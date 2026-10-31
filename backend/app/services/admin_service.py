from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.core.exceptions import ConflictException, NotFoundException
from app.core.logging import log_audit
from app.crud.category import crud_category
from app.crud.comment import crud_comment
from app.models.category import Category
from app.models.comment import Comment
from app.models.user import User
from app.schemas.comment import CommentResponse


class AdminService:
    async def create_category(self, db: Session, name: str, admin: User) -> dict:
        existing = crud_category.get_by_name(db, name)
        if existing:
            raise ConflictException(code="CATEGORY_EXISTS", message="分类名称已存在")
        cat = Category(name=name)
        db.add(cat)
        db.commit()
        db.refresh(cat)
        log_audit("create_category", admin.id, {"category_id": cat.id, "name": name})
        return {"id": cat.id, "name": cat.name}

    async def update_category(self, db: Session, category_id: str, name: str, admin: User) -> dict:
        cat = db.get(Category, category_id)
        if not cat:
            raise NotFoundException(code="CATEGORY_NOT_FOUND", message="分类不存在")
        existing = crud_category.get_by_name(db, name)
        if existing and existing.id != category_id:
            raise ConflictException(code="CATEGORY_EXISTS", message="分类名称已存在")
        cat.name = name
        db.commit()
        db.refresh(cat)
        log_audit("update_category", admin.id, {"category_id": category_id, "name": name})
        return {"id": cat.id, "name": cat.name}

    async def delete_category(self, db: Session, category_id: str, admin: User) -> dict:
        cat = db.get(Category, category_id)
        if not cat:
            raise NotFoundException(code="CATEGORY_NOT_FOUND", message="分类不存在")
        db.delete(cat)
        db.commit()
        log_audit("delete_category", admin.id, {"category_id": category_id})
        return {"message": "删除成功"}

    async def list_all_comments(self, db: Session, *, page: int = 1, page_size: int = 20, book_id: str | None = None) -> dict:
        skip = (page - 1) * page_size
        comments = crud_comment.list_all(db, skip=skip, limit=page_size, book_id=book_id)
        total = crud_comment.count_all(db, book_id=book_id)
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

    async def delete_comment(self, db: Session, comment_id: str, admin: User) -> dict:
        comment = db.get(Comment, comment_id)
        if not comment:
            raise NotFoundException(code="COMMENT_NOT_FOUND", message="评论不存在")
        db.delete(comment)
        db.commit()
        log_audit("delete_comment", admin.id, {"comment_id": comment_id, "book_id": comment.book_id})
        return {"message": "删除成功"}

    async def datasource_status(self) -> dict:
        adapter = get_adapter()
        health = await adapter.health_check()
        from app.core.config import settings
        return {
            "mode": settings.DATA_SOURCE_MODE,
            "status": health.get("status"),
            "message": health.get("message"),
        }


admin_service = AdminService()