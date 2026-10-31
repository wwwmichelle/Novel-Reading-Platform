from datetime import datetime

from pydantic import BaseModel


class CategoryBrief(BaseModel):
    id: str
    name: str

    model_config = {"from_attributes": True}


class CategoryCreate(BaseModel):
    name: str


class CategoryUpdate(BaseModel):
    name: str