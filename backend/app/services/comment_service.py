from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException, PermissionException
from app.crud.comment import crud_comment
from app.models.comment import Comment
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentResponse


class CommentService:
    async def list_comments(self, db: Session, book_id: str, *, page: int = 1, page_size: int = 20) -> dict:
        skip = (page - 1) * page_size
        comments = crud_comment.list_by_book(db, book_id, skip=skip, limit=page_size)
        total = crud_comment.count_by_book(db, book_id)
        items = []
        for c in comments:
            user = db.get(User, c.user_id)
            items.append(CommentResponse(
                id=c.id, book_id=c.book_id, user_id=c.user_id,
                username=user.username if user else "",
                content=c.content, created_at=c.created_at,
            ))
        total_pages = (total + page_size - 1) // page_size if total > 0 else 0
        return {"items": items, "total": total, "page": page, "page_size": page_size, "total_pages": total_pages}

    async def create_comment(self, db: Session, book_id: str, user: User, req: CommentCreate) -> CommentResponse:
        from app.adapters.registry import get_adapter
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})

        recent = crud_comment.list_by_book(db, book_id, skip=0, limit=5)
        now = datetime.now(timezone.utc)
        for c in recent:
            if c.user_id == user.id and c.content == req.content and (now - c.created_at.replace(tzinfo=timezone.utc)) < timedelta(seconds=30):
                raise ConflictException(code="DUPLICATE_COMMENT", message="请勿重复提交评论")

        comment = Comment(book_id=book_id, user_id=user.id, content=req.content)
        db.add(comment)
        db.commit()
        db.refresh(comment)
        return CommentResponse(
            id=comment.id, book_id=comment.book_id, user_id=comment.user_id,
            username=user.username, content=comment.content, created_at=comment.created_at,
        )

    async def delete_comment(self, db: Session, comment_id: str, user: User) -> dict:
        comment = db.get(Comment, comment_id)
        if not comment:
            raise NotFoundException(code="COMMENT_NOT_FOUND", message="评论不存在", detail={"comment_id": comment_id})
        if comment.user_id != user.id and user.role != "admin":
            raise PermissionException(code="NOT_OWNER", message="只能删除自己的评论")
        db.delete(comment)
        db.commit()
        return {"message": "删除成功"}


comment_service = CommentService()