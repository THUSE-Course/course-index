# 部署基础

本分类介绍在 SECoder 上构建、部署和排查应用所需的基础知识。建议按以下顺序阅读：

1. [Docker](docker.md)：把应用及其运行环境构建成容器镜像。
2. [SECoder](secoder.md)：激活账号、GitLab 和 Kubernetes 凭据。
3. [kubectl](kubectl.md)：查看集群资源、日志和发布状态。
4. [Kubernetes 部署](deployer.md)：编写资源清单并通过 CI/CD 发布应用。
5. [GitLab CI/CD](gitlab-ci.md)：理解流水线、作业、变量与测试报告。
6. [SonarQube](sonarqube.md)：查看代码质量与安全分析结果。

课程项目的正常发布入口是 GitLab CI/CD。Headlamp 和 kubectl 用于观察资源、定位错误，以及在有明确目的时进行调试或恢复。
