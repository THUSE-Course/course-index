# 后端部署

本部分将 Django 小作业构建为容器镜像，通过 GitLab CI/CD 部署到个人 Kubernetes 命名空间。

项目名使用 `2026-Django-HW`，示例访问地址为：

```text
https://u-<学号>-2026-django-hw.t.secoder.net
```

## 生产运行配置

### 关闭调试模式

正式部署时必须关闭 Django 的 `DEBUG`。可以通过环境变量区分本地开发和部署环境，例如在 `DEPLOY` 存在时设置 `DEBUG=False`。

不要把生产配置写成只能在某台开发机运行的绝对路径，也不要把密码、`SECRET_KEY` 或第三方 API Key 提交到仓库。

### 使用 WSGI 服务器

`python manage.py runserver` 是开发服务器，不用于部署。按照仓库提供的框架配置 uWSGI：

- 安装并声明 uWSGI 依赖；
- 加载项目的 WSGI module；
- 使用 HTTP 协议监听 `0.0.0.0:80`；
- 让容器启动命令执行项目的 `start.sh`。

参考资料：

- [How to use Django with uWSGI](https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/uwsgi/)
- [uWSGI Documentation](https://uwsgi-docs.readthedocs.io/en/latest/)

## Dockerfile

Dockerfile 应满足：

- Python 版本为 3.11；
- 工作目录为 `/app`；
- 复制源代码并安装 `requirements.txt`；
- 使用 `https://pypi.t.secoder.net/+simple` 作为 SECoder PyPI 镜像；
- 设置部署所需的环境变量；
- 暴露并监听 80 端口；
- 使用 `start.sh` 启动应用。

示例依赖安装命令：

```dockerfile
RUN pip install --no-cache-dir \
    -i https://pypi.t.secoder.net/+simple \
    -r requirements.txt
```

提交前在本地构建并运行镜像：

```bash
docker build -t 2026-django-hw:local .
docker run --rm -p 8000:80 2026-django-hw:local
curl -i http://127.0.0.1:8000/
```

## Kubernetes 资源

在 `deploy/` 中为后端创建：

- Deployment，容器名和标签使用 `app-2026-django-hw`；
- Service，将 80 端口转发到容器的 HTTP 端口；
- HTTPRoute，hostname 使用 `u-<学号>-2026-django-hw.t.secoder.net`；
- Kustomization，包含上述三个资源。

Deployment 至少应配置：

- 镜像占位值，CI 会替换为 `${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}`；
- `imagePullSecrets`；
- CPU 和内存 request/limit；
- 能够反映应用是否可服务的 readiness probe。

如果需要持久化 SQLite 或其他文件，使用 PVC 并挂载到明确的数据目录。不要依赖容器可写层保存数据；Pod 重建后其中的数据会丢失。

完整资源结构和 CI 配置见 [Kubernetes 部署](../../deploy/deployer.md)。请将示例中的前端资源名改为后端资源名，并使用后端实际可用的健康检查路径。

## GitLab CI/CD

后端流水线包含 `build`、`test` 和 `deploy` 阶段：

- `unit-test` 使用 Python 3.11 镜像；
- `before_script` 安装项目依赖；
- `script` 创建并检查迁移，然后运行测试；
- BuildKit 构建并推送镜像；
- Kustomize 将指定提交的镜像部署到个人命名空间；
- 构建和部署只在默认分支执行，测试在普通分支和 Merge Request 中也应运行。

不要把单元测试设为 `allow_failure`，也不要通过修改脚本返回值掩盖失败。

## 完成标准

- 本地测试通过，Docker 镜像能够独立启动。
- GitLab 流水线的测试、构建和部署 Job 均成功。
- `kubectl get pods` 显示后端 Pod Ready。
- Service 存在可用 EndpointSlice。
- HTTPRoute 的 `Accepted` 和 `ResolvedRefs` 条件为 True。
- 从校园网访问后端域名能够得到预期响应，而不是 nginx、404 或 502 占位页。
