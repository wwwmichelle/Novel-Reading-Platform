from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.deps import get_current_user
from app.core.limiter import limiter
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse, UserResponse
from app.services.auth_service import auth_service

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=201)
@limiter.limit(f"{settings.REGISTER_RATE_LIMIT}/minute")
async def register(request: Request, req: RegisterRequest, db: Session = Depends(get_db)):
    return await auth_service.register(db, req)


@router.post("/login", response_model=TokenResponse)
@limiter.limit(f"{settings.LOGIN_RATE_LIMIT}/minute")
async def login(request: Request, req: LoginRequest, db: Session = Depends(get_db)):
    return await auth_service.login(db, req)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(req: RefreshRequest, db: Session = Depends(get_db)):
    return await auth_service.refresh(db, req.refresh_token)


@router.get("/me", response_model=UserResponse)
async def me(user: User = Depends(get_current_user)):
    return await auth_service.get_current_user_info(user)


@router.post("/logout")
async def logout(user: User = Depends(get_current_user)):
    return await auth_service.logout()