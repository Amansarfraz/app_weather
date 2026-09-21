import re
from typing import List

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, HTTPException
from pymongo import DESCENDING

from app.database.mongodb import history_collection
from app.models.history_model import build_history_document
from app.schemas.history_schema import HistoryCreate, HistoryOut

router = APIRouter(prefix="/history", tags=["History"])

MAX_HISTORY_ITEMS = 20


def _serialize(doc: dict) -> dict:
    return {
        "id": str(doc["_id"]),
        "city": doc.get("city"),
        "latitude": doc.get("latitude"),
        "longitude": doc.get("longitude"),
        "searched_at": doc.get("searched_at"),
    }


@router.get("", response_model=List[HistoryOut])
async def get_history():
    try:
        docs = (
            history_collection.find()
            .sort("searched_at", DESCENDING)
            .limit(MAX_HISTORY_ITEMS)
        )
        return [_serialize(doc) for doc in docs]

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", response_model=HistoryOut)
async def add_history(payload: HistoryCreate):
    try:
        # If the same city was searched before, drop the old entry so the
        # new search moves back to the top of the list instead of duplicating.
        history_collection.delete_many(
            {"city": {"$regex": f"^{re.escape(payload.city)}$", "$options": "i"}}
        )

        doc = build_history_document(payload.city, payload.latitude, payload.longitude)
        result = history_collection.insert_one(doc)
        doc["_id"] = result.inserted_id

        # Keep only the most recent MAX_HISTORY_ITEMS entries.
        overflow = list(
            history_collection.find()
            .sort("searched_at", DESCENDING)
            .skip(MAX_HISTORY_ITEMS)
        )
        for item in overflow:
            history_collection.delete_one({"_id": item["_id"]})

        return _serialize(doc)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{history_id}")
async def delete_history_item(history_id: str):
    try:
        object_id = ObjectId(history_id)
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid history id")

    try:
        result = history_collection.delete_one({"_id": object_id})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="History item not found")
        return {"success": True}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("")
async def clear_history():
    try:
        history_collection.delete_many({})
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
