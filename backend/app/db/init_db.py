import logging

from sqlalchemy import inspect, text

from app.core.config import settings
from app.core.security import hash_password
from app.db.base import Base
from app.db.session import engine, SessionLocal
from app.models import *  # noqa: F401, F403

logger = logging.getLogger(__name__)

LEGACY_EXTERNAL_FK_CONSTRAINTS = [
    ("bookshelf", "bookshelf_book_id_fkey"),
    ("bookshelf", "bookshelf_last_read_chapter_id_fkey"),
    ("comments", "comments_book_id_fkey"),
    ("reading_progress", "reading_progress_book_id_fkey"),
    ("reading_progress", "reading_progress_chapter_id_fkey"),
]


def init_database():
    inspector = inspect(engine)
    existing_tables = set(inspector.get_table_names())

    Base.metadata.create_all(bind=engine, checkfirst=True)

    new_tables = set(Base.metadata.tables.keys()) - existing_tables
    if new_tables:
        logger.info(f"Created tables: {new_tables}")
    else:
        logger.info("All tables already exist")


def drop_legacy_external_fk_constraints():
    """移除指向外部数据源图书/章节的旧外键。

    图书与章节由适配层提供，可能不落本地库，因此不允许数据库层强制引用。
    """
    if settings.is_sqlite:
        return
    inspector = inspect(engine)
    existing_tables = set(inspector.get_table_names())
    with engine.begin() as conn:
        for table, constraint in LEGACY_EXTERNAL_FK_CONSTRAINTS:
            if table in existing_tables:
                conn.execute(text(f"ALTER TABLE {table} DROP CONSTRAINT IF EXISTS {constraint}"))
    logger.info("Legacy external foreign keys checked")


def init_admin():
    from app.models.user import User

    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.role == "admin").first()
        if existing:
            logger.info("Admin user already exists, skipping initialization")
            return

        admin = User(
            username=settings.ADMIN_INIT_USERNAME,
            password_hash=hash_password(settings.ADMIN_INIT_PASSWORD),
            role="admin",
        )
        db.add(admin)
        db.commit()
        logger.info(f"Admin user '{settings.ADMIN_INIT_USERNAME}' created successfully")
    finally:
        db.close()


def run_startup():
    init_database()
    drop_legacy_external_fk_constraints()
    init_admin()