# 知识储备

本文档回顾前后端分离开发范式中后端的作用。在文档中有若干以**粗体**标识的关键词，如果你对这些概念已经非常熟悉，就可跳过本节内容。

!!! note "Tips"

    本部分的部分内容已经在前后端分离开发基础中提到，不过做出了更为深入的介绍。

## 后端

### “服务端渲染”与“客户端渲染”

在之前的《程序设计训练》课程中，我们接触过“**服务端渲染**”的处理方式，即后端将网页在本地“**渲染**”（对网页模板进行占位符替换）后，将“渲染”好的网页直接发给用户。这样做服务器端需要解析 HTML 模板，对服务器资源的占用较大；同时前后端紧密耦合，不利于项目的高效开发。

取而代之地，“**客户端渲染**”的方式则是将上述开发过程一分为二：分为前端团队与后端团队两支队伍，前端团队专注于 UI 设计与实现，后端团队只需要提供相应的 API 接口负责具体展示的数据。在用户请求时，服务端先将一个带有逻辑功能（JS 代码）的网页模板发给用户，用户浏览器打开后通过逻辑代码的指示再去请求后端 API 具体要展现什么数据；在拿到后端接口返回的相应数据后，前端再通过自己的逻辑代码将内容“渲染”到浏览器中。

!!! 思考题
    试着对以下网站进行分析，它们是“客户端渲染”还是“服务端渲染”？
    
    + GitHub.com
    + Bilibili.com
    + 网络学堂 2018
    
    提示：一个比较简单的判断方式是在网页要展示的数据还在请求时，网页是显示占位符（如提示 Loading... 之后将数据替换在这个地方）还是完全空白。当然，更加合理的做法是打开网页“审查元素”后进入“网络”选项卡，试着理解每一次请求都在做什么。后端返回给浏览器的，是整个网页，还是仅含有网页中内容的数据包？



### 后端的作用

在“客户端渲染”的语境下，后端可以理解成**与前端交互数据**，并**操作与管理数据库**的一段逻辑代码。接下来我们以一个视频网站为例进行讲解。

**与前端交互内容**包含两个方面：一方面是后端面对前端的查询请求（**GET** 方法）要返回相应的数据供前端渲染，比如用户点开网页后首页要进行视频推荐，用户可以查看自己的个人信息；另一方面是后端面对前端的修改请求（**POST** 方法、**PUT** 方法、**DELETE **方法，分别对应创建、修改、删除）要在**检查**后做出响应，比如用户可以上传视频、发表评论、修改个人信息、删除视频等等。做检查是很重要的一部分，因为前后端分离的开发范式中十分重要的一个思想是**后端不相信前端**，即后端接受到的任何请求除了是前端发来的之外，还有可能是攻击者发来的，因此必须对请求内容做出相应检查。

后端与前端的交互通过网络请求的格式进行，而最常用的数据规范便是 **JSON 格式**（JavaScript Object Notation）。JSON 将数据组织成键值对的形式，其值涵盖的类型包括：object, array, number, string, Boolean (true / false) 和 null。很多高级语言都支持 JSON 格式与自身自带的 HashMap 容器的高效转换，比如在 Python 中，`json` 库可以将 JSON 字符串与 dict 进行转换。

**操作与管理数据库**是由于我们需要将用户的数据高效地组织起来，以供后续查询与修改。这里的“数据库”是一个相对广泛的概念：对于简单的开发需求，**文件系统**也可以满足这个“数据库”的要求，用户的数据可以直接存储成文件的形式；但是，面对更大体量的数据，面对更快的查询与修改需求，各种各样的**数据库软件**是不可或缺的。不管采用哪种数据存储方式，都是以需求和用户为中心服务的。

**关系型数据库**是数据库的一种，一个数据库应用中可以创建若干个**数据库**，每个数据库又可以包含若干个**数据表**（可以类比 Excel 的工作簿、工作表进行理解）。每个数据表中，不同列代表不同的属性，每一行代表一条记录。事实上，我们可以将数据表与一个实体类联系起来。将每一列看做是这个实体类的一个具体的成员变量，每一行看成是这个类的一个实例。换句话说，我们可以将每张数据表看做是相同类的实体构成的集合。这种观点就是 **ORM 机制**（Object-relational mapping）出现的基础：我们可以用操作类和对象的代码来直接操作关系型数据库，而无需裸写 SQL 语句。当然，这样做会带来一定的性能损失，但极大地有利于程序员对代码本身的理解。



### 后端的测试

软件开发与之前我们在课程中写代码最不同的一点就是要多做**软件测试**。在软件开发中，程序的正确性是至关重要的，于是需要专人（测试工程师）来撰写相应的测试代码，涉及到一般情况与尽可能多的 Corner Cases。一方面，这能帮助开发工程师有效开发，另一方面，在一个大型项目中可能会出现改动一部分代码导致另一部分代码的原有功能失效的情况，而通过固定的测试程序与测试用例则可以保证只有稳定的版本才会最终呈现给用户。

后端的单元测试往往有如下前提：

+ 测试工程师将开发工程师撰写的后端逻辑视为黑盒
+ 测试工程师可以直接模拟前端请求，读取与修改数据库中的内容
+ 测试工程师可以通过一系列断言验证程序的正确性

测试工程师就像是在设计 OJ 测例，断言后端系统在面对输入（用户请求）时，应该产生什么样的输出（对用户请求的响应、对数据库的修改）。若断言失败，则说明开发工程师提交的本次修改存在功能性问题，需要进行修复。

我们一般以测试覆盖率来定量地衡量后端测试的有效性与完整性，其中覆盖率的计算方式为测例覆盖到的代码行数与总代码行数之比。



### 后端框架如何工作

一个成熟的后端框架往往具备以下解耦合的功能：

+ 路由：将前端请求的不同路径**映射**到不同的处理函数的方法
+ 模型：**与数据库进行交互**的方法，可以使用 ORM 机制撰写成面向对象风格
+ 视图：前端请求的**处理函数**，接受用户请求并返回响应
+ 单元测试：如何为测试工程师提供模拟请求、读写数据库、断言的操作

这里的“路由”、“模型”、“视图”都是 Django 中的概念，在其他的后端框架中它们不一定被如此称呼，但你总可以在学习其他后端框架时找到这些重要概念的影子。



