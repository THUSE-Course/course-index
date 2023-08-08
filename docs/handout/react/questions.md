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

## Problem 2 (6 pts)

阅读框架中 `src/pages/index.tsx` 中的代码：

```typescript
id !== undefined && (
    <button onClick={() => setBoard(initBoard)} disabled={autoPlay}>
        Undo all changes
    </button>
)
```

这句语句使得 Free Mode 下 Undo all changes 按钮不被渲染，请解释该写法的工作原理。

## Problem 3 (10 pts)

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

- 解释 Redux 存储中 `src/redux/board.ts` 切片设计的目的
- 解释上述代码中 `useEffect` Hook 是如何维护该切片的数据并达到目的的

## Problem 4 (10 pts)

【TODO】