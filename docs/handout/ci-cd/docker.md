# Docker

SECoder 平台通过构建 Docker 镜像并运行容器进行部署。Docker 是一个应用程序容器化环境，通过将程序隔离在不同的容器中运行来提供一致的运行环境，降低运维成本。

Docker 可以理解为程序级别的虚拟化，类比于虚拟机，但 Docker 容器要轻量得多，几乎不带来性能损耗。

## Dockerfile

在进行部署之前，我们首先需要将程序运行所需的环境构建为一个**镜像 (Image)**。一个镜像包含与主机隔离的属于自己的文件系统。我们通过构建镜像将程序运行所需的环境放入这个文件系统中，之后基于镜像运行一个**容器 (Container)**。镜像与容器的关系类似于程序 (Program) 与进程 (Process) 的关系，即镜像是静态存在，而容器是基于镜像运行的动态存在。

我们通过 Dockerfile 文件指示构建镜像时需要执行的操作。以下是一个示例 Dockerfile：

```dockerfile
FROM python:3.10

ENV HOME=/opt/app

WORKDIR $HOME

COPY requirements.txt .

RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

COPY src $HOME

EXPOSE 80

CMD ["python3", "main.py"]
```

我们将会通过逐句讲解此 Dockerfile 中每条指令的作用来让你对 Docker 镜像的构建过程有一个快速了解。

```dockerfile
FROM python:3.9
```

