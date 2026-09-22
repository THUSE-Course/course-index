# 前端部署

本部分将 Next.js 小作业构建为容器镜像，通过 GitLab CI/CD 部署到个人 Kubernetes 命名空间。

项目名使用 `2026-Next-HW`，示例访问地址为：

```text
https://u-<学号>-2026-next-hw.t.secoder.net
```

## Next.js 运行配置

使用 Next.js 的 `standalone` 输出构建最小服务端，并确认最终镜像包含运行所需的 `.next/standalone`、`.next/static` 和 `public` 内容。

容器中的服务必须监听：

```text
HOSTNAME=0.0.0.0
PORT=80
```

如果浏览器需要直接访问后端，后端地址应使用自己的外部域名：

```text
https://u-<学号>-2026-django-hw.t.secoder.net
```

只有运行在 Kubernetes 集群内部的服务端请求才能使用 Service 地址，例如 `http://app-2026-django-hw`。浏览器无法解析集群内 Service 名称。

参考 [Next.js output 配置](https://nextjs.org/docs/app/api-reference/config/next-config-js/output)了解 standalone 输出。

## Dockerfile

Dockerfile 应满足：

- Node.js 版本为 22；
- 使用 pnpm 和锁文件安装依赖；
- 使用多阶段构建，最终镜像不包含开发依赖和源代码缓存；
- 使用 `https://npm-registry.t.secoder.net/` 作为 SECoder NPM 镜像；
- 把 standalone 服务端、静态资源和 `public` 复制到最终镜像；
- 在 80 端口启动服务。

示例换源命令：

```dockerfile
RUN corepack enable \
    && pnpm config set registry https://npm-registry.t.secoder.net/ \
    && pnpm install --frozen-lockfile
```

提交前在本地构建并运行镜像：

```bash
docker build -t 2026-next-hw:local .
docker run --rm -p 3000:80 2026-next-hw:local
```

通过浏览器访问 `http://127.0.0.1:3000`，并直接刷新 `/list` 等前端路由，确认页面和静态资源均能加载。

## Kubernetes 资源

在 `deploy/` 中为前端创建：

- Deployment，容器名和标签使用 `app-2026-next-hw`；
- Service，将 80 端口转发到容器的 HTTP 端口；
- HTTPRoute，hostname 使用 `u-<学号>-2026-next-hw.t.secoder.net`；
- Kustomization，包含上述三个资源。

Deployment 应配置 Registry 拉取 Secret、资源 request/limit 和针对 `/` 的 HTTP readiness probe。完整示例见 [Kubernetes 部署](../../deploy/deployer.md)。

## GitLab CI/CD

前端流水线包含 `build`、`test` 和 `deploy` 阶段：

- 测试 Job 使用 Node.js 22；
- 使用 pnpm 和 `--frozen-lockfile` 安装依赖；
- 分别运行单元测试与 lint；
- BuildKit 构建镜像并推送到项目 Registry；
- Kustomize 将 `${CI_COMMIT_SHA}` 对应的镜像部署到个人命名空间；
- 构建和部署只在默认分支执行，测试在普通分支和 Merge Request 中也应运行。

代码风格检查是否允许失败以仓库题面为准；单元测试不能设置为 `allow_failure`。

## 完成标准

- 本地测试、lint 和生产构建均通过。
- 本地 Docker 镜像能够在 80 端口提供服务。
- GitLab 流水线的测试、构建和部署 Job 均成功。
- `kubectl get pods` 显示前端 Pod Ready。
- HTTPRoute 的 `Accepted` 和 `ResolvedRefs` 条件为 True。
- 从校园网打开前端域名，并刷新各前端路由，页面均能正常显示。
- 前端能够通过配置的后端外部域名访问后端 API。
