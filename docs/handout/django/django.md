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
└── <Project Name>
    ├── __init__.py
    ├── asgi.py
    ├── settings.py
    ├── urls.py
    └── wsgi.py
```

这时，你一般需要在 `<project>/settings.py` 中的 `INSTALLED_APPS` 字段中注册该应用（见我们给出的小作业示例）。接下来，你应该能够理解我们给出的小作业目录结构：

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

!!! note 参考资料
	本节对应官方文档 “编写你的第一个 Django 应用，第 1 部分” 中“创建项目”、“用于开发的简易服务器”、“创建投票应用”节。



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

!!! note 思考题
	假如要设置 `<project>/urls.py` 要把所有的请求都转发给 `api/urls.py` 应该如何设置？`<project>/urls.py` 中 `path` 所**匹配掉**的字段应如何填写？



### 模型（Models）

!!! note 数据库使用的相关知识
	如果你对记录、主键、外键、索引、联合主键这些概念并不熟悉，你可以阅读 [这篇文档](https://zhuanlan.zhihu.com/p/64368422) 快速入门。在实际的开发过程中，这些元数据对于数据表的设计以及数据库使用起来的性能是至关重要的。

在 Django 中，模型用于数据库中数据表的结构设计以及数据表的元数据（如主键、外键、索引等）管理。我们使用 Django 提供的 ORM 机制来进行对数据表和数据表列属性的管理。具体来说，我们只需要在 `<app>/models.py` 中定义一个类继承 `django.db.models.Model` 即可，比如[官方文档](https://docs.djangoproject.com/zh-hans/4.1/intro/tutorial02/)中给出的定义：

```python
from django.db import models

class Question(models.Model):
    question_text = models.CharField(max_length=200)
    pub_date = models.DateTimeField()

class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)
```

在你修改完应用的 `models.py` 之后，你应该使用如下命令去生成修改数据表结构与属性的语句：

```bash
python3 manage.py makemigrations
```

注意请不要将 migrations 文件夹纳入到 .gitignore 文件中。进而，每次在服务端部署时，在其运行之前，请确保你的部署脚本会执行：

```bash
python3 manage.py migrate
```

将上条命令生成的修改表属性的语句应用到该部署所对应的数据库中。

由于我们只是进行本地测试，所以你可以在本地连续地输入这两条指令，本地的数据库会存储在 `db.sqlite3` 文件中。 

!!! note 思考题
	请查阅文档，主键、外键、联合主键、唯一性约束、索引这些元数据都应该如何创建？

!!! note 参考资料
	本节对应官方文档 “编写你的第一个 Django 应用，第 2 部分” 中“数据库配置”、“创建模型”、“激活模型”节。



### 视图（Views）

我们接下来介绍视图函数。



### 单元测试（Unit Tests）

接下来我们介绍单元测试。

