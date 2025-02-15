# Deployer

SECoder 平台提供了托管 Web 应用的服务，可以通过运行 Docker 容器来使应用向外界提供服务。SECoder 平台提供了 deployer 工具来进行部署镜像的构建、容器的运行、配置文件和持久存储的挂载等操作。

可以通过 `registry.<course_name>.secoder.net/tool/deployer` 镜像访问 deployer 工具。一般情况下，你不需要在本地运行 deployer，而是在 GitLab CI/CD 环境中通过配置的流水线运行 deployer 或者通过 SECoder 的部署管理工具间接使用 deployer。

Course Name 在裴丹老师的班上是 spring25a；在李丹老师的班上是 spring25b。

!!! tip "Deployer Cheat Sheet"

    如果你不想深入了解 deployer 的使用方法，可以直接在 GitLab CI/CD 配置中使用下列命令片段：

    **构建镜像**

    ```shell
    export BUILD_IMAGE_NAME=$CI_REGISTRY_IMAGE
    export BUILD_IMAGE_TAG=$CI_COMMIT_REF_SLUG
    export BUILD_IMAGE_USERNAME=$CI_REGISTRY_USER
    export BUILD_IMAGE_PASSWORD=$CI_REGISTRY_PASSWORD
    deployer build
    ```

    **运行容器**

    ```shell
    deployer dyno replace $CI_PROJECT_NAME "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG" "$REGISTRY_USER" "$REGISTRY_PWD"
    ```

Deployer 有五个子命令：`build`、`env`、`dyno`、`config` 和 `storage`。

## build

```shell
deployer build [dockerfile=Dockerfile]
```

命令接受一个可选参数 `dockerfile` 表示 Dockerfile 的文件名，默认为 `Dockerfile`。

命令会从环境变量中读取构建需要的其他信息：

|环境变量|说明|
|-|-|
|`BUILD_IMAGE_NAME`|镜像名称|
|`BUILD_IMAGE_TAG`|镜像标签|
|`BUILD_IMAGE_USERNAME`|Registry 用户名|
|`BUILD_IMAGE_PASSWORD`|Registry 密码|
|`DEPLOY_BUILDER`|Deployer 构建后端的 URL，默认值为 SECoder 的 deployer 后端；正常情况下你不应改动此项|

镜像构建完成后，将会上传到 SECoder Image Registry 用于后续的运行。

!!! note "在 GitLab CI/CD 中使用"

    正常情况下，你会在 GitLab CI/CD 中用到此命令来构建镜像。具体操作我们将会在下一篇文档中讲解。

## env

SECoder 使用环境来管理权限。每个容器都有其所属的环境，对容器进行管理操作需要有对应环境的权限。一般情况下，团队与环境一一对应，而团队的不同项目则置于环境下的不同容器之中。

SECoder 会为每个环境分配一个部署密钥，在 GitLab CI/CD 环境中可以通过 `DEPLOY_ENV` 与 `DEPLOY_TOKEN` 环境变量来访问当前环境名与部署密钥。

`env` 命令有三个子命令：`list`、`create` 和 `delete`，其中 `create` 与 `delete` 要求密钥具有管理环境的权限。

=== "list"

    ```shell
    deployer env list
    ```

    列出所有环境。

=== "create"

    ```shell
    deployer env create {name}
    ```

    创建具有指定名称的环境。

=== "delete"

    ```shell
    deployer env delete {name}
    ```

    删除具有指定名称的环境。

!!! note "正常情况下不会用到此命令"

    由于正常情况下同学不具有创建和删除环境的权限，一般情况下你不需要用到此命令。

## dyno

此命令用于管理容器。`DEPLOY_ENV` 以及 `DEPLOY_TOKEN` 会用于访问容器所在的环境。

`dyno` 命令有四个子命令：`create`、`delete`、`mount` 和 `replace`。

=== "create"

    ```shell
    deployer dyno create {name}
    ```

    创建具有指定名称的容器。容器的默认镜像为 `nginx`。

=== "delete"

    ```shell
    deployer dyno delete {name}
    ```

    删除具有指定名称的容器。

