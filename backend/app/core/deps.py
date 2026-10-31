from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.core.exceptions import AuthException, PermissionException
from app.core.security import decode_token
from app.db.session import get_db
from app.models.user import User


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise AuthException(code="TOKEN_MISSING", message="未提供认证令牌")
    token = authorization.removeprefix("Bearer ").strip()
    payload = decode_token(token)
    if payload.get("type") != "access":
        raise AuthException(code="TOKEN_INVALID", message="令牌类型错误")
    user_id = payload.get("sub")
    if not user_id:
        raise AuthException(code="TOKEN_INVALID", message="令牌内容无效")
    user = db.get(User, user_id)
    if not user:
        raise AuthException(code="USER_NOT_FOUND", message="用户不存在")
    return user


def require_admin(user: User = Depends(get_current_user)) -> User:
    if user.role != "admin":
        raise PermissionException(code="ADMIN_REQUIRED", message="需要管理员权限")
    return user


def get_current_user_optional(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User | None:
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        token = authorization.removeprefix("Bearer ").strip()
        payload = decode_token(token)
        if payload.get("type") != "access":
            return None
        user_id = payload.get("sub")
        if not user_id:
            return None
        return db.get(User, user_id)
    except AuthException:
        return None