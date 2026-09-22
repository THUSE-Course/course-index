# SECoder

SECoder 是本课程使用的开发与部署平台。平台入口为
[https://t.secoder.net](https://t.secoder.net)，需要在校园网环境中访问。

完整的学生手册可从以下任一地址打开：

- 校内：[https://man.t.secoder.net](https://man.t.secoder.net)
- GitHub Pages：[https://thuse-course.github.io/man/](https://thuse-course.github.io/man/)

## 激活账号

1. 使用助教提供的初始密码打开
   [SECoder 注册页面](https://t.secoder.net/register)。
2. 使用学号作为账号，填写姓名、常用邮箱和初始密码。
3. 注册完成后使用学号和密码登录。
4. 首次登录后应立即检查个人资料，并妥善设置自己的密码。

![SECoder 注册页面](https://man.t.secoder.net/assets/register-pc.png)

如果页面无法打开，请先确认设备已经接入校园网。忘记密码、初始密码无效或账号被禁用时，联系课程助教处理。

## 平台提供的服务

登录后的概览页面集中提供课程所需的服务入口：

|服务|用途|地址|
|-|-|-|
|SECoder|账号、组队与 Kubernetes 凭据管理|[t.secoder.net](https://t.secoder.net)|
|GitLab|代码仓库、Merge Request、Container Registry 与 CI/CD|[gitlab.t.secoder.net](https://gitlab.t.secoder.net)|
|SonarQube|代码质量与安全分析|[sonar.t.secoder.net](https://sonar.t.secoder.net)|
|Headlamp|查看 Kubernetes 资源、日志和资源用量|[headlamp.t.secoder.net](https://headlamp.t.secoder.net)|
|Grafana|查看应用和集群的历史监控数据|[grafana.t.secoder.net](https://grafana.t.secoder.net)|

![SECoder 概览页面](https://man.t.secoder.net/assets/overview-desktop-01.png)

## 激活 GitLab

GitLab 使用 SECoder 账号进行单点登录，不需要单独注册：

1. 在 SECoder 概览页面点击 **GitLab 代码仓库和 CI/CD**。
2. 在 GitLab 登录页选择 **secoder**。
3. 在授权页确认账号、姓名和邮箱，然后继续前往 GitLab。
4. 返回 SECoder 的 **个人资料** 页面，点击 **同步 GitLab 子组**。

首次使用、加入新小组或小组成员发生变化后，都应重新执行一次子组同步。修改姓名或邮箱后，需要重新登录 GitLab 才会同步新信息。

## 命名空间

Kubernetes 使用 Namespace 隔离不同用户和小组的资源：

- 个人命名空间：`u-<学号>`，用于个人小作业和实验。
- 小组命名空间：由课程组分配，用于团队项目。

小作业文档中的 `NAMESPACE` 指个人命名空间。例如学号为 `2026000000` 时：

```text
NAMESPACE=u-2026000000
```

Deployment、Service、Secret、PVC 等资源都必须创建在自己的命名空间中。不要在配置中写其他同学或小组的命名空间。

## Kubernetes 凭据

SECoder **个人资料**页面提供两种 Kubernetes 凭据：

- **API 令牌**：用于 GitLab CI/CD 中的 `TOKEN` 变量。
- **kubectl 配置**：用于在自己的计算机上运行 `kubectl`。

![下载 kubectl 配置](https://man.t.secoder.net/assets/profile-desktop-05.png)

这两者访问的是 Kubernetes API，不是 SECoder 网页的登录令牌。令牌或 kubeconfig 泄露后，应立即在个人资料页面轮换令牌；旧令牌、旧 kubeconfig 和使用旧令牌的 CI 作业会同时失效。

!!! warning "保护凭据"

    - 不要把 API 令牌或 kubeconfig 提交到 Git 仓库。
    - CI/CD 中的 `TOKEN` 和 Registry Token 必须设置为 Masked。
    - 不要在作业日志、截图或答疑消息中粘贴凭据。
    - kubeconfig 下载后应设置为仅自己可读，例如 `chmod 600 u-*.kubeconfig`。

kubectl 的安装、配置和常用命令见 [kubectl 使用指南](kubectl.md)，完整部署流程见 [Kubernetes 部署](deployer.md)。
