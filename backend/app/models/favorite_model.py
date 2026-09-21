from datetime import datetime, timezone
from typing import Optional


def build_favorite_document(
    city: str,
    latitude: Optional[float],
    longitude: Optional[float],
) -> dict:
    return {
        "city": city,
        "latitude": latitude,
        "longitude": longitude,
        "added_at": datetime.now(timezone.utc).isoformat(),
    }