指定当前镜像基于什么镜像进行构建。你可以在 [Docker Hub](https://hub.docker.com) 上找到各种各样的镜像。一般来说，一个镜像只包含能够满足功能需求的最小环境。例如，我们在这里所使用的 `python` 镜像就包含了能够运行 Python 的最小环境。这样做的好处是使镜像充分精简，同时允许通过基于已有镜像构建新镜像的方法获得所需的功能。

在镜像名后可以加上以冒号分隔的标签。标签一般指定镜像的版本，例如这里是 `3.9`，代表此镜像的 Python 版本为 3.9。如果不指定标签，默认获取标签为 `latest` 的版本。

!!! note "本课程中你也许会需要的镜像"

    这里列出几个在本课程中也许用得到的镜像，你可以基于它们构建自己的镜像。

    |镜像|说明|
    |-|-|
    |[ubuntu](https://hub.docker.com/_/ubuntu)|Ubuntu 镜像，为程序提供基础运行环境|
    |[gcc](https://hub.docker.com/_/gcc)|GCC 镜像，用于 C/C++ 程序的编译|
    |[python](https://hub.docker.com/_/python)|Python 镜像，用于基于 Python 的后端等|
    |[node](https://hub.docker.com/_/node)|Node.js 镜像，用于前端网站文件的生成|
    |[nginx](https://hub.docker.com/_/nginx)|nginx 镜像，用于前端网站的反向代理|
    |[mysql](https://hub.docker.com/_/mysql)|MySQL 镜像，用于数据库容器|
    |[postgres](https://hub.docker.com/_/postgres)|PostgreSQL 镜像，用于数据库容器|

```dockerfile
ENV HOME=/opt/app
```

设定一个环境变量。注意环境变量不仅可以在后续指令中使用，也会保留到容器运行时。

```dockerfile
WORKDIR $HOME
```

指定工作目录。注意这一工作目录指在镜像的文件系统中的工作目录，而非本机的文件系统。这一工作目录不仅会作为之后 Dockerfile 指令的工作目录，也会作为运行时的初始工作目录。如不指定，默认工作目录为根目录 `/`。在这里我们用 `$HOME` 引用了我们之前声明的环境变量。

```dockerfile
COPY requirements.txt .
```

将本机文件系统的文件拷贝到镜像文件系统中。这里我们将本机文件系统中，工作目录 (即 Dockerfile 所在的目录) 下的 `requirements.txt` 复制到镜像文件系统中的 `.` 即工作目录，这里是 `/opt/app`。

!!! note "requirements.txt"

    将 Python 程序需要的第三方库的清单列入 `requirements.txt` 是一种常见做法。以下是一个示例 `requirements.txt`：

    ```
    django
    requests==2.28.1
    ```

    这表明程序需要 `django` 以及版本为 `2.28.1` 的 `requests` 库来运行。

```dockerfile
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
```

`RUN` 指令在镜像环境中执行一段命令。在这里，我们在镜像中通过 `pip` 安装 `requirements.txt` 指定的第三方库，其中 `-i` 选项将索引源更换到 TUNA 以加快下载速度。`RUN` 指令的影响将会在镜像中保留。因此，最终构建的镜像将包含有我们安装的第三方库。

`RUN` 是一个构建时的指令，这意味着运行容器时将不会重新执行这段命令。

```dockerfile
COPY src $HOME
```

将主机文件系统中的 `src` 目录下的文件复制到镜像文件系统的 `$HOME` 目录。

!!! warning

    目录本身不会被复制，只有目录下的文件会被复制。

我们通过将程序复制到镜像中来在容器运行时执行程序。对于 Python 这样的解释型语言，我们将源文件复制到镜像中即可。

```dockerfile
EXPOSE 80
```

暴露 80 端口。Docker 容器的网络环境与外界同样是隔离的，因此如果需要让外界能够向容器发送网络请求，就需要指定需要暴露的端口。

```dockerfile
CMD ["python3", "main.py"]
```

指定容器运行时执行的命令。注意，与 `RUN` 指令不同，容器构建时不会执行这段命令，只有容器启动时才会。注意此指令的格式，需要将每个参数分隔为单独字符串并在最外层加方括号。这里的这条指令表明基于该镜像的容器运行时将执行 `python3 main.py`。典型地，这条指令用于启动我们的程序。不过，如果程序运行步骤比较复杂，我们一般会选择将程序运行逻辑写为一个 shell 脚本，而在 Dockerfile 中使用 `CMD ["sh", "run.sh"]` 之类的指令来执行这个脚本。

!!! warning "不要将开发配置作为正式部署"

    由于正式部署的站点是对外开放的，使用开发配置进行部署将带来极大的危险性。例如，如果你直接使用 `python3 manage.py runserver` 作为容器的运行命令，这将启动一个开发服务器，在发生异常时程序的调用栈将会直接展示给用户。

    正确的部署方式可以参考你所使用的框架的文档。例如，[How to deploy Django](https://docs.djangoproject.com/en/4.1/howto/deployment/) 文档说明了应该如何部署 Django，包括使用 Gunicorn 和 uWSGI 等方式。

---

到此，该镜像的构建过程就结束了，之后我们就可以使用 SECoder 的 deployer 工具基于构建的镜像运行一个容器。

## 多阶段构建

前面我们提到，Python 等解释型语言只需要将源文件直接复制到镜像中，在容器运行时解释运行源文件即可。但对于 C++/Go/Rust 等编译型语言来说，我们通常不会在容器运行时再进行编译，而是在镜像构建时就执行编译，在容器运行时直接执行可执行文件即可。但是，我们通常希望镜像尽可能精简，为此我们希望最终的镜像只包含可执行文件，不包含源文件。我们可以使用多阶段构建来实现这一点。

结合本课程的特点，下面我们以前端镜像的构建为例说明多阶段构建。前端的部署过程与编译型语言有些类似：我们首先生成网站所提供的静态文件，然后再通过 nginx 反向代理使网站向访问者提供这些文件。

```dockerfile
# Stage 0
FROM node:16

ENV FRONTEND=/opt/frontend

WORKDIR $FRONTEND

RUN npm config set registry https://registry.npm.taobao.org

COPY . .

RUN npm install

RUN npm run build

# Stage 1
FROM nginx:1.22

ENV HOME=/opt/app

WORKDIR $HOME

COPY --from=0 /opt/frontend/dist dist

COPY nginx /etc/nginx/conf.d

EXPOSE 80
```

可以看到，现在我们的构建过程被 `FROM` 指令分为两个阶段。(`#` 开头的行只是注释。) 在第一个阶段，我们首先将 `npm` 源更换为淘宝源以加速下载，然后将主机文件系统下当前目录的文件全部复制到镜像文件系统中，再使用 `npm install` 安装需要的第三方包，最后使用 `npm run build` 生成站点的静态文件。我们的网站只需要这些文件就能提供服务，不需要我们下载的第三方包以及整个工具链。因此，我们接下来在下一个阶段构建我们真正使用的镜像。

!!! note "主机文件系统"

    在 GitLab 平台上执行 CI/CD 时，这里的主机文件系统实际上是我们的仓库，因此 `COPY . .` 实际上是将仓库中的所有文件复制到了镜像的工作目录。因此，不用担心庞大的 `node_modules` 会带来什么负担。

    > 如果你没有忘了 `.gitignore` 它的话。相信我，你不会忘的。

要向外界提供我们的静态文件，我们一般会使用 nginx 进行反向代理，根据请求向客户提供页面文件。

!!! note "nginx"

    我们不会过多介绍 nginx 的用法，你可以通过 [nginx 文档](https://nginx.org/en/docs/) 或网络上的其他资源进行学习。对于简单的前端页面部署，我们提供一个样例 nginx 配置，它应该能够满足多数需求。我们在仓库的 `nginx` 目录下放置以下配置文件：

    ```nginx
    server {
        listen 80;
        root /opt/app/dist;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
    ```

    它表明监听 80 端口，以 `/opt/app/dist` 目录作为根目录，在访问任意 URL 时首先尝试查找该 URL 的文件，再查找该 URL 的目录，最后回退到 `/index.html`。对于由前端框架处理路由的情况来说，实际上只需要反向代理到 `/index.html`，然后由前端框架处理路由即可。

我们基于 `nginx` 镜像构建我们这一阶段的镜像。不同构建阶段的镜像是互相独立的，不共享文件系统。因此，我们在希望从之前的阶段复制文件时，需要使用 `COPY --from={stage}` 指令，其中 `{stage}` 为阶段编号。在这里，我们将前一阶段生成的位于 `/opt/frontend/dist` 目录下的静态文件复制到当前镜像的 `dist` 目录，再将主机文件系统 `nginx` 目录下的配置文件复制到 nginx 的配置目录 `/etc/nginx/conf.d`。最后，我们暴露 80 端口。由于没有显式指定 `CMD` 指令，这一镜像将使用 `nginx` 镜像的 `CMD` 指令，运行 nginx 守护进程。

## 参考资料

以上我们介绍了 Dockerfile 的编写。如果希望更加深入地学习 Docker，包括在本地构建镜像并运行容器等，可以参考 [2022 酒井科协暑培 Docker 文档](https://liang2kl.codes/2022-summer-training-docker-tutorial/) 和 [Docker 官方文档](https://docs.docker.com)。

在本课程提供的[样例项目](https://git.tsinghua.edu.cn/SEG/example)仓库中也可以找到几种常见项目框架的 Dockerfile，可供配置部署时参考。