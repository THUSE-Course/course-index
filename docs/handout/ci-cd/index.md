# CI/CD 小作业

本部分的目标是将前后端小作业推送到 SECoder GitLab，通过流水线完成测试、镜像构建和 Kubernetes 部署，并能够从浏览器访问应用。

开始前请阅读：

- [Docker](../../deploy/docker.md)
- [SECoder](../../deploy/secoder.md)
- [kubectl](../../deploy/kubectl.md)
- [Kubernetes 部署](../../deploy/deployer.md)
- [GitLab CI/CD](../../deploy/gitlab-ci.md)

## 项目准备

在自己的 SECoder GitLab 命名空间中创建两个 Private 项目：

- `2026-Django-HW`
- `2026-Next-HW`

完成 SECoder 注册和 GitLab 登录后，在 SECoder **个人资料**页面点击一次 **同步 GitLab 子组**。如果看不到自己的 GitLab 命名空间或项目权限不正确，先重新同步再刷新 GitLab。

## CI/CD 变量

前端和后端项目都需要在 **Settings → CI/CD → Variables** 中添加：

|Key|Value|设置|
|-|-|-|
|`TOKEN`|SECoder 个人资料页面中的 Kubernetes API 令牌|Masked|
|`NAMESPACE`|`u-<学号>`|普通变量|
|`GITLAB_REGISTRY_USER`|Registry Token 对应的 GitLab 用户名|普通变量|
|`GITLAB_PAT`|具有 `read_registry` 权限的 Token|Masked|

Registry Token 用于让 Kubernetes 在 CI 作业结束后仍能从私有 Registry 拉取镜像。它只需要 `read_registry` 权限，不要为完成本作业授予 `api`、`write_repository` 等无关权限。

!!! warning "不要提交凭据"

    不要把 Token、kubeconfig 或包含凭据的 Docker 配置提交到仓库。截图和答疑日志中也必须隐藏完整值。

## 仓库中的部署文件

每个项目都应包含：

```text
.gitlab-ci.yml
Dockerfile
deploy/
├── deployment.yaml
├── service.yaml
├── httproute.yaml
└── kustomization.yaml
```

前后端必须使用不同的资源名、HTTPRoute 名和 Registry Secret 名。域名都以个人命名空间开头，例如：

- `u-2026000000-2026-django-hw.t.secoder.net`
- `u-2026000000-2026-next-hw.t.secoder.net`

## 流水线结果

正常的默认分支流水线应依次完成：

1. 运行单元测试和代码风格检查。
2. 使用 BuildKit 构建 Docker 镜像。
3. 使用提交 SHA 作为镜像标签并推送到 GitLab Container Registry。
4. 创建或更新 Registry 拉取 Secret。
5. 使用 Kustomize 更新 Deployment、Service 和 HTTPRoute。
6. 等待工作负载 Ready，并通过外部域名访问应用。

## 自查

在推送前，至少完成以下检查：

```bash
docker build -t homework-local .
kubectl kustomize deploy
```

部署后检查：

```bash
kubectl get deployment,pod,service,httproute
kubectl get events --sort-by=.metadata.creationTimestamp
```

若出现错误，先确定失败发生在测试、镜像构建还是 Kubernetes 部署阶段，再按照 [kubectl 排查应用](../../deploy/kubectl.md#troubleshooting)逐层检查。提问时提供已隐藏凭据的 Job 日志和资源状态。
