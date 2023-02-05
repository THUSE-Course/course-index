# 实验思考题题面

## Problem 1 (2 pts)

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

## Problem 2 (2 pts)

在 Step 3 中我们提供了 `flipCell` 的一个错误实现 `badFlipCell`，请简述其错误的原因。

## Problem 3 (4 pts)

在 Next.js 框架中，`pages` 目录结构如下所示，各个 `.tsx` 文件使用 `export default` 方式导出的 React 组件写在括号内。请分别回答在浏览器访问下述地址的时候，浏览器所要渲染的组件名称。若没有符合条件的组件，回答 404 Not Found。

```text
pages
├── _app.tsx (App)
├── index.tsx (IndexScreen)
├── basic.tsx (BasicScreen)
├── info
│   ├── index.tsx (InfoIndexScreen)
│   └── [id]
│       ├── abstract.tsx (InfoAbstractScreen)
│       └── detail.tsx (InfoDetailScreen)
└── settings.tsx (SettingsScreen)
```

地址列表：

- `/`
- `/_app`
- `/my`
- `/info/index`
- `/info/5/detail`
- `/info/index/abstract`

## Problem 4 (8 pts)

在小作业框架中，文件 `src/pages/[id].tsx` 内有这样一段代码：

```typescript
const router = useRouter();
const query = router.query;

useEffect(() => {
    if (!router.isReady) {
        return;
    }

    // Use router.query to fetch data
}, [router, query]);
```

如果替换成下述形式：

```typescript
const router = useRouter();

useEffect(() => {
    // Use router.query to fetch data
}, []);
```

会发现通过 `router.query.id` 获取到的动态路由参数是 `undefined`。你可以通过实践来确认这一点，在修改代码后，观察访问这一页面时后端所返回的错误提示。

请解释这一现象。

!!! note "Tips"

    由于现代软件开发很难单人作战且极难不依赖于第三方，所以当问题发生在你所依赖的第三方或者框架的时候，你很难像在数据结构代码中 debug 那样，简单地回溯找到问题点。这个时候你需要适当地使用搜索引擎，适当地阅读第三方、框架的官方文档来寻找信息，这是软件工程的重要能力之一。

    题面中所描述的现象是 Next.js 框架的一个 Advanced Feature，并且在官方文档中有详细介绍。本题即需要你说明 Next.js 的什么机制导致了这种现象。

## Problem 5 (4 pts)

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