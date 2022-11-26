# TypeScript 初探与游戏逻辑

## 实验目标

通过本 Step，我们希望你能够掌握基本的 TypeScript 语法并且能够使用 TypeScript 语言编写完成康威生命游戏的核心逻辑。

## 实验步骤

之后，你需要在 `src/utils/logic.ts` 文件的函数 `stepBoard` 之中，注释 `// Step 1 BEGIN` 与 `// Step 1 END` 之间的部分填充你的代码，编写完成康威生命游戏的核心逻辑。注意，请勿改动其余部分的代码，请勿新建文件、删除文件。

在编写完成后，你可以在项目根目录下，运行命令 `yarn test logic` 执行我们编写好的单元测试，如果显示下述提示信息则代表你完成了 Step 1：

![](../../static/react/step1-test-pass.png)

如果你在编写游戏的核心逻辑上遇到了困难，可以打开 `test/logic.test.ts` 文件，其中的 `stepBoardGT` 函数是我们提供的样例实现，可供参考。但我们保留因认定为抄袭参考代码而将本 Step 评为零分的权利。

### 代码说明

在 `src/utils/logic.ts` 文件的前两行，我们规定了棋盘尺寸以及表示棋盘的类型如下：

```typescript
export const BOARD_LENGTH = 50;
export type Board = (0 | 1)[][];
```

这说明我们使用一个二维数组表示棋盘，二维数组中的每一个元素代表一个细胞，元素的取值为 `0` 或者 `1`，分别代表细胞死亡与细胞存活。

你需要填充的 `stepBoard` 函数接收一个 `Board` 类型的参数 `board`，其表示这个时刻的棋盘状态。该函数的返回值为 `Board` 类型，其表示下一时刻的棋盘状态。

## 实验评分

本 Step 总分为 10 分。

本 Step 采用自动化评分。我们会检查 Tsinghua Git CI 中是否如下显示本 Step 的通过信息。若有，则你获得本 Step 所有分数：

【TODO：CI 通过界面】

我们保证 CI 判定通过的方式与你本地完全一致（即通过 `yarn test logic` 命令判定）。

## 知识讲解

这里我们会简单讲解 TypeScript 的语法。

【TODO：讲解 TypeScript】