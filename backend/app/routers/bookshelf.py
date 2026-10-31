from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.bookshelf import BookshelfItem
from app.services.bookshelf_service import bookshelf_service

router = APIRouter()


@router.get("", response_model=list[BookshelfItem])
async def list_bookshelf(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await bookshelf_service.list_bookshelf(db, user)


@router.post("/{book_id}", status_code=201)
async def add_book(
    book_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await bookshelf_service.add_book(db, user, book_id)


@router.delete("/{book_id}")
async def remove_book(
    book_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await bookshelf_service.remove_book(db, user, book_id)