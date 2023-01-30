# 任务清单

本文档列出所有你需要在 Django 小作业中做的任务。



## 环境配置

我们使用 `Python=3.9` 配置的本次作业，请在此基础上运行下述命令安装依赖。

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
```



## 代码阅读

快速阅读提供的代码框架，试着回答以下问题：

- 本次作业的顶层项目名是什么？其下有哪些应用？
- `utils` 中的三个文件中的功能函数的输入、输出分别是什么？`CheckRequire` 装饰器的作用是什么？
- 本项目的部署经过了哪些阶段？不同阶段分别做了什么？



## 添加路由

在 `board/urls.py` 中：

- 为 `boards/<index>` API 添加路由到 `views.boards_index` 视图函数
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



## 补全与添加视图函数

在 `board/views.py` 中：

- 阅读 `boards` 视图函数，找出其在 API 文档中的对应项，然后补全 `check_for_board_data` 中的检查输入字段功能
- 阅读 `boards_index` 视图函数的 GET 与 DELETE 方法，按照提示补全 PUT 方法的有关逻辑
- 自行设计并完成 `user/<userName>` API 所对应的视图函数



## 进行单元测试

我们为你撰写的脚本 `test.sh` 包含了进行单元测试与计算覆盖率的功能。如果你只想运行单元测试，你可以运行：

```bash
python3 manage.py test
```

正确完成本次作业应该可以通过所有测试点。在小作业中你可以阅读 `board/tests.py` 中的测试逻辑对你的路由、模型与视图函数进行修改，**但请不要修改 `board/tests.py` 中的内容**。在后续的项目中 `tests.py` 将由组内负责测试与质量保证的同学进行撰写。

