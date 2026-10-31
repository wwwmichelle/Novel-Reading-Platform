from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session


class CRUDBase:
    def __init__(self, model):
        self.model = model

    def get(self, db: Session, id: str):
        return db.get(self.model, id)

    def get_multi(
        self,
        db: Session,
        *,
        skip: int = 0,
        limit: int = 20,
        order_by: Any = None,
    ):
        stmt = select(self.model)
        if order_by is not None:
            stmt = stmt.order_by(order_by)
        stmt = stmt.offset(skip).limit(limit)
        return db.execute(stmt).scalars().all()

    def count(self, db: Session) -> int:
        from sqlalchemy import func
        return db.execute(select(func.count()).select_from(self.model)).scalar_one()

    def create(self, db: Session, obj: Any):
        db.add(obj)
        db.commit()
        db.refresh(obj)
        return obj

    def update(self, db: Session, id: str, data: dict):
        obj = self.get(db, id)
        if obj:
            for key, value in data.items():
                setattr(obj, key, value)
            db.commit()
            db.refresh(obj)
        return obj

    def remove(self, db: Session, id: str) -> bool:
        obj = self.get(db, id)
        if obj:
            db.delete(obj)
            db.commit()
            return True
        return False