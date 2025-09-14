# 前端部署

在这一部分，你将会完成 React (Next.js) 小作业的 CI/CD 配置，并通过 CI/CD 将其部署到 SECoder 上。

你需要在 SECoder GitLab 上新建名为 `2025-Next-HW` 的项目并按要求将密钥在 CI/CD 变量中提供。

完成这一部分后，你应当能够在 `https://frontend-{id}.app.spring25{a|b}.secoder.net` 访问你的前端，其中 `{id}` 为你的学号。

## 任务汇总

### 修改 Next.js 配置 (0.5 分)

**需要修改的代码：**`next.config.js` 第 4, 13 行

在这一任务中，你将需要修改 Next.js 配置文件来使得前端网站能够在 80 端口提供正确的页面文件。首先，你需要阅读 [next.config.js Options: output | Next.js](https://nextjs.org/docs/app/api-reference/next-config-js/output) 来了解 Next.js 配置中可选的构建输出选项。

!!! warning "阅读文档"

    阅读文档是实际开发中一项非常重要的技能，搜索和阅读官方文档往往是找到某一问题解决方案的最快方法之一。这一页面提供了许多关于 Next.js 构建过程的说明，其中也包含了许多你将在本次作业中用到的信息，因此请仔细阅读。

接下来，你需要完成下列任务：

- 修改 Next.js 的输出模式，使之能够构建出独立的最小服务端，并尝试在本地运行这一服务端，测试能否正常访问；
- 将对 `/api/` 的请求重写到标准后端 URL `https://backend-sepi.app.spring25{a|b}.secoder.net/`。

### 编写 Dockerfile (1 分)

**需要修改的代码：**`Dockerfile` 第 2 行 (你可以任意改变这部分的代码行数)

在这一任务中，你将需要编写 Dockerfile 来使得构建的镜像能够通过 node 运行生成的服务端。我们对你的 Dockerfile 有如下要求：

- 使用多阶段构建，最终的镜像仅包含必须的环境、需要提供的页面文件与构建的服务端，不包含开发依赖。
- Node.js 版本为 22；
- 使用 pnpm 而非 npm 作为包管理器；
- 将 pnpm 换源到本地源 https://npm-cache-sepi.app.spring25a.secoder.net/ 以加速下载；
- 通过 Next.js 构建独立服务端 (standalone);
- 最终镜像中，服务端位于 `/app` 目录下。

!!! warning

    由于 SECoder 上容器的运行环境与本地 Docker 环境略有不同，请直接使用默认的 `root` 用户运行命令，而不是使用新建的用户。

??? tip "一些提示。仅在你需要帮助时再来查看！"

    - 开发过程中，我们一般使用 `pnpm dev` 在本地启动开发服务器，但这需要包含庞大的开发依赖，而我们希望构建出最小化的独立服务端，因此这不再可行。你可以通过 `pnpm build` 命令来构建服务端。这些脚本在 `package.json` 中被定义，你也可以自定义所需的脚本。
    - 如果你仔细阅读 `output` 选项的文档，你会注意到 `public` 等静态文件默认不会被复制到 `standalone` 目录中。你需要将这些文件复制到 `standalone` 目录中，否则你的网站将无法正常加载静态资源。
    - 默认情况下，Next.js 服务器会监听 3000 端口，你需要在运行服务器前使用环境变量 `PORT` 来指定监听的端口。HTTP 服务的端口为 80，这也是在浏览器中通过 `http://` 访问网站时的默认端口。
    - 如果你还是觉得无从下手，可以试着从 Next.js 官方的 [Docker 示例项目](https://github.com/vercel/next.js/tree/canary/examples/with-docker) 获取一些灵感。

!!! note "在本地测试"

    由于流水线的执行需要花费不少时间，每一次修改 Dockerfile 后都上传到 GitLab 执行 CI/CD 流水线来测试效果是比较低效的。并且，小作业阶段你无法访问容器的日志和终端，这可能会对调试造成阻碍。
    
    你可以通过在本地构建镜像并运行容器来测试运行结果是否符合期望。由于 Docker 的虚拟化特性，如果在本地能够顺利运行，则理论上在部署到 SECoder 后它也一样能够顺利运行。

### 完成 GitLab CI/CD 配置 (1 分)

**需要修改的代码：**

`.gitlab-ci.yml` 第 2 行，把 Deployer Image 设置成对应 SECoder 的镜像；第 30 行把 Deployer Server 设置成对应的地址。

`.gitlab-ci.yml` 第 22 行 (你可以任意改变这部分的代码行数)

在这一任务中，我们将在 GitLab CI/CD 配置中声明一个有三个阶段 `build`、`test` 和 `deploy` 的流水线，其中 `build` 与 `deploy` 阶段已为你实现完成。你需要补全配置以完成 `test` 阶段，这一阶段包含 `unit-test` 与 `style-test` 两个作业。我们对这两个作业的配置有如下要求：

- 利用作业模板简化配置；
- 在 `node` 镜像上运行，Node.js 版本为 22；
- 使用 pnpm 而非 npm 作为包管理器；
- 在 `before_script` 中将 pnpm 换源到 https://npm-cache-sepi.app.spring25a.secoder.net/ 以加速下载，然后安装依赖；
- 在 `script` 中，分别通过 pnpm 脚本 `test` 和 `lint` 在 `unit-test` 作业执行单元测试，`style-test` 作业执行代码风格检查；
- 在 `unit-test` 作业的 `after_script` 中，使用 SonarScanner 将测试结果上传到 SonarQube。我们已经预先为你提供了 SonarScanner 配置，因此你不需要学习 SonarQube 的用法也能够完成此任务。

## 完成效果

完成任务后，你应当能够成功执行 GitLab CI/CD 流水线并能够通过 `https://frontend-{id}.app.spring25{a|b}.secoder.net` 访问到你部署在 SECoder 上的前端。此时你可以直接通过浏览器访问它并进行正常的游玩。