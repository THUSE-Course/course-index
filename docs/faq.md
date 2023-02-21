# FAQ

本部分将收集微信群与网络学堂中提问较多、有价值的问题。



!!! question "1. 无权限拉取作业仓库"
    **【问题】**
    ![no-access](static/faq/no-access.png)
    <center>拉取作业 Repo 时出现如图所示的错误</center>
    **【解决方案】**在 Tsinghua Git 上需要首先配置自己的公钥。请查看 `C:\Users\[YourUserName]\.ssh\id_rsa.pub` (Windows 系统) 或 `~/.ssh/id_rsa.pub` (类 Unix 系统) 文件是否存在，若不存在请使用 `ssh-keygen` 命令生成。之后，将该文件的内容添加到 Tsinghua Git 中，你可以使用这个链接：https://git.tsinghua.edu.cn/-/profile/keys 快速导航到公钥添加面板。之后，请重新拉取小作业仓库。