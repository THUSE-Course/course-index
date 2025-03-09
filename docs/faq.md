# FAQ

本部分将收集微信群与网络学堂中提问较多、有价值的问题。

!!! question "13. 交到网络学堂的链接要加 spring25b 吗"

    要. 我们期望三行链接分别可以复制粘贴到浏览器地址栏以访问

    - 后端小作业仓库
    - 前端小作业仓库
    - 前端部署 URL

    只要你提交的内容符合此要求, 啥链接都行. (不要跟我杠说交别人的仓库链接行不行, 当然是不行)

!!! question "12. 我刚刚发现我的仓库是 Public / Internal, 这会影响评分吗"

    如果没人抄你的小作业, 那无所谓. 否则我们将不得不考虑扣 1 分. (当然, 如果发现了, 那么抄袭的人肯定更惨)

!!! question "11. 我的 corepack 没法换源, 一定要到官方源下载 pnpm, 很慢, 怎么办呢"

    助教也没找到什么好办法. 可以考虑放弃 corepack, 直接用 `npm install -g pnpm` 解决 (?)

    此问题不影响小作业评分. 如果懒得研究可以忽略.

!!! question "10. 我的部署通过了, 但是网页没有更新, 这是为什么呢?"

    首先尝试 Ctrl+F5 刷新以清除浏览器缓存.
    
    其次他*******的 Deployer 即便返回了 0 值也不一定真的部署了. 检查 DEPLOY_ENV, DEPLOY_TOKEN 等环境变量是否设置正确. 助教调试了 4h 才发现这个问题.

!!! question "9. 部署的前端在回放页面刷新会出现 Application error: client-side exception"

    这是 Next.js 的一个 bug，已在更新版本的 Next.js 被修复。由于此问题不影响小作业的完成与评分，你可以忽略此问题。
    
    你可以使用 `pnpm add next` 更新到新版本的 Next.js 来解决此问题。

!!! question "8. 部署的前端在 `/list` 页面刷新会出现 403 Forbidden"

    这是由于代码模板中的 nginx 配置没有考虑周全。由于此问题不影响小作业的完成与评分，你可以忽略此问题。
    
    要解决此问题，你可以将 nginx 配置中 `try_files` 一行改为 `try_files $uri $uri.html $uri/index.html /index.html;`。

!!! question "7. 镜像构建过程或 CI/CD 流程无法正常执行 .sh 脚本"

    由于代码模板仓库中的 `start.sh` 与 `test.sh` 并没有设置执行权限，若你需要在 Docker 构建过程或 CI/CD 流程中执行这两个脚本，请为它们添加可执行权限或是使用 `sh start.sh` 与 `sh test.sh`。

!!! question "6. 小作业部署后 CI/CD 阶段失败，提示“401: Unauthorized operation.Attach token.”"

    请检查项目变量设置中 `DEPLOY_TOKEN` 是否正确设置。没有设置此变量或提供的密钥错误都可能导致此结果。

!!! question "5. 小作业部署后访问提示 502 Bad Gateway 或访问显示 nginx 默认界面"

    先确认 CI / CD 的 Deploy 阶段是否通过. 如果没有通过, 这可能是你没有正确设置变量导致 deployer 没有访问镜像的权限。请检查 `REGISTRY_PWD` 变量的权限是否为 `read_registry` (注意不是 `read_repository`)，并确认项目 CI/CD 中正确添加了变量，包括 `main` 分支是否被保护，以及复制粘贴 token 时是否出现错误，例如在结尾意外加入了空格等。若你无法确定是否正确设置了变量，请尝试重新生成 token 并重新设置变量。

    对于后端小作业，若你是 Windows 用户，则还可能是 `start.sh` 的换行序列是 CRLF 导致的。由于 Docker 容器运行在 Linux 环境下，而 Linux 使用 LF 作为换行序列，这可能导致 `start.sh` 运行失败使得容器无法正常运行。你可以通过将换行序列从 CRLF 改为 LF 来解决此问题。

    然后, 检查你是否监听的是 **80** 端口.

!!! question "4. 前端小作业部署后访问提示 403 Forbidden"

    这可能是你没有正确地导出静态页面文件。请阅读小作业文档中提供的链接了解如何通过 Next.js 导出静态页面文件。你可以在本地先运行对应的指令观察生成的页面文件的位置。

!!! question "3. 后端小作业部署后访问提示 500 Internal Server Error"

    这可能是你没有正确地配置 uWSGI。请阅读小作业文档中提供的链接了解如何通过 uWSGI 部署 Django 应用，并注意需要修改的参数可能不止一处。

!!! question "2. CI/CD build 阶段失败" (Obsolete)
    **【问题】**
    ![build-failed](static/faq/update-template.png)
    <center>构建阶段日志出现如图所示的错误</center>
    **【解决方案】**请按照网络学堂公告提示更新代码模板！相关 commit 信息如下：
    
    + https://git.tsinghua.edu.cn/se-2023spring/2023-django-hw/-/commit/61e9aae7d36e747cacb5aeddc91190d85118f903
    + https://git.tsinghua.edu.cn/se-2023spring/2023-next-hw/-/commit/98e1192ef7bfcfbe025f626c10a25209a726c5e3

!!! question "1. 无权限拉取作业仓库"
    **【问题】**
    ![no-access](static/faq/no-access.png)
    <center>拉取作业 Repo 时出现如图所示的错误</center>
    **【解决方案】**在 Tsinghua Git 上需要首先配置自己的公钥。请查看 `C:\Users\[YourUserName]\.ssh\id_rsa.pub` (Windows 系统) 或 `~/.ssh/id_rsa.pub` (类 Unix 系统) 文件是否存在，若不存在请使用 `ssh-keygen` 命令生成。之后，将该文件的内容添加到 Tsinghua Git 中，你可以使用这个链接：https://git.tsinghua.edu.cn/-/profile/keys 快速导航到公钥添加面板。之后，请重新拉取小作业仓库。