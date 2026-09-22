from fastapi import APIRouter, HTTPException

from app.auth.security import create_access_token, hash_password, verify_password
from app.database.mongodb import users_collection
from app.schemas.auth_schema import AuthResponse, LoginRequest, SignupRequest, UserOut

router = APIRouter(prefix="/auth", tags=["Auth"])


def _serialize_user(doc: dict) -> UserOut:
    return UserOut(id=str(doc["_id"]), name=doc.get("name", ""), email=doc.get("email", ""))


@router.post("/signup", response_model=AuthResponse)
async def signup(payload: SignupRequest):
    try:
        existing = users_collection.find_one(
            {"email": payload.email.lower()}
        )
        if existing:
            raise HTTPException(status_code=409, detail="An account with this email already exists")

        if len(payload.password) < 6:
            raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

        doc = {
            "name": payload.name.strip(),
            "email": payload.email.lower(),
            "password_hash": hash_password(payload.password),
        }
        result = users_collection.insert_one(doc)
        doc["_id"] = result.inserted_id

        user = _serialize_user(doc)
        token = create_access_token(subject=user.id)
        return AuthResponse(access_token=token, user=user)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/login", response_model=AuthResponse)
async def login(payload: LoginRequest):
    try:
        doc = users_collection.find_one({"email": payload.email.lower()})
        if not doc or not verify_password(payload.password, doc.get("password_hash", "")):
            raise HTTPException(status_code=401, detail="Incorrect email or password")

        user = _serialize_user(doc)
        token = create_access_token(subject=user.id)
        return AuthResponse(access_token=token, user=user)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))