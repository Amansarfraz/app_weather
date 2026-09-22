from pymongo import MongoClient

from app.config.settings import MONGO_URL, DATABASE_NAME

_client = MongoClient(MONGO_URL)
_db = _client[DATABASE_NAME]

# Collection that stores the user's search history.
history_collection = _db["search_history"]

# Collection that stores the user's favorite (starred) cities.
favorites_collection = _db["favorite_cities"]

# Collection that stores registered user accounts.
users_collection = _db["users"]


def get_database():
    return _db