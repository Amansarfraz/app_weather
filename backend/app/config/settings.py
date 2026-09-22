import os
from pathlib import Path

from dotenv import load_dotenv

# app/config/settings.py -> parent is app/config, parent.parent is app/
# so this always finds app/.env no matter which folder you run uvicorn from.
ENV_PATH = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=ENV_PATH)

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")

RAPIDAPI_HOST = os.getenv(
    "RAPIDAPI_HOST",
    "open-weather13.p.rapidapi.com"
)

MONGO_URL = os.getenv(
    "MONGO_URL",
    "mongodb://127.0.0.1:27017"
)

DATABASE_NAME = os.getenv(
    "DATABASE_NAME",
    "weather_app_db"
)

if not RAPIDAPI_KEY:
    raise RuntimeError(
        f"RAPIDAPI_KEY is missing. Checked for a .env file at: {ENV_PATH}\n"
        "Make sure that file exists and has a line like:\n"
        "RAPIDAPI_KEY=your_real_key_here"
    )

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-this-secret-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days