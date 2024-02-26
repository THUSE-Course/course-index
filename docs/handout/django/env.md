# 环境配置

我们使用类Unix系统来完成本作业的环境配置。不推荐使用Windows系统完成下述设置，如果为Windows用户，建议安装 WSL2。

## GitLab 公钥配置

首先确保你的系统已经安装了SSH客户端。大部分Linux发行版和macOS已预装SSH客户端。Windows用户可以安装Git Bash或使用Windows 10及更高版本的内置SSH客户端。

**首先，你应该检查是否已经有了SSH密钥对，如果没有则需要生成。**

1. 打开一个终端窗口。
2. 输入 `cd ~/.ssh`进入SSH目录。
3. 使用 `ls`命令查找 `id_rsa`（私钥）和 `id_rsa.pub`（公钥）文件。如果这些文件存在，说明你已经有了SSH密钥对，无需重新生成。

如果经过上述检查，你没有现成的SSH密钥对，可以按照以下步骤生成一个新的密钥对：

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- `-t rsa` 指定密钥类型为RSA。
- `-b 4096` 指定密钥长度为4096位，以提高安全性。
- `-C "your_email@example.com"` 为密钥添加一个注释，通常使用你的邮箱地址。

按照提示操作，你可以为密钥设置一个密码（也称为"passphrase"，之后每次尝试使用私钥验证时均需提供），也可以直接按Enter键跳过，创建一个没有密码的密钥。密钥对将生成在 `~/.ssh`目录下，私钥文件为 `id_rsa`，公钥文件为 `id_rsa.pub`。

**然后，我们把公钥配置在远端 GitLab 上，以供我们的身份验证。**

一旦你有了SSH密钥对，下一步是将公钥添加到你的GitLab账户中。这样做可以让GitLab识别你的计算机，从而允许安全的代码推送和拉取操作，而无需每次都输入用户名和密码。

使用你的用户名和密码登录到 GitLab。（注意本教程作业位于 Tsinghua Git 上，而我们之后的课程大作业将位于 SECoder Git 上，这是两个不同的 Git 源，需要分别配置公钥）

登录后，选择“Edit Profile”（设置）。在左侧菜单中，选择“SSH Keys”（SSH密钥），然后选择“Add new key”。

在“Key”（密钥）文本框中，粘贴你的SSH公钥。在“Title”（标题）字段中，为你的密钥添加一个描述性标题，帮助你记住这个密钥是用于哪台计算机或什么目的。然后点击“Add key”（添加密钥）。

完成以上步骤后，你就成功将你的SSH公钥添加到了GitLab，现在你可以通过SSH安全地连接到GitLab，进行代码的推送、拉取等操作了，而无需每次操作时都输入用户名和密码。

## 配置后端代码运行的虚拟环境 Conda Environment

虚拟环境是一个独立的、隔离的目录树，允许Python用户和开发者在不同的项目之间维护**隔离的开发环境**。通过使用虚拟环境，你可以为每个项目安装不同版本的包和Python本身，而不必担心这些安装会相互冲突或影响到系统级的Python安装。这种隔离性是虚拟环境的核心优势，有助于保证项目的依赖关系清晰和一致，从而使得项目更容易被其他人理解、使用和维护。

Miniconda是一个轻量级的Anaconda发行版，它包括了conda、Python、以及少数必要的库。相比于完整的Anaconda发行版，Miniconda提供了一个更为简洁、灵活的方式来管理Python虚拟环境和下属的包。

首先，我们下载并安装 Miniconda。

前往 Miniconda 官网 https://docs.anaconda.com/free/miniconda/index.html，选择 Miniconda3 Linux 64-bit 即可进行下载，复制其下载链接后，可在终端键入：

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

即可进行下载。下载完成后，输入下述命令进行安装。（注意这里前面添加了sudo，是为root用户安装）

```bash
sudo bash Miniconda3-latest-Linux-x86_64.sh
```

然后一直回车，同意协议。选取合适的安装位置后（可使用默认，请记住该位置）开始解包，解包完成后选择同意初始化并添加环境变量。

之后输入 `</path/to/installed/conda>/bin/conda init <bash/当前你用的shell>` ，给 当前用户 设置环境变量。

然后重启终端，或使用 `source ~/.bashrc` 刷新环境变量。这时发现终端 prompt 输入的前面就会有一个(base)，代表激活了base(默认)环境，安装完成。

常用的conda命令：

```bash
# 创建虚拟环境
conda create -n <env_name> [python_version]

# 删除虚拟环境
conda remove -n <env_name>

# 激活虚拟环境
conda activate <env_name> 

# 退出虚拟环境(进入环境状态下才可使用)
conda deactivate 

# 查看虚拟环境列表
conda env list
```

这时我们可以开始配置我们的虚拟环境。按照文档要求，我们使用 `Python=3.9` 配置本次作业：

```bash
conda create -n django_hw python=3.9 -y
conda activate django_hw
```

然后，我们克隆作业仓库：

```bash
git clone <后端教程地址/请参考最新版文档>
```

之后我们使用 `cd` 命令进入新克隆的作业仓库，仓库中应该有 `requirements.txt`。在此环境的基础之上，你可以运行下述命令安装依赖：

```bash
pip install -r requirements.txt
```

如果下载过慢，请参考 https://mirrors.tuna.tsinghua.edu.cn/help/pypi/ 将PyPI设为默认源。这时教程作业环境配置已完成，可以按照教程作业的指引检查环境配置是否成功。
