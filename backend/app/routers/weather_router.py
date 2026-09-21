import re

from fastapi import APIRouter, HTTPException

from app.database.mongodb import history_collection
from app.models.history_model import build_history_document
from app.services.weather_service import get_air_quality, get_city, get_forecast

router = APIRouter(prefix="/weather", tags=["Weather"])


@router.get("/city/{city}")
async def city_weather(city: str):
    try:
        data = await get_city(city)
        return {"success": True, "city": city, "data": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/forecast")
async def forecast(latitude: float, longitude: float):
    try:
        data = await get_forecast(latitude, longitude)
        return {
            "success": True,
            "latitude": latitude,
            "longitude": longitude,
            "data": data,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/full/{city}")
async def full_weather(city: str):
    try:
        city_data = await get_city(city)
    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail=f"Could not fetch weather for '{city}': {e}",
        )

    coord = city_data.get("coord") or {}
    latitude = coord.get("lat")
    longitude = coord.get("lon")

    if latitude is None or longitude is None:
        raise HTTPException(status_code=404, detail=f"City '{city}' not found")

    try:
        forecast_data = await get_forecast(latitude, longitude)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not fetch forecast: {e}")

    try:
        resolved_name = city_data.get("name", city)
        history_collection.delete_many(
            {"city": {"$regex": f"^{re.escape(resolved_name)}$", "$options": "i"}}
        )
        history_collection.insert_one(
            build_history_document(resolved_name, latitude, longitude)
        )
    except Exception:
        pass

    return {
        "success": True,
        "city": city_data,
        "forecast": forecast_data,
    }


@router.get("/by-location")
async def weather_by_location(latitude: float, longitude: float):
    try:
        forecast_data = await get_forecast(latitude, longitude)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not fetch forecast: {e}")

    forecast_list = forecast_data.get("list") or []
    city_info = forecast_data.get("city") or {}

    if not forecast_list:
        raise HTTPException(status_code=404, detail="No weather data for this location")

    nearest = forecast_list[0]

    city_shaped = {
        "coord": {"lat": latitude, "lon": longitude},
        "weather": nearest.get("weather"),
        "main": nearest.get("main"),
        "wind": nearest.get("wind"),
        "sys": {"country": city_info.get("country")},
        "timezone": city_info.get("timezone"),
        "dt": nearest.get("dt"),
        "name": city_info.get("name", "Current Location"),
    }

    try:
        resolved_name = city_shaped["name"]
        history_collection.delete_many(
            {"city": {"$regex": f"^{re.escape(resolved_name)}$", "$options": "i"}}
        )
        history_collection.insert_one(
            build_history_document(resolved_name, latitude, longitude)
        )
    except Exception:
        pass

    return {
        "success": True,
        "city": city_shaped,
        "forecast": forecast_data,
    }


@router.get("/air-quality")
async def air_quality(latitude: float, longitude: float):
    try:
        data = await get_air_quality(latitude, longitude)
        return {"success": True, "data": data}
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not fetch air quality: {e}")