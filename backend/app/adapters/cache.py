import hashlib
from cachetools import TTLCache

from app.core.config import settings

_cache: TTLCache = TTLCache(maxsize=256, ttl=settings.CACHE_TTL_SECONDS)


def _cache_key(method: str, *args) -> str:
    raw = f"{method}:{':'.join(str(a) for a in args)}"
    return hashlib.md5(raw.encode()).hexdigest()


def get_cached(method: str, *args):
    key = _cache_key(method, *args)
    return _cache.get(key)


def set_cached(method: str, value, *args):
    key = _cache_key(method, *args)
    _cache[key] = value


def clear_cache():
    _cache.clear()


def clear_cache_by_prefix(method: str):
    keys_to_delete = [k for k in _cache if True]
    for k in keys_to_delete:
        _cache.pop(k, None)