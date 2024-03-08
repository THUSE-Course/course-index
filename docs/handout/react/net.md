# 网络请求

## 实验目的

通过本 Step，我们希望你能够掌握如何发送和处理网络请求，从而完成整个小作业的前端。

## 实验步骤

首先，你需要在理解 JavaScript 的异步与 then 链语法的基础上，了解如何创建一个网络请求并按照 API 文档要求携带参数。

之后，你需要在文件 `src/pages/list.tsx` 中的 `ListScreen` 组件内完成一处代码填空，完成网络请求的发送和处理。该填空位于函数 `deleteBoard` 中，该函数用于删除指定的游戏记录。本处填空的代码量在 20 行以内。该函数应当绑定在每一条游戏列表的 Delete it 按钮上，用于处理用户的点击行为。

完成本 Step 后，你的游戏记录列表的交互应当和下述 GIF 图所展示的类似：

![](../../static/react/step6-demo.gif)

### 代码说明

事实上在 Step 4 中你已经接触过本小作业框架所使用的通用网络请求函数，你可以再次通读该函数，理解其工作原理。另外，本小作业框架中我们已经使用该函数写过多个网络请求处理函数，你可以参考这些代码来完成本 Step。

## 知识讲解

由于本 Step 所涉及的技术要点基本都有成熟的文档介绍，这里直接引用参考文档链接。

最基本的 JS/TS 语言异步语法（包含 then 链语法）可以参考 [技能引导文档相关页面](https://docs.net9.org/languages/javascript/async/)。

函数组件中的网络请求往往需要使用 `useEffect` Hook 管理。`useEffect` Hook 的使用方法可以参考 [技能引导文档相关页面](https://docs.net9.org/frontend/react/function-component/#_3)。