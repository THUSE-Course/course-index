# FAQ

本部分收集与本地环境、代码框架和通用开发工具有关的常见问题。SECoder 与 Kubernetes 问题请优先查阅[部署基础](deploy/index.md)。

!!! question "`conda activate` 后，`python3` 仍然启动系统 Python"

    先执行 `which python`、`which python3` 和 `python --version`，确认当前 shell 实际解析到的可执行文件。常见原因包括 Conda 尚未为当前 shell 初始化、激活脚本没有生效，或 PATH 中存在优先级更高的 Python。

    可以重新打开终端并执行 `conda init <你的 shell>`，再激活环境。若 `python` 已经指向 Conda 环境而 `python3` 没有，可以在该环境中统一使用 `python`，但仍应先确认依赖确实安装在当前环境中。

!!! question "Corepack 无法从官方源下载 pnpm"

    可以不使用 Corepack，改用已经安装的 npm：

    ```bash
    npm install -g pnpm
    ```

    安装后运行 `pnpm --version` 检查是否成功。这个问题只影响本地工具安装，不影响作业代码本身。

!!! question "无法从 Tsinghua Git 克隆作业仓库"

    使用 HTTPS 地址时，先确认浏览器能够访问仓库且自己的账号具有读取权限。

    使用 SSH 地址时，检查 `~/.ssh/id_ed25519.pub` 等公钥文件是否存在；如不存在，可使用 `ssh-keygen` 创建密钥对，然后把公钥添加到 Tsinghua Git 的 SSH Keys 页面。不要上传或发送没有 `.pub` 后缀的私钥文件。

!!! question "作业仓库设为 Public 或 Internal 会有影响吗"

    建议将个人作业仓库设为 Private，避免未完成的代码或答案被其他人直接复制。除非课程要求明确允许，不要通过公开仓库分享作业实现。

!!! question "构建或 CI 无法执行 `.sh` 脚本"

    先检查脚本是否具有可执行权限：

    ```bash
    chmod +x start.sh test.sh
    git add start.sh test.sh
    git commit
    ```

    也可以显式使用 `sh start.sh`，但脚本若依赖 Bash 语法，应使用 `bash start.sh`。

    Windows 用户还应检查文件换行符。容器内通常使用 Linux，脚本应保存为 LF，而不是 CRLF。

!!! question "Next.js 回放页面刷新后出现 client-side exception"

    先查看浏览器开发者工具中的 Console 和 Network，确认是代码异常、静态资源路径还是旧版本框架问题。若问题来自已修复的 Next.js 缺陷，可以在兼容现有项目的前提下更新依赖：

    ```bash
    pnpm add next
    ```

    更新后应重新运行单元测试、构建和本地服务，不能只根据开发模式判断修复成功。

!!! question "Next.js 在 `/list` 等前端路由刷新后返回 403 或 404"

    这通常是静态文件服务器不知道前端路由应回退到入口页面。若使用 nginx 提供静态站点，可以检查 `try_files`：

    ```nginx
    try_files $uri $uri.html $uri/index.html /index.html;
    ```

    如果使用 Next.js standalone 服务端，则应检查构建输出、路由配置和启动命令，而不是直接套用静态站点的 nginx 配置。

!!! question "前端构建后只能看到 403 Forbidden"

    检查 Docker 镜像中是否真正包含构建产物，以及 Web 服务器的根目录是否指向这些文件。可以先在本地运行镜像，并进入容器查看目标目录。使用 Next.js 静态导出时，还要确认 `public` 和生成的 HTML、JavaScript 文件均被复制到最终镜像。

!!! question "Django 启动后返回 500 Internal Server Error"

    500 表示请求已经到达 Django 进程，但应用处理失败。首先查看服务端日志和异常栈，再检查 uWSGI 启动参数、Django settings、数据库迁移以及必需的环境变量。

    部署时不要使用 `manage.py runserver`。阅读 [Django 的 uWSGI 文档](https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/uwsgi/)，确认模块路径、HTTP 监听地址和端口均与项目一致。
