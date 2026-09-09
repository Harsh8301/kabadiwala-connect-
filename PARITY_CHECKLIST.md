# Web-to-Flutter parity checklist

Source audited: `https://github.com/Harsh8301/kabadiwala.git`

| Original behavior | Flutter implementation |
|---|---|
| Marathi-first UI, Hindi and English switch | In-memory language switch across every screen |
| Mobile-width responsive shell | Native responsive shell capped at 480 px on desktop/web |
| Home hero and feature badges | Native gradient hero, actions and recent record |
| Today’s seeded rate drawer | Native bottom sheet with the same five material rates |
| Browser speech synthesis | `flutter_tts` with `mr-IN`, `hi-IN`, `en-IN` |
| Camera/gallery file inputs | Native `image_picker` camera and gallery |
| Four guaranteed offline samples | Native sample cards with the same detected categories |
| 1.1-second recognition animation | Native scanning overlay with the same delay/model label |
| 89% seeded suggestion | Same value and user-confirmed category selection |
| Seven material categories | Same categories, names, rates, hazards and tips |
| Battery/CRT full-screen warning | Native blocking warning with auto/replay speech |
| Value recovery interstitial | Native material-specific modal with speech |
| Weight input, slider and +/- controls | Native 0.1–100 kg state, 0.1–25 kg slider, +/-0.5 kg |
| Formal/informal/additional value | Same rounded formulas and seeded rates |
| Generated lot ID | Same `KWC-2026-####` format |
| Canvas QR-like pattern | Replaced with a standards-compliant scannable QR containing the same payload |
| Optional witness image/sample | Native camera plus offline sample evidence |
| Cash/UPI preference | Same default and toggle behavior; no payment processing |
| Confirmation dialog | Native accidental-tap prevention dialog |
| localStorage ledger | `SharedPreferences` persistent JSON ledger |
| Ledger totals and micro-impact | Same category-specific factors and calculations |
| Recent handover card and QR view | Same behavior with a valid QR dialog |
| Restart demo | Confirmed reset clears the persistent ledger |

No backend, live pricing, production ML classification, face recognition or
payment processing was added, because the source prototype explicitly does not
provide those functions.
