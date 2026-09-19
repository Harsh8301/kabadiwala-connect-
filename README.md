# Kabadiwala Connect Flutter app

Mobile-first, multilingual collection and traceability app for informal scrap
collectors and formal recyclers. The active entry point is `lib/main.dart`,
which starts `MinistryApp` and restores the saved collector session before
showing onboarding or the dashboard.

## Main flow

1. Onboard with a valid 10-digit Indian mobile number and select Marathi,
   Hindi, or English.
2. Capture a rear-camera photo or select a gallery image. The picker resizes and
   compresses large images before upload and shows a preview immediately.
3. The app posts the photo as multipart field `image` to the secure backend.
4. The review UI shows the approximate AI suggestion, confidence, and any
   bounding boxes. The collector confirms or changes the material.
5. Battery and CRT require a localized, explicit safety acknowledgement.
6. The confirmed material—not the original AI value—drives price, safety,
   recycler matching, QR data, handover, payment, sync, and ledger records.

The app never calls Roboflow directly and contains no Roboflow key.

## API configuration

One compile-time value controls the backend base URL:

```text
API_BASE_URL
```

The app appends `/api/detection/scrap`. Defaults and examples:

```powershell
# Android emulator (default)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001

# Physical Android device on the same Wi-Fi network
flutter run --dart-define=API_BASE_URL=http://LAPTOP_IPV4_ADDRESS:5001

# Production
flutter run --release `
  --dart-define=API_BASE_URL=https://DEPLOYED_BACKEND_DOMAIN
```

For a physical device, bind the local development server to an address reachable
on the LAN, permit the chosen port in the firewall, and use the laptop's IPv4
address. Production builds must use an HTTPS backend and must not point to
localhost.

## Local setup

Start the backend first:

```powershell
cd ..\kabadiwala-backend
npm install
npx vercel dev --local --listen 5001
```

Then run the app:

```powershell
cd ..\kabadiwala-flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001
```

## Offline and error behavior

Roboflow cloud inference requires internet. Offline, timeout, invalid response,
bad configuration, rate-limit, and server errors keep the selected photo
visible and leave manual material selection available. Retry is available when
online. Failed or uncertain inference never defaults to PCB. A newly selected
single-item photo supersedes an older pending request; stale results are ignored.

Only the scrap-identification photo is sent to the detection backend. Handover
or witness images are not sent to Roboflow. Existing local lot storage remains
part of the traceability product flow.

## Localization, safety, and accessibility

Safety headings, Battery/CRT-specific instructions, acknowledgement actions,
offline fallback, phone errors, and AI status text come from the shared
English/Hindi/Marathi map in `lib/data/ministry_data.dart`. Language changes
rebuild an open warning immediately. Changing a selected material clears its
prior safety acknowledgement.

The onboarding number field uses a numeric keyboard, a 10-character limit, and
a formatter that rejects—not silently cleans—letters, spaces, symbols, decimal
points, negative signs, overlong input, and invalid pasted text. The Continue
action stays disabled until exactly ten digits are present; controller-side
validation enforces the same rule.

The generated transparent logo is stored at
`assets/branding/kabadiwala_connect_logo.png`. It is used responsively on the
landing page and on a 1.6-second minimum animated in-app splash. The native
Android launch background uses a resized transparent copy and the same cream
background, avoiding a blank frame or visible logo rectangle.

## Verification

```powershell
dart format .
flutter analyze
flutter test
flutter build web --no-wasm-dry-run `
  --dart-define=API_BASE_URL=https://DEPLOYED_BACKEND_DOMAIN
flutter build apk --debug `
  --dart-define=API_BASE_URL=http://10.0.2.2:5001
```

Live end-to-end inference cannot be verified until the private key is added to
the backend environment. Price and recycler records are clearly marked demo
data, remote sync is simulated, and model accuracy depends on the deployed
dataset and version.

The AI result is an approximate suggestion. It does not certify material
composition, purity, weight, safety or market value.
