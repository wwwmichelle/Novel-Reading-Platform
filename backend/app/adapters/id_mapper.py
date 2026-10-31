import hashlib
from uuid import UUID


_id_map: dict[str, str] = {}


def _stable_uuid(seed: str) -> str:
    hashed = hashlib.md5(seed.encode("utf-8")).hexdigest()
    return str(UUID(int=int(hashed[:32], 16)))


def map_external_id(source: str, external_id: str) -> str:
    key = f"{source}:{external_id}"
    if key not in _id_map:
        _id_map[key] = _stable_uuid(key)
    return _id_map[key]


def get_internal_id(source: str, external_id: str) -> str | None:
    return _id_map.get(f"{source}:{external_id}")


def clear_mapping():
    _id_map.clear()