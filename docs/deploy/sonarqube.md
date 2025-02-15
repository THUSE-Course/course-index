# SonarQube

SonarQube 是一个自动代码评审工具，能够对代码进行静态分析并发现潜在的问题。SECoder 使用 SonarQube 对源代码和测试报告进行分析。

## `sonar-project.properties`

在 [GitLab CI/CD](../gitlab-ci) 文档中，我们在执行完测试之后运行了 SonarScanner。SonarScanner 会从根目录下的 `sonar-project.properties` 读取项目配置，进行代码分析后将结果上传到 SECoder 平台。不同语言项目的配置也不尽相同，这里我们以 Python 的配置为例讲解基本的配置项目。

```properties
sonar.inclusions=app/**/*,tests/**/*

sonar.python.coverage.reportPaths=coverage-reports/coverage.xml
sonar.python.xunit.reportPath=xunit-reports/xunit-result.xml

sonar.coverage.exclusions=tests/**/*
```

### 需要分析的代码

我们可以通过 `inclusions` 指定需要分析的代码。这一项是一个逗号分隔的路径列表，允许使用 `*` 和 `**` 通配符，其中 `**` 代表任意层级的目录。

在这里，我们通过 `inclusions` 指定了代码分析需要包含 `app` 和 `tests` 以及它们的子目录下的所有文件。不在其中的代码将不会被 SonarQube 检查。一般来说，我们会将所有自己编写的代码 (包括测试代码) 纳入分析，而将框架生成的代码和第三方库如 Django 生成的项目框架、`node_modules` 等排除在分析外。

此外，我们也可以使用 `exclusions` 指明需要排除的代码。默认情况下，整个项目目录都会被纳入分析，因此只指定 `exclusions` 时将会分析除了 `exclusions` 外的所有其他代码。

### 测试报告

测试报告分为两部分：测试覆盖率报告和测试执行报告。测试覆盖率报告检查被测试了的源代码占所有源代码的比例，并分析哪些代码还没有被测试覆盖。测试执行报告则会具体地给出每一个测试的执行结果。

接下来我们指定测试报告路径。`python.coverage.reportPaths` 指定了测试覆盖率报告的路径，在这里即我们在 [GitLab CI/CD](../gitlab-ci) 文档中使用 `coverage` 命令生成的报告。`python.xunit.reportPath` 指定测试执行报告的路径，在这里即我们在 [GitLab CI/CD](../gitlab-ci) 文档中使用 `coverage` 命令运行 `pytest` 测试时指定的报告路径。

最后，由于我们不会要求测试代码也被测试覆盖 (套娃)，我们将测试代码排除在覆盖率计算之外。

!!! note "其他语言的配置"

    你可以在 [Test Coverage & Execution](https://sonarqube.secoder.net/documentation/analysis/coverage/) 查看每种语言的测试报告如何配置。

## SonarQube 平台

在代码分析完毕后，我们就可以在 SECoder 的 [SonarQube](https://sonarqube.secoder.net/) 平台上查看代码分析结果了。下面是一个示例：

![SonarQube Project](../static/sonarqube.png)

我们可以进入项目来查看更详细的分析，这些分析有助于你更好地开发出符合软件工程规范的应用。

### 代码异味 (Code Smell)

代码异味指不符合开发规范，可能带来潜在问题的代码。例如，过于庞大复杂的函数、多次重复的代码段或魔法数字、空的代码块等等都可能造成代码异味。SonarQube 会为每个代码异味评估风险等级以及预计修复时间，可以在 SonarQube 平台上检查这些代码异味并进行解决。

!!! tip "可以手动确认并忽略 SonarQube 认定的代码异味"

    如果确认某些被认定的代码异味有其存在的必要 / 是 SonarQube 误判了, 则可以手动确认并忽略这些异味. 但 **这并不意味着你可以通过这种方式逃避检查**.

    安全热点也同理.

### 安全热点 (Security Hotspot)

SonarQube 会检查项目中潜在的安全问题，例如 SQL 注入、拒绝服务攻击 (DoS) 以及跨站请求伪造 (CSRF) 等。SonarQube 会指出可能带来隐患的代码，解释为什么这是有风险的，并提供可能的解决方案。

### 统计

在统计界面可以查看项目的各种数据，包括测试覆盖率、代码重复率、代码复杂度 (圈复杂度和认知复杂度) 等。SonarQube 会基于各种数据对项目的可靠性、安全性、可维护性进行评估，在开发过程中可以参考这些数据改进项目的开发流程。

## 参考资料

你可以在 [SonarQube Documentation](https://sonarqube.secoder.net/documentation) 更详细地学习 SonarQube 的使用方法。SonarScanner 更具体的配置方法可以在 [Analyzing Source Code](https://sonarqube.secoder.net/documentation/analysis/overview/) 一节中找到。

在本课程提供的[样例项目](https://git.tsinghua.edu.cn/SEG/example)仓库中也可以找到几种常见项目框架的 SonarQube 配置，可供配置部署时参考。需要注意的是，这些样例项目都较为老旧，请在参考时注意版本和兼容性等问题。