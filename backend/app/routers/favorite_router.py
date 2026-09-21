import re
from typing import List

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, HTTPException
from pymongo import DESCENDING

from app.database.mongodb import favorites_collection
from app.models.favorite_model import build_favorite_document
from app.schemas.favorite_schema import FavoriteCreate, FavoriteOut

router = APIRouter(prefix="/favorites", tags=["Favorites"])


def _serialize(doc: dict) -> dict:
    return {
        "id": str(doc["_id"]),
        "city": doc.get("city"),
        "latitude": doc.get("latitude"),
        "longitude": doc.get("longitude"),
        "added_at": doc.get("added_at"),
    }


@router.get("", response_model=List[FavoriteOut])
async def get_favorites():
    try:
        docs = favorites_collection.find().sort("added_at", DESCENDING)
        return [_serialize(doc) for doc in docs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", response_model=FavoriteOut)
async def add_favorite(payload: FavoriteCreate):
    try:
        existing = favorites_collection.find_one(
            {"city": {"$regex": f"^{re.escape(payload.city)}$", "$options": "i"}}
        )
        if existing:
            return _serialize(existing)

        doc = build_favorite_document(payload.city, payload.latitude, payload.longitude)
        result = favorites_collection.insert_one(doc)
        doc["_id"] = result.inserted_id
        return _serialize(doc)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{favorite_id}")
async def delete_favorite(favorite_id: str):
    try:
        object_id = ObjectId(favorite_id)
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid favorite id")

    try:
        result = favorites_collection.delete_one({"_id": object_id})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Favorite not found")
        return {"success": True}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/by-city/{city}")
async def delete_favorite_by_city(city: str):
    try:
        favorites_collection.delete_many(
            {"city": {"$regex": f"^{re.escape(city)}$", "$options": "i"}}
        )
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))