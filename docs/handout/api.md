# 小作业 API 文档

!!! note "甲方可不会给你这些"

    API 文档、数据库表设计文档等文档均应当是开发组内部编写的文档，用于协调组内开发和前后端交互。这些文档均不会由甲方提供，需要开发组自行设计。
    
    API 文档应当包含每一个 API 的地址、请求方法和响应格式，通过 API 文档，前后端均只需要面对 API 的约束进行开发从而实现解耦合。
    
    小作业为了减轻作业压力，不需要大家自行设计 API，只需要面对我们给出的 API 文档实现前后端即可。
    
    由于小作业规模较小，故我们直接使用文字说明。对于较大规模的应用，可以使用一些工具辅助管理 API 文档，如 [Apifox](https://www.apifox.cn)。

## URL `/login`

该 API 用于用户注册与登录。

该 API 仅接受以 POST 方法请求。以其他方法请求均应当设置状态码为 405 Method Not Allowed，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method"
}
```

### POST

使用 POST 方法请求该 API 即表示用户请求登录，若用户不存在，则表示注册该用户。

=== "请求体"

    请求体的格式为：
    
    ```json
    {
        "userName": "Ashitemaru",
        "password": "123456"
    }
    ```
    
    上述字段的说明为：
    
    - `userName`。表示用户名，应当为非空字符串，且长度不大于 50
    - `password`。表示用户的密码，应当为非空字符串，且长度不大于 20

=== "成功响应"

    当该用户不存在（用户名不存在于已有用户名列表中），即注册时，需要创建该用户。

    注册成功时，需要签发 JWT 令牌，设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed",
        "token": "***.***.***" // JWT
    }
    ```
    
    当该用户存在（用户名存在于已有用户名列表中），即登录时，需要核对密码是否与数据库一致。

    登录成功时，需要签发 JWT 令牌，设置状态码为 200 OK，成功响应格式为：

    ```json
    {
        "code": 0,
        "info": "Succeed",
        "token": "***.***.***" // JWT
    }
    ```

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```

    - 若该用户存在（用户名存在于已有用户名列表中），即登录时，密码核对失败，错误响应的状态码为 401 Unauthorized，`code` 字段为 `2`，`info` 字段为 `Wrong password`
    - 若读写数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

## URL `/boards`

该 API 用于操作整体的游戏记录列表，包括获取全部游戏记录以及新增游戏记录。

该 API 仅接受以 GET 与 POST 方法请求。以其他方法请求均应当设置状态码为 405 Method Not Allowed，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method"
}
```

### GET

使用 GET 方法请求该 API 即表示请求当前存储的全部游戏记录，以创建时间为基准倒序排列，越晚创建的记录出现在数组索引越小的位置。

=== "请求体"

    本方法不需要提供任何请求体。

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed",
        "boards": [
            // For example:
            {
                "id": 3,
                "boardName": "Double beehive",
                "createdAt": 1669320727.6460,
                "userName": "Ashitemaru",
            },
            // ...
        ]
    }
    ```
    
    这里 `boards` 字段是一个数组，数组中每一项都应该包含下述字段：
    
    - `id`。表示该游戏记录在数据库中的唯一标识符，应当为正整数
    - `boardName`。表示该游戏记录的名称，应当为非空字符串
    - `createdAt`。表示该游戏记录创建的时间，使用 UNIX 时间戳（秒）表示，应当为浮点数
    - `userName`。表示该游戏创建者的用户名，应当为非空字符串
    
    !!! warning "时间戳是有单位的"
    
        UNIX 时间戳可以以秒、毫秒、微秒作为单位，不同语言和不同第三方默认的 UNIX 时间戳单位是不同的，请务必查明文档。
    
    !!! note "`board` 字段"
    	注意到这里返回的棋盘信息中没有 `board` 字段，这里是故意为之的。
    	这里遵守的设计思想是只提供必要的信息给前端展示。如这里要求列出所有棋盘，显然应该是在“列表”界面出现，不需要具体的棋盘信息。这样设计可以极大地降低网络传输时延（从每个棋盘要传输 2KB 以上的具体数据到只需要传输仅仅几个字节的元信息）。
    	我们可以等到用户真正要看这个棋盘的时候再去请求具体内容，也可以在棋盘元信息取回渲染在前端之后再开始在后台请求具体的数据，实现预加载机制。

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```
    
    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）


### POST

使用 POST 方法请求该 API 即表示请求增加一条游戏记录，如果需要增加的游戏记录已存在，则更新该记录。

=== "请求头"

    使用 POST 方法请求该 API 时需要携带 JWT 令牌验证身份。请求头需要将 `Authorization` 字段设置为 JWT 令牌。

