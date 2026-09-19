# Kabadiwala Connect

Kabadiwala Connect combines a multilingual Flutter collection and traceability
app with a Node.js detection backend. The backend keeps the Roboflow credential
off the mobile client and does not write uploaded images to disk.

## Flutter app

The app supports collector onboarding, scrap-photo capture, AI-assisted material
review, safety acknowledgements, price confirmation, recycler matching, QR
handover, payment tracking, local persistence, and a lot ledger.

Run it against the local backend:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001
```

For a physical Android device, replace `10.0.2.2` with the development
computer's LAN IPv4 address. Production builds must use an HTTPS backend.

## Detection backend

The backend exposes:

- `POST /api/detection/scrap` — accepts one JPEG, PNG, or WebP in multipart field
  `image` (maximum 8 MB) and returns a normalized material suggestion.
- `GET /api/health` — reports service health and whether Roboflow is configured.
- `POST /api/detect` — backward-compatible detection alias.

Copy `.env.example` to `.env` and provide the private configuration locally:

```text
PORT=5001
ROBOFLOW_API_KEY=replace_with_private_key
ROBOFLOW_PROJECT_ID=kabadiwala-scrap
ROBOFLOW_MODEL_VERSION=1
ROBOFLOW_CONFIDENCE_THRESHOLD=0.45
ROBOFLOW_OVERLAP_THRESHOLD=0.30
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

Do not commit `.env` or place the Roboflow key in Flutter source. Start and test
the backend with:

```powershell
npm install
npm test
npm run build
npm start
```

Cloud inference requires internet access and valid model credentials. Empty,
low-confidence, and unknown-only results are returned as uncertain and never
default to PCB. The AI result is an approximate suggestion; it does not certify
material composition, purity, weight, safety, or market value.

## Vercel deployment

Configure the Roboflow variables and `ALLOWED_ORIGINS` in Vercel for Preview and
Production, then deploy from the repository root. `/api` contains the serverless
entry points, while the local Node server shares the same handlers and validation.

## Verification

```powershell
npm test
npm run build
flutter analyze
flutter test
```
