# 实验思考题题面

## Problem 1 (4 pts)

说明函数 `f1, f2, f3, f4` 的返回值类型。

```typescript
const foo = () => 0;

const f1 = () => foo();
const f2 = () => { foo(); }
const f3 = () => { return foo(); }
const f4 = async () => foo();
```

## Problem 2 (2 pts)

阅读下述代码：

```typescript
interface A {
    foo: () => void;
    foobar: () => void;
}

interface B {
    foo: () => void;
    barfoo: () => void;
}

const bar = (x: A | B): number => {
    if (x instanceof A) {
        return 0;
    }

    x.barfoo();
    return 1;
};
```

这段代码 TypeScript 是否会报编译错误？请说明原因。

## Problem 3 (4 pts)

阅读框架中 `src/pages/index.tsx` 中的代码：

```typescript
id !== undefined && (
    <button onClick={() => setBoard(initBoard)} disabled={autoPlay}>
        Undo all changes
    </button>
)
```

这句语句使得 Free Mode 下 Undo all changes 按钮不被渲染，请解释该写法的工作原理。

## Problem 4 (2 pts)

在 Step 3 中我们提供了 `flipCell` 的一个错误实现 `badFlipCell`，请简述其错误的原因。

## Problem 5 (10 pts)

阅读框架中 `src/pages/index.tsx` 中的代码：

```typescript
useEffect(() => {
    if (id === undefined) {
        dispatch(resetBoardCache());
    }

    return () => {
        if (id === undefined) {
            dispatch(setBoardCache(board));
        }
    };
}, [board, id, dispatch]);
```

回答：

- 分析 `setBoardCache` 和 `resetBoardCache` 这两个 Redux Reducer 的调用时机
- 分析这个 `useEffect` Hook 所完成的功能（可以描述一个用户故事，说明这个 Hook 起到了什么样的作用）

## Problem 6 (4 pts)

小明是某一家互联网公司的全栈开发工程师，他为公司设计的 JWT 鉴权系统为，将用户名和密码负载在 JWT 上供后端鉴权服务器判断。现在有黑客拦截到了某一条 JWT 信息，但是没能成功获得该 JWT 加密后的签名部分（即第三部分）。请问该黑客有没有成功劫持该 JWT 代表的用户，请说明理由。

## Problem 7 (4 pts)

小作业框架中 `next.config.js` 中有下述函数：

```javascript
async function rewrites() {
    return [{
        source: "/api/:path*",
        destination: "http://127.0.0.1:8001/:path*",
    }];
}
```

请分别叙述 `source, destination` 字段的含义，并简要叙述该函数的作用。
