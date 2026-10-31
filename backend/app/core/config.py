from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    APP_NAME: str = "NovelReadingSystem"
    APP_ENV: str = "development"
    DEBUG: bool = True

    DATABASE_URL: str = "sqlite:///./dev.db"

    JWT_SECRET_KEY: str = "change-me-to-a-strong-random-secret-key-at-least-32-chars"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    CORS_ORIGINS: str = "http://localhost:5173,http://localhost:3000"

    ADMIN_INIT_USERNAME: str = "admin"
    ADMIN_INIT_PASSWORD: str = "change-me-to-a-strong-password"

    DATA_SOURCE_MODE: str = "demo"
    DATA_SOURCE_API_URL: str = ""
    DATA_SOURCE_TIMEOUT_SECONDS: int = 10
    DATA_SOURCE_MAX_RETRIES: int = 3
    CACHE_TTL_SECONDS: int = 300

    LOGIN_RATE_LIMIT: int = 5
    REGISTER_RATE_LIMIT: int = 5

    MAX_PAGE_SIZE: int = 50
    DEFAULT_PAGE_SIZE: int = 20

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    @property
    def is_sqlite(self) -> bool:
        return self.DATABASE_URL.startswith("sqlite")


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()