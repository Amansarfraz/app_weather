import httpx

from app.config.settings import (
    RAPIDAPI_KEY,
    RAPIDAPI_HOST
)


BASE_URL = f"https://{RAPIDAPI_HOST}"


HEADERS = {
    "x-rapidapi-host": RAPIDAPI_HOST,
    "x-rapidapi-key": RAPIDAPI_KEY
}


async def get_city(city: str):

    url = f"{BASE_URL}/city"

    params = {
        "lang": "EN",
        "city": city
    }

    async with httpx.AsyncClient() as client:

        response = await client.get(
            url,
            headers=HEADERS,
            params=params,
            timeout=20
        )

    response.raise_for_status()

    return response.json()


async def get_forecast(latitude: float, longitude: float):

    url = f"{BASE_URL}/fivedaysforcast"

    params = {
        "lang": "EN",
        "longitude": longitude,
        "latitude": latitude
    }

    async with httpx.AsyncClient() as client:

        response = await client.get(
            url,
            headers=HEADERS,
            params=params,
            timeout=20
        )

    response.raise_for_status()

    return response.json()


async def get_air_quality(latitude: float, longitude: float):
    """
    Air quality from Open-Meteo — free, no API key required.
    Returns US AQI, European AQI, and individual pollutant concentrations.
    """

    url = "https://air-quality-api.open-meteo.com/v1/air-quality"

    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": "us_aqi,european_aqi,pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone",
    }

    async with httpx.AsyncClient() as client:

        response = await client.get(
            url,
            params=params,
            timeout=20
        )

    response.raise_for_status()

    return response.json()