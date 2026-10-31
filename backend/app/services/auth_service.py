from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.exceptions import AuthException, ConflictException
from app.core.security import create_access_token, create_refresh_token, hash_password, verify_password
from app.crud.user import crud_user
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, UserResponse


class AuthService:
    async def register(self, db: Session, req: RegisterRequest) -> UserResponse:
        existing = crud_user.get_by_username(db, req.username)
        if existing:
            raise ConflictException(code="USERNAME_EXISTS", message="用户名已存在")
        user = User(
            username=req.username,
            password_hash=hash_password(req.password),
            role="user",
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return UserResponse.model_validate(user)

    async def login(self, db: Session, req: LoginRequest) -> TokenResponse:
        user = crud_user.get_by_username(db, req.username)
        if not user or not verify_password(req.password, user.password_hash):
            raise AuthException(code="INVALID_CREDENTIALS", message="用户名或密码错误")
        access = create_access_token(user.id, user.role)
        refresh = create_refresh_token(user.id)
        return TokenResponse(
            access_token=access,
            refresh_token=refresh,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def refresh(self, db: Session, refresh_token: str) -> TokenResponse:
        from app.core.security import decode_token
        payload = decode_token(refresh_token)
        if payload.get("type") != "refresh":
            raise AuthException(code="TOKEN_INVALID", message="令牌类型错误")
        user_id = payload.get("sub")
        user = db.get(User, user_id)
        if not user:
            raise AuthException(code="USER_NOT_FOUND", message="用户不存在")
        access = create_access_token(user.id, user.role)
        new_refresh = create_refresh_token(user.id)
        return TokenResponse(
            access_token=access,
            refresh_token=new_refresh,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def get_current_user_info(self, user: User) -> UserResponse:
        return UserResponse.model_validate(user)

    async def logout(self) -> dict:
        return {"message": "退出成功"}


auth_service = AuthService()