from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.auth_router import router as auth_router
from app.routers.favorite_router import router as favorite_router
from app.routers.history_router import router as history_router
from app.routers.weather_router import router as weather_router

app = FastAPI(
    title="Weather App API",
    description="Weather Forecast API using RapidAPI + MongoDB",
    version="1.0.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(weather_router)
app.include_router(history_router)
app.include_router(favorite_router)
app.include_router(auth_router)


@app.get("/")
async def root():
    return {"message": "Weather App API is running"}