=== "请求体"

    请求体的格式为：
    
    ```json
    {
        "board":
            "00010001010000...",
        "boardName": "Double beehive",
        "userName": "Ashitemaru"
    }
    ```
    
    上述字段的说明为：
    
    - `board`。表示该游戏记录，应当为长度为 2500 的、仅含有 `0` 或者 `1` 的字符串
    - `boardName`。表示该游戏记录的名称，应当为非空字符串，且长度不大于 50
    - `userName`。表示该游戏创建者的用户名，应当为非空字符串，且长度不大于 50

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed",
        "isCreate": false // For example
    }
    ```
    
    这里 `isCreate` 字段是一个布尔值，表示这次请求是否在数据库中新增了一条游戏记录。换言之，若本次请求仅仅是更新了数据库中的某一条记录，则 `isCreate` 字段为 `false`。

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```
    
    - 若请求头中携带的 JWT 令牌无法通过验证或已经过期，错误响应状态码为 401 Unauthorized，`code` 字段为 `2`，`info` 字段为 `"Invalid or expired JWT"`
    - 若请求体中数据格式不满足格式规定，错误响应的状态码为 400 Bad Request，`code` 字段为 `-2`。`info` 字段的具体内容根据具体错误确定。
        1. `board` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [board]"`
        2. `boardName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [boardName]"`
        3. `userName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [userName]"`
        4. `boardName` 为空串或过长，此时 `info` 字段为 `"Bad length of [boardName]"`
        5. `userName` 为空串或过长，此时 `info` 字段为 `"Bad length of [userName]"`
        6. `board` 长度不为 2500，此时 `info` 字段为 `"Bad length of [board]"`
        7. `board` 中含有非 `0` 或 `1` 的字符，此时 `info` 字段为 `"Invalid char in [board]"`
    - 若请求体中 `userName` 与当前 JWT 令牌中的用户名不一致，错误响应的状态码为 403 Forbidden，`code` 字段为 `3`，`info` 字段为 `"Permission denied"`
    - 若读写数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

## URL `/boards/{id}`

该 API 用于操作具体的某一条游戏记录，包括获取该游戏记录、删除该游戏记录。

该 API 仅接受以 GET 与 DELETE 方法请求。以其他方法请求均应当设置状态码为 405 Method Not Allowed，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method"
}
```

此外，需要检测参数 `id`，该参数必须为非负整数。若参数不符合要求均应当设置状态码为 400 Bad Request，错误响应格式为：

```json
{
    "code": -1,
    "info": "Bad param [id]"
}
```

在 `id` 格式正确的基础上应当检验该 ID 对应的游戏记录是否存在。若不存在均应当设置状态码为 404 Not Found，错误响应格式为：

```json
{
    "code": 1,
    "info": "Board not found"
}
```

### GET

使用 GET 方法请求该 API 即表示请求读取指定的游戏记录。

=== "请求体"

    本方法不需要提供任何请求体。

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed",
        "board":
            "00010001010000...",
        "boardName": "Double beehive",
        "userName": "Ashitemaru"
    }
    ```
    
    上述字段的说明为：
    
    - `board`。表示该游戏记录，应当为长度为 2500 的、仅含有 `0` 或者 `1` 的字符串
    - `boardName`。表示该游戏记录的名称，应当为非空字符串，且长度不大于 50
    - `userName`。表示该游戏创建者的用户名，应当为非空字符串，且长度不大于 50

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```
    
    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

### DELETE

使用 DELETE 方法请求该 API 即表示请求删除指定的游戏记录，用户仅能删除自己的游戏记录。

=== "请求头"

    使用 DELETE 方法请求该 API 时需要携带 JWT 令牌验证身份。请求头需要将 `Authorization` 字段设置为 JWT 令牌。

=== "请求体"

    本方法不需要提供任何请求体。

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed"
    }
    ```

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```
    
    - 若请求头中携带的 JWT 令牌无法通过验证或已经过期，错误响应状态码为 401 Unauthorized，`code` 字段为 `2`，`info` 字段为 `"Invalid or expired JWT"`
    - 若用户请求删除非本人创建的游戏记录，错误响应状态码为 403 Forbidden，`code` 字段为 `3`，`info` 字段为 `"Cannot delete board of other users"`
    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

## URL `/user/{userName}`

该 API 用于获取玩家的所有游戏记录。

该 API 仅接受以 GET 方法请求。以其他方法请求均应当设置状态码为 405 Method Not Allowed，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method"
}
```

此外，需要检测参数 `userName`，该参数必须为非空且长度不大于 50 的字符串。若参数不符合要求均应当设置状态码为 400 Bad Request，错误响应格式为：

```json
{
    "code": -1,
    "info": "Bad param [userName]"
}
```

在 `userName` 格式正确的基础上应当检验该名称对应的玩家是否存在。若不存在均应当设置状态码为 404 Not Found，错误响应格式为：

```json
{
    "code": 1,
    "info": "User not found"
}
```

### GET

本接口返回玩家的所有棋盘存档信息。

=== "请求体"

    本方法不需要提供任何请求体。

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：
    
    ```json
    {
        "code": 0,
        "info": "Succeed",
        "userName": "c7w",
        "boards": [
            // For example:
            {
                "id": 7,
                "boardName": "IWannaTakeABreak:(",
                "createdAt": 1669320727.6460,
                "userName": "c7w",
            },
            // ...
        ]
    }
    ```
    
    上述字段的说明为：
    
    - `userName`。查询的用户名，应当为非空字符串，且长度不大于 50
    - `boards`。该玩家的所有对局信息，不含棋盘的具体状态。

=== "错误响应"

    所有错误响应的格式均为：
    
    ```json
    {
        "code": *,
        "info": "[Some message]"
    }
    ```
    
    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）
