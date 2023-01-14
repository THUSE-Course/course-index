# Django 语法

本文档回顾 Django 中关于上一章提到的 “路由”、“模型”、“视图” 与 “单元测试” 的具体写法。在文档中有若干以**粗体**标识的关键词，如果你对这些概念已经非常熟悉，就可跳过本节内容。

!!! warning 注意时效性
	本文档在撰写时主要参考了官方 Django 教程 [4.1 版本](https://docs.djangoproject.com/en/4.1/) 的文档，请注意关注官方教程保持其时效性。



## Django 框架

### 文件树结构

在安装了 Django 库之后，我们可以使用 `django-admin startproject <项目名>` 来创建一个新项目。在新建**项目**后，我们进入项目文件夹，可以看到如下的文件树：

```
.
├── manage.py  # 使用命令行操作后端的主入口
└── <Project Name>
    ├── __init__.py  
    ├── settings.py  # 后端启动时应用的设置
    ├── urls.py  # 主路由入口
    ├── asgi.py  # 以 asgi 方式进行部署的配置文件
    └── wsgi.py  # 以 wsgi 方式进行部署的配置文件
```

项目部署的部分是大作业阶段 Sprint 1 的主要内容，这里我们不详细展开。

然后我们可以使用 `python3 manage.py startapp <应用名> ` 来新建一个**应用**。一个 Django 项目中可以同时存在多个应用，一个应用是具有完成某个独立功能作用的模块，这之后你应该看到：

```
.
├── app1  # 你创建的应用
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── migrations  # 应用对数据库表及表属性的修改历史
│   │   └── __init__.py
│   ├── models.py  # 应用的“模型”定义
│   ├── tests.py  # 应用的“单元测试”定义
│   └── views.py  # 应用的“视图”定义
├── manage.py
└── v11
    ├── __init__.py
    ├── asgi.py
    ├── settings.py
    ├── urls.py
    └── wsgi.py
```

接下来，你应该能够理解我们给出的小作业目录结构：

```
.
├── DjangoHW  # 我们的项目名为 DjangoHW
│   ├── __init__.py
│   ├── asgi.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── README.md
├── board  # 我们新建了一个应用叫做 board
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── migrations
│   │   ├── 0001_initial.py
│   │   ├── 0002_remove_board_deleted_remove_user_deleted.py
│   │   └── __init__.py
│   ├── models.py
│   ├── tests.py
│   ├── urls.py
│   └── views.py
├── db.sqlite3  # 本地数据库存储
├── manage.py
├── requirements.txt
└── utils  # 撰写的功能函数，可以放在应用中也可以放在根目录下，保证引用路径正确即可
    ├── utils_request.py
    ├── utils_require.py
    └── utils_time.py
```



### 路由（Routing）

首先，我们来解决后端收到请求时，后端会将请求交给哪个应用的哪个视图函数处理的问题。和这个功能有关的文件主要包括 `<项目名>/urls.py` 和 `<应用名>/urls.py`。

假如我们的后端部署在 `my-backend.com`，我们在访问 `my-backend.com/board/restart` 时，后端会首先在 `<项目名>/urls.py` 中以 `board/restart` 开始搜索。假设 `<项目名>/urls.py` 中配置为：

```python
from django.urls import path, include

urlpatterns = [
    path('board/', include("board.urls")),
]
```

我们会匹配掉字符串 `'board/'`，然后将剩下的请求 `restart` 交给 `board/urls.py` 处理，这也是这里 `include` 的作用，将请求转发给子应用的路由表处理。

然后，假设我们在 `board/urls.py` 中配置为：

```python
from django.urls import path, include
import board.views as views

urlpatterns = [
    path('restart', views.restart_board),
]
```

这时剩余请求 `restart` 匹配到第一条规则后，交由 `board/views.py` 中的 `restart_board` 函数进行处理，即后端会帮助我们调用这个函数，并把请求体（和请求有关的信息，包括请求方法、请求数据等等）作为参数传给这个函数。

此外还有更多和路由有关的功能，例如在路径中解析变量等，请阅读[官方文档](https://docs.djangoproject.com/zh-hans/4.1/topics/http/urls/)。



### 模型（Models）



### 视图（Views）



### 单元测试（Unit Tests）

