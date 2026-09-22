# 课程小作业

本次课程小作业分为 CI/CD、后端（Django 或 FastAPI）和前端（Next.js）三部分，目标是帮助大家熟悉前后端开发、容器构建、自动化测试与 Kubernetes 部署。本课程小作业覆盖了大作业常用的基本技术，代码框架也可以作为后续项目的参考。

!!! note "小作业为可选练习"

    本学期小作业不计入课程成绩，仅供同学们练习使用。建议亲自完成环境配置、测试和部署过程，不要只以生成代码能够运行为目标。

## 使用上学期的代码仓库

2026 秋季继续使用 2026 春季发布的小作业代码框架：

- 前端：[2026-next-hw](https://git.tsinghua.edu.cn/se-2026spring/2026-next-hw)
- 后端：[2026-django-hw](https://git.tsinghua.edu.cn/se-2026spring/2026-django-hw)

这些仓库提供业务代码和 TODO 框架；部署部分以本网站当前文档为准。

前端项目名使用 `2026-Next-HW`，后端项目名使用 `2026-Django-HW`。

## 推荐顺序

1. 阅读[需求文档](requirement.md)和 [API 文档](api.md)。
2. 在本地完成后端并运行测试。
3. 在本地完成前端并运行测试。
4. 阅读 [SECoder](../deploy/secoder.md)、[kubectl](../deploy/kubectl.md)和
   [Kubernetes 部署](../deploy/deployer.md)。
5. 将前后端项目推送到 SECoder GitLab，配置 CI/CD 并完成部署。

## 获取和推送代码

先从 Tsinghua Git 克隆代码：

```bash
git clone https://git.tsinghua.edu.cn/se-2026spring/2026-next-hw.git
git clone https://git.tsinghua.edu.cn/se-2026spring/2026-django-hw.git
```

然后完成以下准备：

1. 在 [SECoder](https://t.secoder.net) 激活账号。
2. 通过 SECoder 登录 [GitLab](https://gitlab.t.secoder.net)，并在个人资料页面执行一次 **同步 GitLab 子组**。
3. 在自己的 GitLab 命名空间中创建 `2026-Next-HW` 和 `2026-Django-HW` 项目。
4. 将项目的 Git remote 指向新建的 GitLab 仓库并推送默认分支。
5. 按 [CI/CD 小作业文档](ci-cd/index.md)配置 Kubernetes 与 Registry 凭据。

添加远程仓库时，以 GitLab 项目页面给出的地址为准。例如：

```bash
git remote rename origin upstream
git remote add origin <SECoder GitLab 项目地址>
git push -u origin main
```

如果默认分支不是 `main`，请使用仓库实际的默认分支名。

若课程组更新代码框架，会另行发布公告。此时可以从 `upstream` 获取更新，再通过 merge 或 rebase 将其整合到自己的分支中。

!!! note "Git 教程"

    小作业使用 Git 管理和提交代码。可以通过[技能引导文档](https://docs.net9.org/basic/git/)学习 Git 基础。

## 答疑说明

你可以在课程微信群或网络学堂讨论区提问。提问前请先完整阅读小作业文档和 [FAQ](../faq.md)，并提供：

- 执行的命令或操作步骤；
- 完整且已隐藏凭据的错误信息；
- 已经尝试的排查方法；
- 对问题所在阶段的判断。

不要在提问中发送 SECoder 密码、GitLab Token、Kubernetes API 令牌或 kubeconfig。
