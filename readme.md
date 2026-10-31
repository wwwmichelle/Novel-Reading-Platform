# 中国现当代文学阅读与交流系统

**访问入口：** [电脑网页](http://localhost:8080) · [后端接口文档](http://localhost:8000/api/v1/docs) · [手机预览](http://10.131.131.140:8080)

## 项目介绍

基于 Vue 3 和 FastAPI 的文学阅读与交流系统，提供 30 部中国现当代文学作品，包含网页端和鸿蒙 ArkTS 前端源码。当前可直接使用电脑网页及手机浏览器版本，鸿蒙原生包尚未构建验证。

## 主要功能

支持书目浏览、分类、书名/作者搜索、注册登录、评论和个人书架。访客可浏览与搜索，收藏和发表评论需要登录。

## 书目来源与阅读方式

书目来自得到电子书和当当读书，包括《呐喊》《骆驼祥子》《家》《围城》《活着》等。详情页可前往原站阅读，试读、会员或购买要求以原站为准。本站提供书目与互动功能，默认不提供站内全文；`demo` 模式保留章节阅读和进度接口，供测试使用。


## 技术栈

| 模块 | 技术 |
| --- | --- |
| 网页前端 | Vue 3、TypeScript、Vite 6、Vue Router、Pinia、Axios |
| 后端 | Python 3.12、FastAPI、Uvicorn、Pydantic、SQLAlchemy |
| 数据库 | PostgreSQL 16；开发配置支持 SQLite |
| 认证与安全 | JWT、bcrypt、SlowAPI、Bleach |
| 鸿蒙端 | ArkTS、ArkUI |
| 部署与测试 | Docker Compose、Nginx；pytest、Vitest、Playwright |


## Docker 容器组成

项目通过 `docker-compose.yml` 启动三个服务：

| 服务 / 默认容器名 | 镜像 | 端口 | 职责 |
| --- | --- | --- | --- |
| `web` / `novelreading-web-1` | `nginx:latest`，由前端 Dockerfile 构建 | `8080 → 80` | 提供网页，转发 API 请求 |
| `backend` / `novelreading-backend-1` | 基于 `python:3.12-slim` 构建 | `8000 → 8000` | 运行 FastAPI 业务接口 |
| `postgres` / `novelreading-postgres-1` | `postgres:16` | 内部 `5432` | 保存用户、评论、书架等数据 |


## 目录结构
```text
novel-reading/
├── backend/                # 后端 API、业务逻辑、数据库模型与测试
│   ├── app/adapters/       # 来源适配与文学书目配置
│   ├── requirements.txt
│   └── Dockerfile
├── frontend-web/           # Vue 网页端、组件与测试
│   ├── src/
│   ├── nginx.conf          # 网页容器使用的 Nginx 配置
│   └── Dockerfile
├── frontend-hmos/          # 鸿蒙 ArkTS 源码
├── tests/e2e/              # 浏览器验收脚本
├── .env.example            # 环境变量示例
├── docker-compose.yml      # 容器编排
├── start.ps1               # Windows 启动脚本
└── readme.md
```

## 启动与访问

### 1. 准备环境

启动 Docker Desktop，使用 Linux 容器，在本目录打开终端。首次构建需要网络下载依赖。

仅在没有 `.env` 时执行 `Copy-Item .env.example .env`，并填写数据库密码、JWT 密钥和管理员初始密码；已有配置保留。

### 2. 启动容器

```powershell
docker compose up -d --build
```

Windows 也可执行 `.\start.ps1`，自动启动并显示访问地址。

### 3. 访问地址

| 用途 | 地址 |
| --- | --- |
| 电脑前端 | [http://localhost:8080](http://localhost:8080) |
| 后端 API | [http://localhost:8000/api/v1](http://localhost:8000/api/v1)（接口基础路径） |
| 后端接口文档 | [http://localhost:8000/api/v1/docs](http://localhost:8000/api/v1/docs) |
| 手机网页预览 | http://10.131.131.140:8080 |
| 健康检查 | [http://localhost:8080/health](http://localhost:8080/health) |

手机需与电脑连接同一 Wi-Fi，电脑和 Docker Desktop 保持运行。手机地址使用当前电脑局域网 IP，切换网络后可能变化，可运行 `start.ps1` 重新查看。当前为本机部署，无公网地址。

### 4. 常用管理命令

```powershell
docker compose ps                     # 查看状态
docker compose logs -f backend web    # 查看日志
docker compose stop                   # 停止服务
docker compose start                  # 重新启动
```

源码修改后重新执行 `docker compose up -d --build`；日常停止服务保留数据卷。


## 配置与开发说明

- 环境变量：根目录 `.env`；实际服务配置以 `docker-compose.yml` 为准。
- 精选书目：`backend/app/adapters/literature_catalogue.json`，新增来源需同步客户端链接校验。
- 网页开发：进入 `frontend-web/`，先执行 `npm ci`；`npm run dev` 启动，`npm test` 测试，`npm run build` 构建。
- 后端测试：`docker compose run --rm -e DATA_SOURCE_MODE=demo backend python -m pytest tests -q`。
- 鸿蒙工程：使用 DevEco Studio，补齐 SDK 与签名；后端地址在 `entry/src/main/resources/rawfile/config.json` 中配置。当前手机预览使用网页版。
