# GitLab CI/CD

**持续集成**（Continuous Integration，CI）是在代码发生变化时自动完成依赖安装、构建、测试和静态检查。**持续部署**（Continuous Deployment，CD）是在这些检查通过后，把指定版本的应用发布到运行环境。

SECoder GitLab 会读取仓库根目录的 `.gitlab-ci.yml`，并在提交代码或创建合并请求时运行流水线。

## 基本概念

### Job

Job 是流水线的最小执行单元，包含执行环境、命令和产物。例如：

```yaml
unit-test:
  image: python:3.11
  stage: test
  script:
    - pip install -r requirements.txt
    - pytest
```

任意一条 `script` 命令返回非零状态时，Job 默认失败。不要在测试命令后追加一个必定成功的命令来掩盖错误。

### Stage

Stage 决定 Job 的执行顺序。同一 Stage 的 Job 可以并行运行；当前 Stage 全部成功后，流水线才进入下一阶段。

```yaml
stages:
  - build
  - test
  - deploy
```

### Pipeline

一次 Pipeline 是某个提交对应的完整执行过程。可以在 GitLab 项目的 **Build → Pipelines** 中查看每个 Job 的状态和日志。

网络波动导致的偶发失败可以重试；配置或测试错误应先修复代码，不能依靠反复重试碰运气。

## YAML 速览

YAML 使用缩进表示层级，并用 `-` 表示数组元素：

```yaml
job-name:
  image: node:22
  stage: test
  before_script:
    - corepack enable
    - pnpm install --frozen-lockfile
  script:
    - pnpm test
```

只能使用空格缩进，不能混用 Tab。包含 `:`、`#` 或其他特殊字符的字符串无法按预期解析时，应显式加引号。

## 隐藏 Job 与继承

以 `.` 开头的 Job 不会直接运行，可作为模板被其他 Job 继承：

```yaml
.node-test:
  image: node:22
  stage: test
  before_script:
    - corepack enable
    - pnpm config set registry https://npm-registry.t.secoder.net/
    - pnpm install --frozen-lockfile

unit-test:
  extends: .node-test
  script:
    - pnpm test

style-test:
  extends: .node-test
  script:
    - pnpm lint
```

课程提供的 BuildKit 和 Kustomize 配置同样通过隐藏 Job 复用。完整内容见 [Kubernetes 部署](deployer.md#gitlab-cicd)。请直接把模板内容放入项目的 `.gitlab-ci.yml`，不要使用远程 `include:`。

## 组成完整流水线

将 `.buildkit`、`.kustomize` 与测试 Job 放入同一个文件后，可以定义实际执行的构建和部署 Job：

```yaml
stages:
  - build
  - test
  - deploy

build-image:
  extends: .buildkit
  stage: build
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'

unit-test:
  extends: .node-test
  stage: test
  script:
    - pnpm test

style-test:
  extends: .node-test
  stage: test
  script:
    - pnpm lint

deploy:
  extends: .kustomize
  stage: deploy
  variables:
    KUSTOMIZE_PATH: deploy
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
```

实际项目的 `deploy` Job 还需要创建私有镜像拉取 Secret，并把 Deployment 中的镜像替换为 `${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}`。不要在多个页面之间拼猜命令，直接以 [Kubernetes 部署](deployer.md#gitlab-cicd)中的完整示例为基础修改资源名。

## 变量

GitLab 自动提供常用的预定义变量：

|变量|说明|
|-|-|
|`CI_DEFAULT_BRANCH`|项目默认分支|
|`CI_COMMIT_SHA`|当前提交的完整 Git SHA|
|`CI_PROJECT_PATH_SLUG`|适合用于资源名的项目路径|
|`CI_REGISTRY`|GitLab Container Registry 地址|
|`CI_REGISTRY_IMAGE`|当前项目的镜像仓库地址|
|`CI_REGISTRY_USER`|当前构建 Job 使用的 Registry 用户名|
|`CI_REGISTRY_PASSWORD`|当前构建 Job 使用的 Registry 密码|

SECoder 部署还需要项目变量：

|变量|来源|
|-|-|
|`TOKEN`|SECoder 个人资料页面中的 Kubernetes API 令牌|
|`NAMESPACE`|个人命名空间 `u-<学号>`|
|`GITLAB_REGISTRY_USER`|长期 Registry 凭据对应的 GitLab 用户名|
|`GITLAB_PAT`|具有 `read_registry` 权限的 Token|

`TOKEN` 与 `GITLAB_PAT` 必须设为 Masked，不应出现在 `.gitlab-ci.yml`、仓库文件或 Job 日志中。轮换 SECoder API 令牌后，要同步更新所有项目中的 `TOKEN`。

## Rules

使用 `rules` 限制 Job 在哪些提交上运行。例如只在默认分支构建和部署：

```yaml
rules:
  - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
```

测试通常应在分支和 Merge Request 中运行，而部署应只在默认分支运行。这样可以在合并前发现问题，同时避免开发分支覆盖线上应用。

## 测试报告和产物

测试工具可以生成 JUnit、覆盖率等报告，再通过 `artifacts` 上传给 GitLab 或 SonarQube：

```yaml
unit-test:
  stage: test
  script:
    - pytest --junitxml=xunit-reports/xunit-result.xml
  artifacts:
    when: always
    reports:
      junit: xunit-reports/xunit-result.xml
```

即使上传报告，也必须保留测试命令的失败状态。报告用于解释失败，不能把失败的测试变成成功。

## 排查流水线

1. 先确定失败属于 build、test 还是 deploy 阶段。
2. 从 Job 日志中找到第一条实际错误，不要只看最后的 `exit code 1`。
3. build 失败时，在本地运行相同的 Docker 构建。
4. test 失败时，在相同语言版本和锁文件下运行测试。
5. deploy 失败时，检查 CI 变量是否存在，再使用 [kubectl](kubectl.md)查看资源和事件。

更多 GitLab CI/CD 语法见 [GitLab CI/CD documentation](https://docs.gitlab.com/ci/)。
