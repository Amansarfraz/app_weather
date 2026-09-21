from typing import Optional

from pydantic import BaseModel


class FavoriteCreate(BaseModel):
    city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class FavoriteOut(BaseModel):
    id: str
    city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    added_at: str