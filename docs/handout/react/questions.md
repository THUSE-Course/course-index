# 实验思考题题面

## Problem 1 (3 pts)

回答下述代码的最终输出内容并作简短的解释：

```typescript
const foo = (x) => x * x;
const bar = (x) => x % 2 === 0;
const arr = [1, 2, 3, 4, 5, 6];
const processed = arr.filter(bar).map(foo);

console.log(processed);
```

## Problem 2 (6 pts)

在初始完毕下述组件后，用户第一次点击按钮并再也不点击，回答点击并等候足够长时间后屏幕上的数字以及控制台输出的数字分别是什么并解释：

```typescript
const ComponentDemo = () => {
    const [value, setValue] = useState(0);

    const foo = () => new Promise((resolve, reject) => setTimeout(resolve, 1));
    const clickCallback = () => {
        foo().then(() => setValue((x) => x + 1));
        console.log(value);
    };

    return <div>
        <p> {value} </p>
        <button onClick={clickCallback}> Click me </button>
    </div>;
};
```

## Problem 3 (15 pts)

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

## Problem 4 (6 pts)

小明是某一家互联网公司的全栈开发工程师，他为公司设计的 JWT 鉴权系统为，将用户名和密码负载在 JWT 上供后端鉴权服务器判断。现在有黑客拦截到了某一条 JWT 信息，但是没能成功获得该 JWT 加密后的签名部分（即第三部分）。请问该黑客有没有成功劫持该 JWT 代表的用户，请说明理由。
