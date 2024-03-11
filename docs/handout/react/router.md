# 切换页面

## 实验目的

通过本 Step，我们希望你能够掌握如何在 Next.js 框架中设置页面路由和跳转，从而基本完成游戏记录列表页面。

## 实验步骤

本步骤不需要实操，但我们希望你通过阅读代码框架和本文档来理解 Next.js 框架中的页面路由和跳转。

首先你需要理解 Next.js 框架中如何管理页面路由，以及简单了解如何使用 `useRouter` Hook 来获取路由相关的基本信息以及实现页面跳转。

本 Step 需要你关注的是游戏记录列表页面，路径为 `/list`。我们已经在游戏主界面（路径为 `/`）底部写好了一个点击后能跳转到该页面的按钮，按钮上文字应当是 Go to full list。

之后，你需要关注文件 `src/pages/list.tsx` 中的 `ListScreen` 组件，注意游戏记录列表页面中各按钮的点击事件处理函数中的路由行为。游戏记录列表页面具有下述的交互：

- 页面加载完成后显示游戏记录的列表，若暂无游戏记录，则显示空列表提示文字
- 点击某个记录的 Play it 按钮可以跳转到 Replay Mode 的游戏主界面回放该记录（Replay Mode 的主界面路径为 `/?id={id}`）
- 点击自己所创建的记录的 Delete it 按钮可以删除该记录（非自己的记录则不显示该按钮），需要有弹窗提示删除成功，删除成功后列表中该记录应当立刻消失
    - 该交互由于处理删除记录的函数 `deleteBoard` 在下一个 Step 才需要填充，故这一步仅仅会展示按钮
- 点击某个记录的 View this user 按钮可以跳转到该记录作者的所有游戏记录页面（路径为 `/list?name={userName}`）

具体的 UI 结构设计可以参考需求文档中的截图。

游戏记录列表的交互和下述 GIF 图所展示的类似：

![](../../static/react/step5-demo.gif)

### 实验提示

在渲染一个列表的时候不妨考虑一下 `Array.map` 方法，其会接受一个回调函数并且将数组中每一项按照回调函数指明的规则映射为新数组中对应项。回忆一下，React 组件的渲染，不就是将数据映射为 UI 吗？

### 代码说明

我们已经在 `ListScreen` 组件内声明了 `refreshing, boardList` 两个组件状态，前者用于表示当前页面是否还在获取数据过程中，后者则用于存储列表页面用于展示的游戏记录。

此外，你可以注意到我们在解析路由中用户名参数的时候使用了 `decodeURIComponent` 函数，这是因为用户名中可能含有部分特殊字符，如 `?/!#@` 或者空格，这些字符无法直接嵌入链接中。

---

??? note "一些小提示"

    小作业要求在未登录的时候要能够自动跳转至登录页面，然而在网络请求函数内部似乎并不能直接触发页面跳转。观察一下代码框架，事实上我们在 `src/pages/index.tsx` 中已经为你写好了弹窗和跳转的代码，你只需要思考 `request` 函数应当如何触发这一段代码：

    ```typescript hl_lines="8 9"
    request(/* params */)
        .then((res) => alert(res.isCreate ? CREATE_SUCCESS : UPDATE_SUCCESS))
        .catch((err) => {
            if (
                err instanceof NetworkError &&
                err.type === NetworkErrorType.UNAUTHORIZED
            ) {
                alert(LOGIN_REQUIRED);
                router.push("/login");
            }
            else {
                alert(FAILURE_PREFIX + err);
            }
        });
    ```

---

从本 Step 开始，前后端需要对接使用，这里简单叙述如何在本地对接前后端。首先你需要一个已经完全完成的后端小作业，将其启动并监听某一个端口。之后，打开前端小作业的 `next.config.js` 文件，找到下述内容：

```javascript
// ...
async rewrites() {
    return [{
        source: "/api/:path*",
        destination: "http://127.0.0.1:8000/:path*",
    }];
}
// ...
```

