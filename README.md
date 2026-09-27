# Kabadiwala Connect Flutter app

## Flutter Web on Vercel

Import this Flutter repository as a separate Vercel project (Framework Preset:
Other, Root Directory: `.`). The checked-in `vercel.json` builds the web app
using `tool/build_web.sh` and serves the generated `build/web` directory.
The web build calls `https://kabadiwala-backend.vercel.app/predict`.

After the web project has a production URL, add that exact origin to the
backend Vercel project's `ALLOWED_ORIGINS` environment variable and redeploy
the backend. Browser image uploads require this CORS setting. Test the web app
with a real image after both deployments are ready.

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

The app appends `/predict` to this HTTPS origin. `lib/config/api_config.dart`
rejects an empty, non-HTTPS, or path-bearing origin. Build the APK only after
deploying the backend and configuring its Roboflow Environment Variables:

```powershell
.\tool\build_production_apk.ps1 -BackendUrl https://kabadiwala-backend.vercel.app
```

The script checks the deployed `/health` endpoint and builds a release APK with
the HTTPS origin embedded. It requires Node.js for the health check. The APK is
distributed separately from Vercel.

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
flutter analyze
flutter test
.\tool\build_production_apk.ps1 -BackendUrl https://kabadiwala-backend.vercel.app
```

Install the resulting APK on an Android device with internet access. Capture a
known scrap item, confirm the suggestion and confidence, retry with a bad image,
and verify manual selection after an error. A passing mock test alone does not
prove the deployed model or device network path.

The same Dart HTTP client can be checked against a labeled image on a computer:

```powershell
dart run tool/live_detection_smoke.dart PATH_TO_IMAGE EXPECTED_CATEGORY
```

This smoke test does not replace testing the installed APK on a device.

Price and recycler records are clearly marked demo data, remote sync is
simulated, and model accuracy depends on the deployed dataset and version.

The AI result is an approximate suggestion. It does not certify material
composition, purity, weight, safety or market value.
