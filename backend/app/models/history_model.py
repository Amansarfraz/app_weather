from datetime import datetime, timezone
from typing import Optional


def build_history_document(
    city: str,
    latitude: Optional[float],
    longitude: Optional[float],
) -> dict:
    """Build the dict that gets stored in the `search_history` collection."""

    return {
        "city": city,
        "latitude": latitude,
        "longitude": longitude,
        "searched_at": datetime.now(timezone.utc).isoformat(),
    }
