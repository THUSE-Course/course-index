# 小作业 API 文档

!!! note "甲方可不会给你这些"

    API 文档、数据库表设计文档等文档均应当是开发组内部编写的文档，用于协调组内开发和前后端交互。这些文档均不会由甲方提供，需要开发组自行设计。

    API 文档应当包含每一个 API 的地址、请求方法和响应格式，通过 API 文档，前后端均只需要面对 API 的约束进行开发从而实现解耦合。

    小作业为了减轻作业压力，不需要大家自行设计 API，只需要面对我们给出的 API 文档实现前后端即可。

    这里提供部分设计 API 文档的时候可以参考的资料：

    【TODO：参考资料】

## URL `/boards`

该 API 用于操作整体的游戏记录列表，包括获取全部游戏记录以及新增游戏记录。

该 API 仅接受以 GET 与 POST 方法请求。以其他方法请求均应当设置状态码为 400 Bad Request，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method",
}
```

### GET

使用 GET 方法请求该 API 即表示请求当前存储的全部游戏记录。

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
                "name": "Double beehive",
                "createdAt": 1669320727646,
                "userName": "Ashitemaru",
            },
            // ...
        ],
    }
    ```

    这里 `boards` 字段是一个数组，数组中每一项都应该包含下述字段：

    - `id`。表示该游戏记录在数据库中的唯一标识符，应当为正整数
    - `name`。表示该游戏记录的名称，应当为非空字符串
    - `createdAt`。表示该游戏记录创建的时间，使用 UNIX 时间戳（毫秒）表示，应当为正整数
    - `userName`。表示该游戏创建者的用户名，应当为非空字符串

=== "错误响应"

    所有错误响应的格式均为：

    ```json
    {
        "code": *,
        "info": "[Some message]",
    }
    ```

    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

### POST

使用 POST 方法请求该 API 即表示请求增加一条游戏记录，如果需要增加的游戏记录已存在，则更新该记录。

=== "请求体"

    请求体的格式为：

    ```json
    {
        "board":
            "00010001010000...",
        "boardName": "Double beehive",
        "userName": "Ashitemaru",
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
        "isCreate": false, // For example
    }
    ```

    这里 `isCreate` 字段是一个布尔值，表示这次请求是否在数据库中新增了一条游戏记录。换言之，若本次请求仅仅是更新了数据库中的某一条记录，则 `isCreate` 字段为 `false`。

=== "错误响应"

    所有错误响应的格式均为：

    ```json
    {
        "code": *,
        "info": "[Some message]",
    }
    ```

    - 若请求体中数据格式不满足格式规定，错误响应的状态码为 400 Bad Request，`code` 字段为 `-2`。`info` 字段的具体内容根据具体错误确定，各类格式错误的优先级如下：
        1. `board` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [board]"`
        2. `boardName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [boardName]"`
        3. `userName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [userName]"`
        4. `boardName` 为空串或过长，此时 `info` 字段为 `"Bad length of [boardName]"`
        5. `userName` 为空串或过长，此时 `info` 字段为 `"Bad length of [userName]"`
        6. `board` 长度不为 2500，此时 `info` 字段为 `"Bad length of [board]"`
        7. `board` 中含有非 `0` 或 `1` 的字符，此时 `info` 字段为 `"Invalid char in [board]"`
    - 若读写数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

## URL `/boards/{id}`

该 API 用于操作具体的某一条游戏记录，包括获取该游戏记录、删除该游戏记录以及更新该游戏记录。

该 API 仅接受以 GET、DELETE 与 PUT 方法请求。以其他方法请求均应当设置状态码为 400 Bad Request，错误响应格式为：

```json
{
    "code": -3,
    "info": "Bad method",
}
```

此外，需要检测参数 `id`，该参数必须为正整数。若参数不符合要求均应当设置状态码为 400 Bad Request，错误响应格式为：

```json
{
    "code": -1,
    "info": "Bad param [id]",
}
```

在 `id` 格式正确的基础上应当检验该 ID 对应的游戏记录是否存在。若不存在均应当设置状态码为 404 Not Found，错误响应格式为：

```json
{
    "code": 1,
    "info": "Board not found",
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
        "userName": "Ashitemaru",
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
        "info": "[Some message]",
    }
    ```

    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

### DELETE

使用 DELETE 方法请求该 API 即表示请求删除指定的游戏记录。

=== "请求体"

    本方法不需要提供任何请求体。

=== "成功响应"

    请求成功时，应当设置状态码为 200 OK，成功响应格式为：

    ```json
    {
        "code": 0,
        "info": "Succeed",
    }
    ```

=== "错误响应"

    所有错误响应的格式均为：

    ```json
    {
        "code": *,
        "info": "[Some message]",
    }
    ```

    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）

### PUT

使用 PUT 方法请求该 API 即表示请求更新指定的游戏记录。

=== "请求体"

    请求体的格式为：

    ```json
    {
        "board":
            "00010001010000...",
        "boardName": "Double beehive",
        "userName": "Ashitemaru",
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
    }
    ```

=== "错误响应"

    所有错误响应的格式均为：

    ```json
    {
        "code": *,
        "info": "[Some message]",
    }
    ```

    - 若请求体中数据格式不满足格式规定，错误响应的状态码为 400 Bad Request，`code` 字段为 `-2`。`info` 字段的具体内容根据具体错误确定，各类格式错误的优先级如下：
        1. `board` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [board]"`
        2. `boardName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [boardName]"`
        3. `userName` 字段缺失或非字符串类型，此时 `info` 字段为 `"Missing or error type of [userName]"`
        4. `boardName` 为空串或过长，此时 `info` 字段为 `"Bad length of [boardName]"`
        5. `userName` 为空串或过长，此时 `info` 字段为 `"Bad length of [userName]"`
        6. `board` 长度不为 2500，此时 `info` 字段为 `"Bad length of [board]"`
        7. `board` 中含有非 `0` 或 `1` 的字符，此时 `info` 字段为 `"Invalid char in [board]"`
    - 若读取数据中途抛出错误，错误响应的状态码为 500 Internal Server Error，`code` 字段为 `-4`，`info` 字段尽量携带错误信息（CI 不评测该错误响应）
