# Weatherly — Weather Forecast App

Flutter + FastAPI + MongoDB + RapidAPI (open-weather13), matching the structure
you already started. This zip contains **only the files to copy into your
existing `app_weather` and `backend` folders** — drop them in and overwrite.

## What's included

**Backend** (`backend/app/`)
- `config/settings.py`, `services/weather_service.py` — unchanged, your originals.
- `database/mongodb.py` — Mongo connection (pymongo).
- `models/history_model.py` — builds the history document.
- `schemas/` — request/response shapes.
- `routers/weather_router.py` — your original `/weather/city/{city}` and
  `/weather/forecast`, **plus a new `GET /weather/full/{city}`** that does
  city → coordinates → forecast in one call and saves it to history.
- `routers/history_router.py` — **new**: `GET /history`, `POST /history`,
  `DELETE /history/{id}`, `DELETE /history` (clear all).
- `main.py` — wires up both routers.

**Flutter app** (`app_weather/lib/`)
- `models/` — `CityModel` (current weather), `ForecastItem` + `DailyForecast`
  (3-hour + 5-day grouping), `HistoryItem`.
- `services/api_service.dart` — talks to the backend, friendly error messages.
- `utils/` — colors/gradients per weather condition, constants, icon mapper.
- `widgets/` — animated search bar, glass "current weather" card (floating
  icon animation), hourly strip cards, staggered-entrance daily forecast rows.
- `screens/` — animated splash → home (search + current + next hours) →
  5-day forecast screen, and a history screen (swipe to delete, tap to
  reload that city).
- `routes/app_routes.dart` — fade/slide page transitions.
- `pubspec.yaml` — added `http`, `intl`, `google_fonts`.

No image assets are used anywhere (your `assets/images` folder was empty), so
there's nothing to configure there — every icon is drawn with Flutter's
Material icons + gradients.

## 1. Backend setup

```powershell
cd weather_backend        # or wherever backend/app lives in your project
pip install -r requirements.txt
```

Make sure MongoDB is running locally (`mongodb://127.0.0.1:27017` by default,
see `backend/app/.env`), and put your **real, regenerated** RapidAPI key in
`.env`:

```env
RAPIDAPI_KEY=your_real_key_here
RAPIDAPI_HOST=open-weather13.p.rapidapi.com
MONGO_URL=mongodb://127.0.0.1:27017
DATABASE_NAME=weather_app_db
```

Run it:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Test in the browser first** (this is Phase 3 from your original plan —
do this before touching Flutter):

- http://127.0.0.1:8000/weather/full/Sahiwal
- http://127.0.0.1:8000/history

If `/weather/full/Sahiwal` doesn't return real data, open
http://127.0.0.1:8000/docs and try `/weather/city/{city}` alone to see the
raw RapidAPI response — the field names in `CityModel`/`ForecastItem`
(`lib/models/`) are based on the standard OpenWeatherMap response shape that
`open-weather13` proxies. If your key's plan returns a different shape,
tell me the raw JSON and I'll adjust the parsing.

## 2. Flutter setup

```powershell
cd app_weather
flutter pub get
```

Open `lib/utils/app_constants.dart` and set the right `baseUrl` for how
you're running the app:

- Android emulator → `http://10.0.2.2:8000` (already set)
- iOS simulator / desktop / web → `http://127.0.0.1:8000`
- Real phone on the same Wi-Fi → `http://<your-PC-LAN-IP>:8000`

Run:

```powershell
flutter run
```

## Notes / next steps

- History currently keeps the last 20 unique cities (`MAX_HISTORY_ITEMS` in
  `history_router.py`). Change that constant to adjust.
- `pymongo` is used synchronously inside async routes, which is fine at this
  scale (a personal/student project). If you later add heavy traffic, swap
  to `motor` (the async Mongo driver) — I can do that migration for you.
- Favorite cities (from your original feature list) isn't built yet — happy
  to add it next: it would be another Mongo collection + a star icon on the
  current weather card.
