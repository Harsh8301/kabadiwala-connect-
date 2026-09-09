# Kabadiwala Connect — Flutter

Native Flutter port of the original static HTML/CSS/JavaScript prototype.

## Included parity

- Marathi, Hindi and English language switching
- Five-step pickup workflow and progress indicator
- Camera/gallery selection and offline sample items
- Seeded material identification confirmation
- Battery and CRT hazard acknowledgement with text-to-speech
- Material-specific value recovery tips
- Weight control and live formal/informal price calculations
- Lot pass, valid QR generation, witness image and payment preference
- Persistent local session ledger, totals, micro-impact and demo reset
- Today’s rate board with text-to-speech

All prices, confidence figures and recovery factors remain seeded demo values.

## Run

If this folder does not yet contain platform folders, run once:

```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

`image_picker` requires no additional Android configuration. For iOS, add the
following usage descriptions inside `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Select an e-waste or handover photograph.</string>
<key>NSCameraUsageDescription</key>
<string>Capture an e-waste or handover photograph.</string>
```
