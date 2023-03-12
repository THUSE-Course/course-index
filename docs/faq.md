# FAQ

本部分将收集微信群与网络学堂中提问较多、有价值的问题。

!!! question "5. 小作业部署后访问提示 502 Bad Gateway"

    这可能是你没有正确设置变量导致 deployer 没有访问镜像的权限。请检查 `REGISTRY_PWD` 变量的权限是否为 `read_registry` (注意不是 `read_repository`)，并确认项目 CI/CD 中正确添加了变量，包括 `master` 分支是否被保护，以及复制粘贴 token 时是否出现错误，例如在结尾意外加入了空格等。

!!! question "4. 前端小作业部署后访问提示 403 Forbidden"

    这可能是你没有正确地导出静态页面文件。请阅读小作业文档中提供的链接了解如何通过 Next.js 导出静态页面文件。

!!! question "3. 后端小作业部署后访问提示 500 Internal Server Error"

    这可能是你没有正确地配置 uWSGI。请阅读小作业文档中提供的链接了解如何通过 uWSGI 部署 Django 应用，并注意需要修改的参数可能不止一处。

!!! question "2. CI/CD build 阶段失败"
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