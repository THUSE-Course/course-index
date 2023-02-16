# 后端部署

在这一部分，你将会完成 Django 小作业的 CI/CD 配置，并通过 CI/CD 将其部署到 SECoder 上。

你需要在 SECoder GitLab 上新建名为 `2023-Django-HW` 的项目并按要求将密钥在 CI/CD 变量中提供。

完成这一部分后，你应当能够在 `https://backend-{id}.app.secoder.net` 访问你的后端，其中 `{id}` 为你的学号。

## 任务汇总

### 完成 Dockerfile (1 分)

**需要修改的代码：**`Dockerfile` 第 2-14 行

我们提供了 Dockerfile 的框架，现在请你补全这份 Dockerfile，使构建的镜像满足如下要求：

- Python 版本为 3.9；
- 设定 `DEPLOY` 环境变量为 `1`；
- 工作目录为 `/opt/tmp`；
- 将源代码复制到工作目录；
- 安装 `requirements.txt` 声明的依赖并通过换源到 TUNA 加速下载；
- 对外暴露 80 端口；
- 容器运行时执行 `start.sh` 脚本。

### 关闭调试开关 (1 分)

**需要修改的代码：**`DjangoHW/settings.py` 第 29 行

正式部署的 Django 应用需要关闭调试开关，否则可能会带来安全问题。由于我们在 Dockerfile 中设定了 `DEPLOY` 环境变量，我们可以通过此环境变量来区分当前是否处于部署环境，进而决定是否打开调试开关。

你需要使得环境变量 `DEPLOY` 存在时，调试开关 `DEBUG` 为 `False`，否则为 `True`。

!!! info "`os.getenv`"

    你可以通过 Python 标准库中的 `os.getenv` 函数来读取环境变量。`os.getenv(key)` 将在环境变量 `key` 存在时返回一个 `str`，否则返回 `None`。

### 使用 uWSGI 部署 (1 分)

**需要修改的代码：**`requirements.txt` 第 12 行，`start.sh` 第 6-14 行

现在项目中的 `start.sh` 通过 `python3 manage.py runserver` 启动了开发服务器，这并不适于部署。我们将会通过使用 uWSGI 进行部署来获得更好的性能和安全性。

你需要添加对 uWSGI 的依赖，将应用的运行方式改为通过 uWSGI 运行并监听 80 端口。我们已经为你提供了 `uwsgi` 命令的框架，请你修改它使得它能够正常工作。

!!! info "通过 uWSGI 运行 Django 应用"

    你可以通过 [How to use Django with uWSGI](https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/uwsgi/) 了解如何通过 uWSGI 运行 Django 应用。

    你可以在 [uWSGI Docs](https://uwsgi-docs.readthedocs.io/en/latest/index.html) 更详细地了解 uWSGI 的使用方法。

请阅读上述文档并理解我们提供的选项的作用，并修改部分参数使之能够正确运行。

### 完成 GitLab CI/CD 配置 (1 分)

**需要修改的代码：**`.gitlab-ci.yml` 第 17-18、23、28、32-34、48-49 行

我们将在 GitLab CI/CD 配置中声明一个有三个阶段 `build`、`test` 和 `deploy` 的流水线，其中每个阶段都只有一个作业。你需要补全配置以实现如下目标：

- `build` 和 `deploy` 作业仅在 `master` 分支执行；
- `unit-test` 作业在 `python` 镜像而非 `deployer` 镜像上运行，其中 Python 版本为 3.9；
- 在 `unit-test` 作业的 `before_script` 部分安装 `requirements.txt` 声明的依赖并通过换源到 TUNA 加速下载；
- 在 `unit-test` 作业的 `script` 部分创建并执行迁移，然后运行单元测试脚本 `test.sh`。

### 思考题：为什么改了这个选项？ (0.5 分)

在使用 uWSGI 运行的过程中，我们使用了 `--http` 选项而非上面给出的教程中的 `--socket` 选项。同时，我们监听了 `0.0.0.0` 而非 `127.0.0.1`。请查阅资料并解释 `--http` 选项与 `--socket` 选项的区别，并解释监听 `0.0.0.0` 的原因。

## 完成效果

完成任务后，你应当能够成功执行 GitLab CI/CD 流水线并能够通过 `https://backend-{id}.app.secoder.net` 访问到你部署在 SECoder 上的后端。此时你可以使用 [curl](https://curl.se)、[Postman](https://www.postman.com) 等工具来向它发送请求并得到正确的响应。

完成前端小作业后，你可以将 API 地址修改为此 URL 并测试前后端的对接。
