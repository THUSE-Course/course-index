# React (Next.js) 前端小作业文档

## 作业目标

本作业目标为使用基于 TypeScript 语言的 React (Next.js) 框架实现 Web 前端。本作业中所完成的 Web 前端，应当可以与后端小作业中所完成的 Django 后端对接，完整构成一个带有记录管理功能的康威生命游戏。

??? note "什么是 Next.js"

    Next.js 是基于 React 的一个更高层的框架，相对于原生 React，其提供了更为方便的路由配置、更简单的 SSR 等相关优化。

    另外，Next.js 可以通过增添 API 路由来实现语法类似于 Express 的后端。事实上，在命制本次小作业时，我们已经基于 Next.js 后端，通过 Prisma 数据库 API 和 SQLite 数据库实现了和使用 Django 功能近似的参考后端。学有余力的同学可以尝试。

    参考资料：

    - 计算机系学生科协技能引导文档 <https://docs.net9.org/backend/expressjs/express-js/>
    - Next.js 官方中文文档 <https://www.nextjs.cn>
    - Prisma 官方文档 <https://www.prisma.io>

## 代码地址

前端小作业代码框架地址为 <https://git.tsinghua.edu.cn/se-2026spring/2026-next-hw/>。

## 使用说明

本作业需要在 SECoder Gitlab 平台开发、提交代码，并按照指定方式部署到指定地址。建议你以**作业截止时间前主分支上最后一次 commit 以及最后一次部署活动**为基准进行自检。

需要注意的是，我们在每个 Step 的文档以及下发代码中均对你能够修改的部分作出了限定，我们确定**仅在限定范围内修改代码能够完成小作业所有要求**。然而，由于可能存在我们也没能考虑完备的实现方案，我们并不强制你仅能修改限定范围内的代码。

我们还提供了若干实验思考题供同学们拓展思考，具体题面与提交方式见后续文档。

## 文档结构

每一个 Step 的文档都包含有下述部分：

- 实验目标。介绍本 Step 需要实现的功能
- 实验步骤。介绍完成本 Step 所需要的步骤
- 自测检查。介绍完成本 Step 后建议核对的功能点
- 知识讲解。**简单**讲解本 Step 中你需要掌握的知识，如果你已经掌握，则可以跳过这一部分

## 参考资料

!!! warning "虽然给你提供了知识讲解..."

    虽然每个 Step 都提供了知识讲解部分作简单介绍，但限于篇幅并不能深入讲解。为了更好地掌握，我们依然建议你通过完整的文档成体系地学习 React (Next.js) 框架，文档见下。

- React 框架官方中文文档 <https://react.docschina.org/>
- 计算机系学生科协技能引导文档 <https://docs.net9.org/frontend/react/>
