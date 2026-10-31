from sqlalchemy import select
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.category import Category


class CRUDCategory(CRUDBase):
    def get_by_name(self, db: Session, name: str) -> Category | None:
        return db.execute(select(Category).where(Category.name == name)).scalar_one_or_none()

    def list_all(self, db: Session) -> list[Category]:
        return db.execute(select(Category).order_by(Category.name)).scalars().all()


crud_category = CRUDCategory(Category)