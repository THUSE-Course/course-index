# 管理全局状态

## 实验目的

通过本 Step，我们希望你能够掌握如何在 React 中通过 Redux 实现全局数据共享，据此实现登录令牌的存储与读取。

## 实验步骤

首先你需要理解如何使用 Redux 以及 `useSelector, useDispatch` 两个 Redux Hook，并且需要阅读本文档中有关基于令牌的鉴权系统的相关内容，理解小作业中使用的登录系统工作原理。

之后，你需要完成四处代码填空。其中第一处位于 `src/pages/login.tsx` 的组件 `LoginScreen` 中，你需要在登录请求成功后的回调函数中发起将后端服务器所签发的 JWT 令牌存储到 Redux 的请求。第二处位于 `src/redux/auth.ts` 中，你可以仿照已经完成的 Reducer 编写代码，以正确处理存储 JWT 令牌的请求并正确更新 Redux 存储。第三和第四处位于 `src/utils/network.ts` 的函数 `request` 中，你需要在网络请求函数中编写代码以读取 Redux 中 JWT 令牌，并将其携带在请求头中供服务器鉴权。

本 Step 四处填空的代码量均在 10 行以内。

在完成填空后，目前的游戏应当可以正常登录。

完成本 Step 后，你的游戏的交互应当和下述 GIF 图所展示的类似：

![](../../static/react/step4-demo.gif)

### 代码说明

代码框架中的函数 `request` 事实上是一个在 JWT 鉴权系统下的通用网络请求函数，虽然错误处理部分依然较为粗糙。本 Step 中你主要需要关注 `needAuth` 参数，其表示了当前的网络请求是否需要携带 JWT 供鉴权，你需要据此判断是否需要携带 JWT 令牌以及是否需要在读取令牌失败时报错等。

---

从本 Step 开始，前后端需要对接使用，这里简单叙述如何在本地对接前后端。首先你需要一个已经完全完成的后端小作业，将其启动并监听某一个端口。之后，打开前端小作业的 `next.config.js` 文件，找到下述内容：

```javascript
// ...
async rewrites() {
    return [{
        source: "/api/:path*",
        destination: "http://127.0.0.1:8001/:path*",
    }];
}
// ...
```

将这里的 `8001` 修改为你的后端所监听的端口号即可。

## 实验评分

本 Step 总分为 10 分。

本 Step 采用人工评分。我们会查看截止时间前最后一次部署后游戏主界面是否满足：

- （4 分）未登录时，在自由状态下任意创建一个游戏记录，输入游戏记录名后点击保存按钮，提示需要登录并自动跳转至登录页面
- （2 分）输入新用户名和密码，点击注册/登录，提示成功并自动切换回到主界面
- （1 分）先前创建的游戏记录保持在棋盘上，并且最下方的跳转至登录页面按钮转变为已登录提示文字和注销按钮
- （3 分）再次输入游戏记录名点击保存，此时显示保存成功

由于本 Step 涉及到网络请求，如果出现网络错误提示弹窗或者 5 秒内页面没有反应，我们会重试一次。若重试依然不成功则判定该功能点不得分。

??? note "一些小提示"

    本 Step 要求在未登录的时候要能够自动跳转至登录页面，然而在网络请求函数内部似乎并不能直接触发页面跳转。观察一下代码框架，事实上我们在 `src/pages/index.tsx` 中已经为你写好了弹窗和跳转的代码，你只需要思考 `request` 函数应当如何触发这一段代码：

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

## 知识讲解

Redux 可以理解为一个所有组件都可以访问和操作的存储，Redux 的提出是因为 React 本身仅提供了在父子组件之间传递数据的方案，对于登录状态、登录令牌、用户信息等所有组件都需要的信息则相对难以处理。

编写 Redux，首先需要定义存储本身，本作业框架中 `src/redux/store.ts` 文件则完成了这一任务，其定义了 `store` 对象。Redux 的存储是由多个切片构成的，可以理解为不同用途的空间。例如本作业中用于保存用户信息的 `src/redux/auth.ts` 和临时保存棋盘信息的 `src/redux/board.ts`。这些切片最终汇总到 `store.ts` 文件中用来构成最后的 `store`。

Redux 存储切片的定义以 `src/redux/board.ts` 为例：

```typescript
interface BoardState {
    board: Board;
}

const initialState: BoardState = {
    board: getBlankBoard(),
};

export const boardSlice = createSlice({
    name: "board",
    initialState,
    reducers: {
        setBoardCache: (state, action: PayloadAction<Board>) => {
            state.board = action.payload;
        },
        resetBoardCache: (state) => {
            state.board = getBlankBoard();
        },
    },
});
```

首先通过接口定义这个切片中存储的数据格式，并且定义默认值。随后通过 `createSlice` 函数定义切片，其中定义了切片的名称，以及操作该切片中数据的方法——Reducer。Reducer 会接受当前的状态 `state` 和外部发起的修改请求 `action`，修改请求往往有一个负载 `action.payload`。Reducer 的目的则是根据 `action` 更新 `state` 之中的信息，形成新的状态。

例如这里 `setBoardCache` 则会将该切片中的 `board` 字段更新为修改请求中所负载的棋盘状态。

---

在组件中读取 Redux 中的数据的方法为使用 `useSelector` Hook，例如 `src/pages/index.tsx` 中：

```typescript
const boardCache = useSelector((state: RootState) => state.board.board);
const userName = useSelector((state: RootState) => state.auth.name);
```

这里读取了 Redux 存储中的 `state.board.board` 以及 `state.auth.name` 两个值。值得注意的是，`useSelector` Hook 的重要作用是，当组件中所读取的存储值发生改变的时候，该 Hook 可以令该组件重新渲染。

然而由于 Hook 仅能够在组件中使用，在组件外需要获取 Redux 数据时，可以直接通过 `store.getState()` 获取到 Redux 当前所有的切片数据。

在组件中修改 Redux 中的数据的方法为使用 `useDispatch` Hook，该 Hook 返回一个 `dispatch` 函数，直接用此函数发送一个 Reducer 即可发起更改：

```typescript
const dispatch = useDispatch();
dispatch(resetBoardCache());
```