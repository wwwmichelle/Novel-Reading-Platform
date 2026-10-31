import logging
import sys

SENSITIVE_KEYS = {"password", "token", "authorization", "secret", "refresh_token", "access_token"}


class SensitiveDataFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        try:
            msg = str(record.getMessage())
            for key in SENSITIVE_KEYS:
                if key.lower() in msg.lower():
                    record.msg = f"[REDACTED: contains sensitive key '{key}']"
                    record.args = ()
                    break
        except Exception:
            pass
        return True


def setup_logging(debug: bool = False):
    level = logging.DEBUG if debug else logging.INFO
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter(
            fmt="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
    )
    handler.addFilter(SensitiveDataFilter())

    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.addHandler(handler)
    root_logger.setLevel(level)

    for noisy in ["uvicorn.access", "sqlalchemy.engine"]:
        logging.getLogger(noisy).setLevel(logging.WARNING if not debug else logging.INFO)


def log_audit(action: str, user_id: str | None, detail: dict | None = None):
    logger = logging.getLogger("audit")
    logger.info(f"AUDIT | action={action} | user_id={user_id} | detail={detail or {}}")