# 前端部署

在这一部分，你将会完成 React (Next.js) 小作业的 CI/CD 配置，并通过 CI/CD 将其部署到 SECoder 上。

你需要在 SECoder GitLab 上新建名为 `2023-Next-HW` 的项目并按要求将密钥在 CI/CD 变量中提供。

完成这一部分后，你应当能够在 `https://frontend-{id}.app.secoder.net` 访问你的前端，其中 `{id}` 为你的学号。

## 任务汇总

### 补全 nginx 配置文件 (1.5 分)

**需要修改的代码：**`nginx/default.conf` 第 3-4、13 行

在这一任务中，你将需要补全 nginx 配置文件来使得前端网站能够在 80 端口提供正确的页面文件：

- 修改监听的端口号，使之监听 80 端口；
- 将根目录设置为 `/opt/app/dist`；
- 将对 `/api/` 的请求转发到你的后端地址。

### 编写 Dockerfile (1.5 分)

**需要修改的代码：**`Dockerfile` 第 2 行 (你可以任意改变这部分的代码行数)

在这一任务中，你将需要编写 Dockerfile 来使得构建的镜像能够通过 nginx 反向代理提供 Next.js 生成的静态页面。我们对你的 Dockerfile 有如下要求：

- 使用多阶段构建，最终的镜像仅包含必须的环境与需要提供的页面文件，不包含依赖的第三方库；
- Node.js 版本为 18，nginx 版本为 1.22；
- 使用 Yarn 而非 npm 作为包管理器；
- 将 Yarn 换源到 [npmmirror](https://npmmirror.com) (https://registry.npmmirror.com) 以加速下载；
- 通过 Next.js 构建静态页面文件;
- 最终镜像中，静态页面文件位于 `/opt/app/dist` 目录下。

!!! info "使用 Next.js 导出静态页面文件"

    你可以参考[静态 HTML 页面导出](https://www.nextjs.cn/docs/advanced-features/static-html-export)来了解如何使用 Next.js 导出静态页面文件。

!!! note "在本地测试"

    由于流水线的执行需要花费不少时间，每一次修改 Dockerfile 后都上传到 GitLab 执行 CI/CD 流水线来测试效果是比较低效的。并且，小作业阶段你无法访问容器的日志和终端，这可能会对调试造成阻碍。
    
    你可以通过在本地构建镜像并运行容器来测试运行结果是否符合期望。由于 Docker 的虚拟化特性，如果在本地能够顺利运行，则理论上在部署到 SECoder 后它也一样能够顺利运行。

### 完成 GitLab CI/CD 配置 (1.5 分)

**需要修改的代码：**`.gitlab-ci.yml` 第 20 行 (你可以任意改变这部分的代码行数)

在这一任务中，我们将在 GitLab CI/CD 配置中声明一个有三个阶段 `build`、`test` 和 `deploy` 的流水线，其中 `build` 与 `deploy` 阶段已为你实现完成。你需要补全配置以完成 `test` 阶段，这一阶段包含 `unit-test` 与 `style-test` 两个作业。我们对这两个作业的配置有如下要求：

- 利用作业模板简化配置；
- 在 `node` 镜像上运行，Node.js 版本为 18；
- 使用 Yarn 而非 npm 作为包管理器；
- 在 `before_script` 中将 Yarn 换源到 [npmmirror](https://npmmirror.com) 以加速下载，然后安装依赖；
- 在 `script` 中，`unit-test` 作业执行单元测试，`style-test` 执行代码风格检查；
- 在 `unit-test` 作业的 `after-script` 中，使用 SonarScanner 将测试结果上传到 SonarQube。我们已经预先为你提供了 SonarScanner 配置，因此你不需要学习 SonarQube 的用法也能够完成此任务。

### 思考题：为什么不用 `rewrites`？ (1 分)

在前端小作业的思考题中，你探究了 `rewrites` 函数的作用，并在本地进行前后端对接时将后端地址填入了 `destination` 中。但在本次作业中，我们将后端地址填入了 nginx 配置的 `location /api/` 之中。请查阅资料并解释为什么需要这么做。

## 完成效果

完成任务后，你应当能够成功执行 GitLab CI/CD 流水线并能够通过 `https://frontend-{id}.app.secoder.net` 访问到你部署在 SECoder 上的前端。此时你可以直接通过浏览器访问它并进行正常的游玩。