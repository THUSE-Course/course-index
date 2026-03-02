# FastAPI 后端小作业文档

!!! info "为 Vibe Coding 准备的文档"

    这是为了 vibe coding 准备的文档, 我们希望同学们能运用 vibe coding 来完成 FastAPI 的后端小作业.

## 前置条件

如果你希望了解小作业的更多细节, 请先阅读 [Django](../django/index.md) 的文档. 我们将直接在 Django 的基础上讲解 FastAPI 的相关内容.

## 什么是 FastAPI

FastAPI 是一个用于编写 **Web API** 的 Python 框架, 它的设计目标是让开发者能够快速简单地构建高性能的 API 服务. 在前后端分离的框架下, 后端常常并不负责渲染 HTML, 因此 FastAPI 主要关注于处理 HTTP 请求、验证数据、返回 JSON 响应等 API 相关的功能, 而不是像 Django 那样同时提供模板渲染、ORM 等全栈功能.

FastAPI 的核心优势包括:

- **类型提示驱动的参数校验**: 在函数签名里写清楚参数类型的情况下, FastAPI 会自动验证请求参数是否符合预期, 不符合就直接返回错误响应
- **自动生成接口文档**: 它会根据你的路由和参数定义生成 OpenAPI 规范, 并提供可交互的文档页面, 便于自测和联调
- **对异步友好**: 可以用 `async def` 编写接口, 适合处理高并发 I/O 场景 (例如大量请求 / 调用外部服务 / WebSocket 等)

## FastAPI 应用的常见选型

以下是一些在 FastAPI 应用中常见的工具和库, 你可以根据项目需求选择使用. 对于小作业, `uvicorn` + `pydantic-settings` + `SQLAlchemy` with sqlite3 即可.

### Web 框架

- ASGI Server
  - `uvicorn`: FastAPI 官方示例默认使用的 ASGI 服务器, 性能不错, 支持 HTTP/1.1 和 HTTP/2
  - `hypercorn`: 另一个 ASGI 服务器, 支持 HTTP/2 和 QUIC, 适合需要这些协议的场景

- 进程管理 / 多 worker
  - `gunicorn` + `uvicorn.workers.UvicornWorker`
  - `uvicorn --workers N`: 更简单直接, 但能力比 gunicorn 少一点

### 配置与环境变量

- `pydantic-settings`: Pydantic v2 推荐的 settings 管理方式, 直接用 Pydantic 模型定义配置项, 支持从环境变量、文件等多种来源加载
- `python-dotenv`: 用 .env 文件加载环境变量

### 数据库与 ORM

- 驱动
  - `asyncpg`: PostgreSQL 的异步驱动, 性能很好
  - `sqlite3`: Python 标准库自带的 SQLite 驱动, 适合小型项目或测试环境
  - `motor`: MongoDB 的异步驱动
  - `asyncmy`: MySQL 的异步驱动

- ORM
  - `SQLAlchemy`: 最流行的 Python ORM, 支持多种数据库后端和异步
  - `SQLModel`: 基于 SQLAlchemy 和 Pydantic 的 ORM

- Migration
  - `alembic`: SQLAlchemy 官方推荐的迁移工具, 支持异步迁移 (和 Django 的 migration 类似)

### 缓存与消息队列

- 缓存
  - `redis`: 异步的 Redis 客户端

- 队列
  - `celery`: 经典的分布式任务队列, 支持多种 broker 和后端, 包括 Redis
  - `aio-pika`: RabbitMQ 的异步客户端, 适合需要消息队列但不想引入 Celery
  - `aio-kafka`: Kafka 的异步客户端

### 认证与安全

- JWT
  - `pyjwt`: 常见的 JWT 库, 支持多种算法
  - `python-jose`: 另一个常见的 JWT 库, 适合 OAuth2/JWK 场景

- 哈希
  - `hashlib`: Python 标准库自带的哈希库, 适合简单的哈希需求
  - `passlib`: 更全面的密码哈希库, 支持多种算法, 包括 bcrypt 和 argon2

- OAuth / 第三方登录
  - `authlib`: OAuth/OIDC 的常见选型

### 日志与可观测性

- 日志
  - `logging`: Python 标准库自带的日志模块, 适合简单的日志需求
  - `structlog`: 结构化日志的常见选型, 适合需要输出 JSON 格式日志的场景
  - `loguru`: 易用的日志库, 适合中小项目

- 监控
  - `prometheus-client`: Prometheus 指标库, 适合需要暴露指标的场景
  - `opentelemetry-api` / `opentelemetry-sdk`: OpenTelemetry 的核心库, 适合需要分布式追踪和指标的场景

### 测试

- `pytest`: 事实标准的 Python 测试框架, 适合单元测试和集成测试
- `pytest-asyncio`: pytest 的插件, 支持异步测试
- `faker`: 生成测试数据的库

## 如何 Vibe?

### 从已有的功能开始复制

助教在尝试的时候克隆了 Django 的仓库, 直接使用了以下 Prompt:

> Check ../2026-Django-HW for ref, implement identical product with FastAPI and async, use uv to maintain env, use modern stack, manage Git yourself. Prefer library to self-implement library logic. Use type annotation, write docs (for beginners). Use ruff to format and lint code (add to dev deps).

CodeX (gpt-5.3-codex medium) 直接一次性写完了这个项目. 这种方式更接近实际开发过程中从已有的代码库 (如用于参考的其它开源项目或希望迁移的旧项目) 进行复制和改写的流程.

### 从 API 文档开始

你也可以考虑把小作业的 API 文档给 LLM 参考, 要求它根据 API 文档的接口定义来实现后端逻辑. 这种方式更贴近实际开发中根据 API 设计来实现后端的流程.

### 从前端的接口定义开始

在实际的项目开发中, 前端可能会先定义好它需要调用的接口. 你可以把小作业的前端仓库给 LLM 参考, 让它根据前端的接口定义来实现后端逻辑. 这种方式更贴近实际开发中根据前端需求来实现后端的流程.

### 从需求文档开始...

如果确实没有什么参考, 你也可以直接把需求文档给 LLM 参考, 让它根据需求来设计 API 和实现后端逻辑. 这种方式更贴近实际开发中从需求到设计再到实现的流程. 并不推荐这样的方式, 因为这可能导致定义出很难用的 API, 导致后续返工.
