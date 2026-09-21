from typing import Optional

from pydantic import BaseModel


class HistoryCreate(BaseModel):
    city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class HistoryOut(BaseModel):
    id: str
    city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    searched_at: str
