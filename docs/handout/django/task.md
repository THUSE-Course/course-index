# 任务清单

本文档列出所有你需要在 Django 小作业中做的任务。



## 环境配置

我们使用 Linux（或 WSL）环境与 `Python=3.11` 配置本次作业，推荐你使用 `conda` 创建一个新的虚拟环境：

```bash
conda create -n django_hw python=3.11 -y
conda activate django_hw
```

在此环境的基础之上，你可以运行下述命令安装依赖，注意请确保你的当前工作路径在克隆的小作业仓库中：

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
```

!!! note "配置环境也是软件工程的一部分"

    软件工程是一门研究用工程化方法构建和维护有效的、实用的和高质量的软件的学科，而配置环境是任何工程化项目的第一步。在本次作业中，我们使用了 `conda` 作为环境管理工具，使用了 `pip` 作为依赖管理工具。这些工具的使用都是为了让你能够更加方便地配置环境，从而更加专注于实现功能。在大作业中，你也会使用到类似的工具，因此请务必熟悉这些工具的使用方法。


然后，你可以运行如下指令检查环境配置是否成功：

```bash
python3 manage.py runserver
```

这会在 `localhost:8000` 开启服务端进行监听网络请求。你可以打开浏览器，访问 http://localhost:8000/startup 来检查服务端是否正常启动。如果正常启动，你会看到含有 "Congratulations! You have successfully installed the requirements. Go ahead!" 的网页。



## 代码阅读

快速阅读提供的代码框架，试着回答以下问题：

- 本次作业的顶层项目名是什么？其下有哪些应用？
- `utils` 中的四个文件中的功能函数的输入、输出分别是什么？`CheckRequire` 装饰器的作用是什么？



!!! note "API 文档"
	下面的任务推荐你对照着 API 文档完成。


## 添加路由

在 `board/urls.py` 中：

- 为 `boards/<index>` API 添加路由到 `views.boards_index` 视图函数
    - 注意这里不要写成 `<int:index>`，因为 API 文档里规定对于不是 int 的情况也要返回合法的 JSON 请求，而非展示 Django 的默认 404 网页

- 为 `user/<userName>` API 添加路由到下面“添加视图函数”节中自定义的视图函数



## 补全模型

在 `board/models.py` 中：

- 补全 `Board` 类的成员
    - `id`，使用 BigAutoField，设置主键
    - `user`，外键连接到 `User` 类，使用级联删除
    - `board_state`，使用 CharField
    - `board_name`，使用 CharField
    - `created_time`，使用 FloatField，初始值为类创建时的时间
- 补全 `Board` 表的元数据
    - 为 `board_name` 创建索引
    - 在 `user` 和 `board_name` 上建立联合唯一约束

之后，你应该使用如下命令建库：

```bash
 python3 manage.py makemigrations board && python3 manage.py migrate
```



## 补全与添加视图函数

在 `board/views.py` 中：

- 按照所给注释补全 `login` 登录函数
- 阅读 API 文档中的对应项，然后补全 `check_for_board_data` 中的检查输入字段功能
- 按照所给注释补全 `boards` 视图函数
- 阅读 API 文档中的对应项，完成 `boards_index` 的 DELETE 方法
- 阅读 API 文档中的对应项，完成 `user/<userName>` API 所对应的视图函数



## 进行单元测试

我们为你撰写的脚本 `test.sh` 包含了进行单元测试与计算覆盖率的功能。如果你只想运行单元测试，你可以运行：

```bash
python3 manage.py test
```

正确完成本次作业应该可以通过所有测试点。在小作业中你可以阅读 `board/tests.py` 中的测试逻辑对你的路由、模型与视图函数进行修改，**但请不要修改 `board/tests.py` 中的内容**。在后续的项目中 `tests.py` 将由组内负责测试与质量保证的同学进行撰写。

