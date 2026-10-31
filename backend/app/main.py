from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.config import settings
from app.core.exceptions import AppException, app_exception_handler, unhandled_exception_handler
from app.core.limiter import limiter
from app.core.logging import setup_logging
from app.db.init_db import run_startup


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging(settings.DEBUG)
    run_startup()
    from app.adapters.registry import init_registry
    init_registry()
    yield


app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    description="小说阅读系统后端 API",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc",
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(Exception, unhandled_exception_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.routers import health, auth, books, categories, search, comments, bookshelf, reading, admin

app.include_router(health.router)
app.include_router(auth.router, prefix="/api/v1/auth", tags=["认证"])
app.include_router(books.router, prefix="/api/v1/books", tags=["图书"])
app.include_router(categories.router, prefix="/api/v1/categories", tags=["分类"])
app.include_router(search.router, prefix="/api/v1/search", tags=["搜索"])
app.include_router(comments.router, prefix="/api/v1", tags=["评论"])
app.include_router(bookshelf.router, prefix="/api/v1/bookshelf", tags=["书架"])
app.include_router(reading.router, prefix="/api/v1/reading-progress", tags=["阅读进度"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["管理"])