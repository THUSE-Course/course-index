# 后端部署

在这一部分，你将会完成 Django 小作业的 CI/CD 配置。

你需要在 SECoder GitLab 上新建名为 `2025-Django-HW` 的项目并按要求将密钥在 CI/CD 变量中提供。

## 任务汇总

### 关闭调试开关 (0.5 分)

**需要修改的代码：**`DjangoHW/settings.py` 第 28 行

正式部署的 Django 应用需要关闭调试开关，否则可能会带来安全问题。我们可以在 Dockerfile 中设定某一环境变量来通过它区分当前是否处于部署环境，进而决定是否打开调试开关。

你需要使得环境变量 `DEPLOY` 存在时，调试开关 `DEBUG` 为 `False`，否则为 `True`。

!!! info "`os.getenv`"

    你可以通过 Python 标准库中的 `os.getenv` 函数来读取环境变量。`os.getenv('key')` 将在环境变量 `key` 存在时返回一个 `str`，否则返回 `None`。

### 更改 SECRET_KEY 和 SALT (0 分)

**需要修改的代码：**`DjangoHW/settings.py` 第 24 行；`utils/utils_jwt.py` 第 11 行

你应该在正式部署时将 `SECRET_KEY` 以更安全的方式存储，比如存储在环境变量中然后通过 `os.getenv` 读取。在小作业（和大作业？）中我们不要求一定要这么做，但应该了解这种做法的必要性。

!!! warn "一定要保护好 SECRET_KEY"

    Secret Key 用于生成签名等，泄露之可能导致可以伪造用户身份等严重安全后果。在正式部署时，一定要保护好 SECRET_KEY。

### 使用 uWSGI 部署 (0.5 分)

**需要修改的代码：**`requirements.txt` 第 12 行，`start.sh` 第 6-14 行

现在项目中的 `start.sh` 通过 `python3 manage.py runserver` 启动了开发服务器，这并不适于部署。我们将会通过使用 uWSGI 服务器进行部署来获得更好的性能和安全性。

你需要添加对 uWSGI 的依赖，将应用的运行方式改为通过 uWSGI 运行并监听 80 端口。我们已经为你提供了 `uwsgi` 命令的框架，请你修改它使得它能够正常工作。

!!! info "通过 uWSGI 运行 Django 应用"

    你可以通过 [How to use Django with uWSGI](https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/uwsgi/) 了解如何通过 uWSGI 运行 Django 应用。

    你可以在 [uWSGI Docs](https://uwsgi-docs.readthedocs.io/en/latest/index.html) 更详细地了解 uWSGI 的使用方法。

!!! note "WSL 本地安装 uWSGI"

    如果你是 WSL 用户，直接使用 `pip` 安装 uWSGI 时可能因为编译工具链版本问题而构建失败。你可以尝试通过 Conda 安装 uWSGI：

    ```bash
    conda install uwsgi
    ```

请阅读上述文档并理解我们提供的选项的作用，**并修改部分参数**使之能够正确运行。

### 完成 Dockerfile (0.5 分)

**需要修改的代码：**`Dockerfile` 第 2-14 行

我们提供了 Dockerfile 的框架，现在请你补全这份 Dockerfile，使构建的镜像满足如下要求：

- Python 版本为 3.11；
- 设定 `DEPLOY` 环境变量为 `1`；
- 工作目录为 `/app`；
- 将源代码复制到工作目录；
- 安装 `requirements.txt` 声明的依赖并通过换源到 `https://pypi-cache-sepi.app.spring25a.secoder.net/simple` 加速下载；
- 对外暴露 80 端口；
- 容器运行时执行 `start.sh` 脚本。

!!! note "在本地测试"

    由于流水线的执行需要花费不少时间，每一次修改 Dockerfile 后都上传到 GitLab 执行 CI/CD 流水线来测试效果是比较低效的。并且，小作业阶段你无法访问容器的日志和终端，这可能会对调试造成阻碍。
    
    你可以通过在本地构建镜像并运行容器来测试运行结果是否符合期望。由于 Docker 的虚拟化特性，如果在本地能够顺利运行，则理论上在部署到 SECoder 后它也一样能够顺利运行。

!!! tip "Secoder Pypi 镜像"

    你可以通过 `https://pypi-cache-sepi.app.spring25a.secoder.net/simple` 镜像下载 Python 包。这个镜像是对 TUNA 镜像的本地缓存，这样做可以显著减轻 Secoder 对 TUNA 镜像的访问压力，同时能够进一步加速下载（常常在 3s 内可以完成依赖下载的步骤）。

### 完成 GitLab CI/CD 配置 (0.5 分)

**需要修改的代码：**`.gitlab-ci.yml` 第 2、19-21、25、30、34-36、41、51、56-57 行

我们将在 GitLab CI/CD 配置中声明一个有三个阶段 `build`、`test` 和 `deploy` 的流水线，其中每个阶段都只有一个作业。你需要补全配置以实现如下目标：

- `build` 和 `deploy` 作业仅在 `master` 分支执行；
- `unit-test` 作业在 `python` 镜像而非 `deployer` 镜像上运行，其中 Python 版本为 3.11；
- 在 `unit-test` 作业的 `before_script` 部分安装 `requirements.txt` 声明的依赖并通过换源到 TUNA 加速下载；
- 在 `unit-test` 作业的 `script` 部分创建并执行数据库迁移计划（migrations，修改数据表结构与属性的语句），然后运行单元测试脚本 test.sh。

为了让大家进行本地测试，我们不会为大家创建 Secoder 上的容器，因此 CI/CD 流水线执行过程中你的 `deploy` 阶段可能会执行失败，这是正常现象。

### 思考题：为什么改了这个选项？ (0.5 分)

在使用 uWSGI 运行的过程中，我们使用了 `--http` 选项而非上面给出的教程中的 `--socket` 选项。同时，我们监听了 `0.0.0.0` 而非 `127.0.0.1`。请查阅资料并解释 `--http` 选项与 `--socket` 选项的区别，并解释监听 `0.0.0.0` 的原因。

### 本地测试 (0 分)

你需要在本地构建 Docker 镜像并通过 [curl](https://curl.se)、[Postman](https://www.postman.com) 等工具来测试能否与容器中的后端正常通信。

在本地构建 Docker 镜像和运行 Docker 容器的方法可以参考 Docker 文档的 [本地运行容器](../../../deploy/docker#_2) 部分。

!!! warning "请务必完成本任务"

    尽管此任务并不直接计入分数，但由于无法将后端小作业部署到 SECoder 平台上，如没有在本地进行测试，很可能在小作业验收时出现问题。

!!! info "在 SECoder 上测试"

    你可以暂时利用前端小作业的容器来测试后端的部署，具体做法是将 `deployer dyno replace` 命令的 dyno 由 `backend` 改为 `frontend`，这之后你可以在 `https://frontend-{id}.app.secoder.net` 访问到后端并测试部署是否正常，其中 `{id}` 为你的学号。

    请在作业截止前检查你的容器是否运行着前端小作业，否则我们无法验收前端小作业。

## 完成效果

完成任务后，你应当能够成功执行 GitLab CI/CD 流水线 deploy 阶段前的所有阶段，并能够在本地正常与容器中的后端进行通信。
