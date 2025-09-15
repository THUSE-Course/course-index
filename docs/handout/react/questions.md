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

阅读下述简易并发控制 wrapper 的代码：

```typescript
import { Mutex } from 'async-mutex';

const MAX_CONCURRENCY = {
    ["QwenVLMax"]: 20,
    // ...
} as const;
type ConcurrencyLimitGroup = keyof typeof MAX_CONCURRENCY;
const concurrencyLimitGroups = Object.fromEntries(
    Object
        .entries(MAX_CONCURRENCY)
        .map(([group, limit]) => [group, Array(limit).fill(0).map((_, idx) => Promise.resolve(idx))]),
) as Record<ConcurrencyLimitGroup, Promise<number>[]>;
const mutexes = Object.fromEntries(
    Object
        .entries(MAX_CONCURRENCY)
        .map(([group]) => [group, new Mutex()]),
) as Record<ConcurrencyLimitGroup, Mutex>;
const runWithConcurrencyLimit = async <T>(group: ConcurrencyLimitGroup, task: () => Promise<T>) => {
    const mutex = mutexes[group];
    await mutex.acquire();
    const concurrencyLimitGroup = concurrencyLimitGroups[group];
    const idx = await Promise.race(concurrencyLimitGroup);
    const promise = task();
    concurrencyLimitGroup[idx] = /* TODO */;
    mutex.release();
    return promise;
};

export default runWithConcurrencyLimit;
```

这一 wrapper 的功能是接受异步任务，并按照各个控制组所设定的最大并发数量控制并发。

(1) 通过查阅 API 文档或者利用 LLM 等方式了解 `Promise.race`，叙述 `idx` 表示的是什么意思。

(2) 在 `TODO` 处填写合适的代码完成 wrapper 的实现。

(3) 如果去除掉 `mutex` 锁，可能会导致什么问题？

## Problem 4 (6 pts)

小明是某一家互联网公司的全栈开发工程师，他为公司设计的 JWT 鉴权系统为，将用户名和密码负载在 JWT 上供后端鉴权服务器判断。现在有黑客拦截到了某一条 JWT 信息，但是没能成功获得该 JWT 加密后的签名部分（即第三部分）。请问该黑客有没有成功劫持该 JWT 代表的用户，请说明理由。