=== "mount"

    ```shell
    deployer dyno mount {name} {volumes}
    ```

    将给定的挂载项挂载到指定容器，其中 `volumes` 为一个文件名，该文件包含一个 JSON 数组，其中每一项代表一个挂载项，每个挂载项的属性如下：

    |属性|类型|说明|
    |-|-|-|
    |`type`|`"config" | "storage"`|该挂载项的类型，包括配置项和持久存储两种|
    |`name`|`string`|该挂载项的描述性名称|
    |`src`|`string`|挂载项的来源，即使用 `config` 或 `storage` 子命令创建的配置项或持久存储的名称|
    |`path`|`string`|挂载目录|

    !!! note "不能挂载单文件"

        由于 Linux 系统中的挂载实际上是挂载了一个文件系统，因此在表现上，挂载完成后 `path` 将会是一个目录。这意味着你不能挂载单独的一个文件。
        
        例如，若你希望从 `config.json` 中读取配置，则你需要创建一个目录 `config` (名字是无关紧要的)，将 `config.json` 放在其中，将含有 `config.json` 的配置项挂载到此目录，然后在运行时从 `config/config.json` 读取配置。

=== "replace"

    ```shell
    deployer dyno replace {name} {image} [username] [password]
    ```

    使用给定的镜像 `image` 重新运行指定容器 `name`，可选的 `username` 和 `password` 为 image registry 的用户名与密码。

!!! note "在 GitLab CI/CD 中使用"

    正常情况下，你会通过 SECoder 平台创建与仓库关联的容器 (将会在后续文档介绍)，此时相当于执行了 `dyno create`。接下来，在 GitLab CI/CD 的最后一个阶段使用 `dyno replace` 就可以使用新构建的镜像替换项目的容器，这样就完成了将新版本代码部署上线的流程。具体操作我们将会在下一篇文档中讲解。

## config

管理配置项。`DEPLOY_ENV` 以及 `DEPLOY_TOKEN` 会用于访问容器所在的环境。

在开发时和正式部署时使用不同的配置是一种常见做法。例如，你可以让你的后端在开发时连接本地的数据库，在部署时连接部署的数据库。然而，由于容器的易失性，一个容器在重新启动后其中所做的修改都将丢失。这意味着如果我们每次都进入容器手动修改配置将十分低效。

我们可以通过配置项来简化这个流程。配置项是只读的挂载项，可以用于存放各种配置文件。配置项可以作为一个目录被挂载到容器中。这样，在部署时将会自动使用挂载的配置。

`config` 命令有三个子命令：`create`、`delete` 和 `replace`。

=== "create"

    ```shell
    deployer config create {name} {dir}
    ```

    以目录 `dir` 下的内容创建配置项 `name`。

=== "delete"

    ```shell
    deployer config delete {name}
    ```

    删除具有指定名称的配置项。

=== "replace"

    ```shell
    deployer config replace {name} {dir}
    ```

    以目录 `dir` 下的内容替换配置项 `name`。

!!! note "在 SECoder 平台中使用"

    你可以直接使用 SECoder 提供的可视化界面来管理配置项。具体操作我们将在后续文档讲解。

## storage

管理持久存储。`DEPLOY_ENV` 以及 `DEPLOY_TOKEN` 会用于访问容器所在的环境。

数据库容器等需要在容器内保存数据。但同样由于容器的易失性，在容器重启时其中的数据将会丢失，因此我们需要一种能够持久保存数据的方法。

持久存储与配置项类似，都可以挂载到容器的某一目录。它们之间的不同点在于持久存储是可写的，并且你不需要为其提供初始内容。这样，我们就可以在容器重新启动时不致丢失数据了。

`storage` 命令有两个子命令：`create` 和 `delete`。

=== "create"

    ```shell
    deployer storage create {name}
    ```

    创建持久存储 `name`。

=== "delete"

    ```shell
    deployer storage delete {name}
    ```

    删除具有指定名称的持久存储。

!!! note "在 SECoder 平台中使用"

    你可以直接使用 SECoder 提供的可视化界面来管理持久存储。具体操作我们将在后续文档讲解。