将这里的 `8000` 修改为你的后端所监听的端口号即可。

## 知识讲解

由于本 Step 所涉及的技术要点基本都有成熟的文档介绍，这里直接引用参考文档链接。

你需要了解 Next.js 是通过 `pages` 目录下的目录结构管理路由的，具体的文档参见 [Next.js 官方文档相关页面](https://nextjs.org/docs/routing/introduction)。

关于路由，Next.js 定义了 `useRouter` Hook。其可以用于获取动态路由之中携带的参数以及通过 `const router = useRouter(); router.push(...);` 的方式实现页面跳转。该 Hook 的文档见 [官方指导](https://nextjs.org/docs/api-reference/next/router#userouter)。

!!! note "浏览器 JavaScript 与 `useRouter`"

    我们提到过使用 `router.push()` 方法可以令页面跳转，然而在浏览器原生 JavaScript 中，对 `window.location.href` 赋值也能实现页面跳转。

    这两者的核心区别在于使用原生 JavaScript 会导致整个页面的完全重加载，这对性能而言是相当不利的。所以，我们推荐使用 `useRouter` 的方式实现页面跳转，非必要不使用原生 JavaScript 方法。

### 基于文件系统的路由

前端的路由，指的是如何将网址中的路径映射到具体的页面。而 Next.js 采用基于文件系统的路由，即网址的路径与组件所在 `.tsx` 文件路径一致。

小作业中 `src/pages` 目录下文件结构如下所示：

```plaintext
src
└── pages
    ├── _app.tsx
    ├── index.tsx
    ├── login.tsx
    └── list.tsx
```

其中 `_app.tsx` 是 Next.js 的入口文件，不参与路由，`index.tsx` 是保留文件名。所以各个文件对应的路由如下：

- `/` 对应 `index.tsx`
- `/login` 对应 `login.tsx`
- `/list` 对应 `list.tsx`

更复杂的路由的例子如下所示：

```plaintext
src
└── pages
    ├── _app.tsx -> 入口文件
    ├── index.tsx -> /
    ├── login.tsx -> /login
    └── list
        ├── index.tsx -> /list
        ├── detail.tsx -> /list/detail
        └── edit.tsx -> /list/edit
```

### `useRouter` Hook

Next.js 提供了一个 `useRouter` Hook，可以用于获取当前页面的路由信息。

本次课程中主要使用下述两个功能：

- 捕获路由参数
- 实现页面跳转

#### 捕获路由参数

路由参数指的是网址中所负载的参数，例如 `/list?name=holder` 中的 `name=holder` 就代表名为 `name` 的路由参数，值为 `holder`。

在文件 `src/pages/index.tsx` 中有下述代码，`useEffect` 的用法 Step 4 中会作详细讲解：

```typescript
const router = useRouter();
const query = router.query;

useEffect(() => {
    if (!router.isReady) {
        return;
    }

    // 从这里获取路由参数 id（网址形如 /?id=3）
    router.query.id;
}, [router, query]);
```

!!! note "关于 `router.isReady`"

    `router.isReady` 是一个布尔值，用于表示当前页面的路由参数是否已经准备好。这是因为 Next.js 会在页面加载完成之前先加载页面，然后再加载路由参数，所以在页面加载完成之前，`router.query` 可能是空的。

    由于这个特性，我们在 `useEffect` 中使用了 `router.isReady` 来保证我们在获取路由参数之前，页面已经加载完成。

    该写法较为复杂的根源是 Next.js 的 [ASO 机制](https://nextjs.org/docs/pages/building-your-application/rendering/automatic-static-optimization)。

#### 实现页面跳转

页面跳转的代码如下所示，更多方法参见 Next.js 文档：

```typescript
router.push("/");  // 跳转到首页
router.back();  // 返回上一页
```

需要注意的是，类似 `window.href = ...` 等 JS 原生方法也能实现跳转，但是由于很有可能不与 Next.js 框架兼容，所以请尽量不要使用这类方法。
