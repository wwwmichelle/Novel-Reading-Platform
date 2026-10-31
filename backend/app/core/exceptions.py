from fastapi import Request
from fastapi.responses import JSONResponse


class AppException(Exception):
    def __init__(self, code: str, message: str, http_status: int = 400, detail: dict | None = None):
        self.code = code
        self.message = message
        self.http_status = http_status
        self.detail = detail or {}
        super().__init__(message)


class AuthException(AppException):
    def __init__(self, code: str = "AUTH_ERROR", message: str = "认证失败", http_status: int = 401, detail: dict | None = None):
        super().__init__(code, message, http_status, detail)


class NotFoundException(AppException):
    def __init__(self, code: str = "NOT_FOUND", message: str = "资源不存在", detail: dict | None = None):
        super().__init__(code, message, 404, detail)


class ValidationException(AppException):
    def __init__(self, code: str = "VALIDATION_ERROR", message: str = "参数校验失败", detail: dict | None = None):
        super().__init__(code, message, 400, detail)


class PermissionException(AppException):
    def __init__(self, code: str = "FORBIDDEN", message: str = "权限不足", detail: dict | None = None):
        super().__init__(code, message, 403, detail)


class ConflictException(AppException):
    def __init__(self, code: str = "CONFLICT", message: str = "资源冲突", detail: dict | None = None):
        super().__init__(code, message, 409, detail)


class RateLimitException(AppException):
    def __init__(self, code: str = "RATE_LIMIT", message: str = "请求过于频繁", detail: dict | None = None):
        super().__init__(code, message, 429, detail)


class DataSourceException(AppException):
    def __init__(self, code: str = "DATASOURCE_ERROR", message: str = "数据源不可用", detail: dict | None = None):
        super().__init__(code, message, 503, detail)


async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.http_status,
        content={"code": exc.code, "message": exc.message, "detail": exc.detail},
    )


async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=500,
        content={"code": "INTERNAL_ERROR", "message": "服务器内部错误", "detail": {}},
    )