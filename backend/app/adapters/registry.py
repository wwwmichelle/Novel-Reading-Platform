from app.adapters.base import DataSourceAdapter
from app.core.config import settings

_adapter: DataSourceAdapter | None = None


def init_registry():
    global _adapter
    mode = settings.DATA_SOURCE_MODE.lower()
    if mode == "demo":
        from app.adapters.demo import DemoDataAdapter
        _adapter = DemoDataAdapter()
    elif mode == "real":
        from app.adapters.real import RealDataAdapter
        _adapter = RealDataAdapter()
    else:
        from app.adapters.demo import DemoDataAdapter
        _adapter = DemoDataAdapter()


def get_adapter() -> DataSourceAdapter:
    if _adapter is None:
        init_registry()
    return _adapter