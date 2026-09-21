from typing import Any, Dict

from pydantic import BaseModel


class WeatherResponse(BaseModel):
    """Shape of the combined /weather/full/{city} response.

    Kept loose (Dict[str, Any]) on purpose: the raw RapidAPI/OpenWeather
    payload has many optional fields and we don't want a schema mismatch
    to break the endpoint. This is mostly here for API documentation.
    """

    success: bool
    city: Dict[str, Any]
    forecast: Dict[str, Any]
