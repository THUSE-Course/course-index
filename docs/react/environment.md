# 环境配置

!!! note "时效性文档"

    本文档是具有时效性的文档，为了保证内容准确应当保持更新。

    本文档的最后更新时间在页面最底部。

为了能够在本地正确运行我们下发的代码，请你按照本 Step 配置本地环境。

在配置环境中遇到问题，请首先检查这一问题是否已经在 FAQ 部分提出。如果这一问题并未出现在 FAQ 或者 FAQ 中提供的解决方案并不能解决问题，请在微信群或者网络学堂中提出。

---

本文档截图均基于 Mac 系统与 Safari 浏览器。

## Node.js

Node.js 是服务器端运行 JavaScript 的环境，我们需要在本地配置 Node.js 环境以运行我们的前端代码。

对 Node.js 更为细节的介绍参考计算机系学生科协技能引导文档 <https://docs.net9.org/languages/node.js/>。

可以通过 [Node.js 官方中文网站](https://nodejs.org/zh-cn/) 下载并安装 Node.js，我们推荐下载**长期维护版本（Long Time Support）**，LTS 版本相较于最新版本往往更为稳定。

另外，为了获取更详细的安装指导，我们推荐获取安装包而非二进制文件，下载安装包后打开即可安装。

为了确认是否正确安装，可以打开终端，输入指令 `node -v` 确认：

![](/static/react/step0-node.png)

## yarn

Node.js 下载后会自带有包管理工具 npm 用于管理项目内所用到的第三方依赖。这里我们更推荐使用 yarn 作为后续开发的包管理工具，因为 yarn 相对于 npm 具有更快的下载速度、更清晰的命令行输出。

安装 yarn 时，你首先需要确定 npm 已经安装完毕，只需要通过 `npm -v` 确认：

![](/static/react/step0-npm.png)

之后运行指令 `npm install -g yarn` 即可安装 yarn，随后可以通过指令 `yarn -v` 来确认是否安装成功（这里如果遇到了读写权限问题，可能需要切换到管理员模式，Mac 与 Linux 系统上可以直接在指令前加 `sudo`，Windows 系统上则应在打开终端时选择“以管理员身份运行”）：

![](/static/react/step0-yarn.png)

## TypeScript

TypeScript 是 JavaScript 的超集，可以将其简单理解为带有类型标注的 JavaScript。TypeScript 的编译器会在编译时检查变量类型是否满足标注要求，若满足则会编译生成 JavaScript 代码。

可以通过 yarn 安装 TypeScript，指令为 `yarn global add typescript`。

为了确定 TypeScript 是否正确安装，可以需要通过 `tsc -v` 确认：

![](/static/react/step0-ts.png)

## 本项目的配置

在配置完最基本的环境后，下一步可以将本次小作业 `git clone` 到本地，进入该项目的根目录作最后的配置。

下面我们简单讲解 yarn 的使用方法：

```shell
yarn install # 自动安装依赖
yarn add lodash # 添加名为 lodash 的依赖
yarn add -D lodash # 添加开发环境下名为 lodash 的依赖（即生产环境下不使用该依赖）
yarn remove lodash # 删除名为 lodash 的依赖
yarn start # 运行名为 start 的脚本
```

而 yarn 如何确定怎么自动安装依赖或者应当运行什么样的脚本，均会在项目根目录下 `package.json` 文件内定义。本次小作业的 `package.json` 文件节选为：

```json
{
    "name": "conway-game",
    // ...
    "scripts": {
        // ...
        "fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
        // ...
    },
    "dependencies": {
        "axios": "^1.2.0",
        // ...
    },
    "devDependencies": {
        "@testing-library/jest-dom": "^5.14.1",
        // ...
    }
}
```

其中 `dependencies` 与 `devDependencies` 字段定义了本项目所有的依赖名称以及版本要求，在本项目根目录下运行 `yarn install` 即会安装这里所列举的所有依赖。

另外，`scripts` 字段定义了所有可以运行的脚本，这里运行 `yarn fix` 相当于运行 `eslint src --ext .js,.jsx,.ts,.tsx --fix`。

---

在配置好 yarn 的基础上，现在运行 `yarn install` 安装第三方依赖。本次小作业不需要额外安装其他第三方依赖即可完成：

![](/static/react/step0-yarn-install.png)

所有的第三方依赖将会安装在 `node_modules` 目录下，该目录应当已经被 `.gitignore` 忽略。

!!! warning "黑洞"

    `node_modules` 是一个文件结构十分复杂且庞大的文件夹，并且随着依赖迭代更新和包管理工具对其的维护，其内部的结构变动十分频繁，所以该目录非常不利于文件系统管理，故戏称为“黑洞”。

    另外，**切记在 `.gitignore` 内忽略该目录**，否则软工大作业刚开始一周内就在仓库里写了十几万行代码的，就有可能是你的小组。

之后，运行 `yarn dev` 启动本次项目：

![](/static/react/step0-yarn-dev.png)

项目启动后应当能在本地端口上访问到前端页面，默认端口号为 3000。上述截图中因为默认端口 3000 被占用，故采用了 3001 端口。

打开浏览器并在地址栏输入 `http://localhost:3000`（默认端口占用时需要替换端口号），即可访问到本次小作业前端页面。若能够看到类似于下图的界面，就说明环境配置完成，可以完成小作业了🎉：

![](/static/react/step0-final.png)
