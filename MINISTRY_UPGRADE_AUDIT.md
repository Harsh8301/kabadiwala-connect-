# Kabadiwala Connect - Ministry of Mines Upgrade Audit

## A. Original architecture

The inspected application was a Flutter Material 3 prototype using one
`ChangeNotifier` controller, enum-based in-memory navigation, `SharedPreferences`
JSON storage, `image_picker`, `geolocator`, `qr_flutter`, `flutter_tts`, and an
HTTP service for the separate `kabadiwala-backend` Vercel `/api/detect` endpoint.

The original production path represented one material, one weight, and one lot.
It had a usable single-item flow, real GPS permission handling, QR generation,
manual material correction, basic recycler selection, payment preference, and a
persistent ledger. Prices and recycler records were seeded. Remote sync, batch
lots, price history, and full handover state were absent.

## B. Original feature inventory

Working before this upgrade:

- English, Hindi, and Marathi labels for the core five-step flow
- Camera/gallery capture with compressed image selection
- Secure Roboflow request through `/api/detect`, plus manual fallback
- Single material confirmation, safety dialog, weight and price estimate
- Device GPS request with an honest unavailable state
- Scannable QR payload, witness photo, cash/UPI preference
- Seeded recycler matching and recycler receipt confirmation
- Local persistent single-material ledger and basic totals

Partially implemented or UI-only before this upgrade:

- Onboarding stored only in controller memory
- Recycler authorization was explicitly placeholder data
- Payment recorded preference/status but processed no payment
- Prices were static current rates with no structured history
- Offline support persisted completed ledger records only
- Recycler view could confirm receipt but not correct final weight/value

## C. Gap analysis and outcome

| Requirement | Original state | Upgrade status | Action/outcome |
|---|---|---|---|
| Minimal collector profile | Partial | Complete | Persistent ID, language, operating location |
| Collector dashboard | Partial | Complete | Start, prices, lots, earnings, safety, sync, language, summary |
| Batch/single modes | Missing | Complete | Batch is recommended; single remains available |
| Multiple photos | Missing | Complete | Up to eight compressed gallery photos or camera captures |
| Multi-material grouping | Missing | Complete | Roboflow predictions group by category; manual add/edit/remove always works |
| Material categories | Partial | Complete | PCB, cables, battery, CRT, LCD, motor, magnets, mixed plastics |
| Material information | Partial | Complete | Data-driven subcategory, recoverables, hazard, handling |
| Contextual safety | Partial | Complete | Material warnings, dedicated section, speech controls |
| Material-wise weight | Missing | Complete | Quantity, condition, weight, validation, total |
| Structured prices/history | Missing | Complete (demo) | Typed records, location, range, rate, 7-day history and trends |
| Price board | Partial drawer | Complete (demo) | Search, material/location controls, cards, chart, spoken price |
| Digital multi-material lot | Missing | Complete | KBC ID, materials, images, GPS, values, status and sync fields |
| Meaningful QR route | Partial | Complete | QR serializes the local traceability record; lot detail resolves it locally |
| GPS and denial state | Complete | Complete | Real permission path retained; demo location is explicitly labelled |
| Recycler dataset | Partial | Complete (demo) | Typed replaceable records; every entry says verification required |
| Recycler matching | Partial | Complete (rule-based) | Compatibility, distance, rates, pickup and visible reasons/score |
| Recycler details/actions | Partial | Partial | Select and pickup state work; call/directions clearly report unsupported integration |
| Recycler dashboard | Partial | Complete (demo) | Incoming lots, weight/value metrics, open/confirm flow |
| Documented handover | Partial | Complete | Expected/final weight, final value, GPS, evidence photo, timestamp/status history |
| Transaction statuses | Partial | Complete | Typed workflow statuses and status event history |
| Cash/optional digital | Partial | Complete (state) | Cash-first; digital is explicitly simulated and optional |
| Earnings ledger | Partial | Complete | Persistent totals, paid/pending filters, material and recycler summaries |
| Offline local records | Partial | Complete | Profile/lots/reference data work locally; new lots become Pending Sync |
| Sync queue | Missing | Complete (demo remote) | Retry, failed state, deduplication, last-sync timestamp |
| Low-end optimization | Partial | Complete for prototype | Image compression/limits, lazy lists, restrained animation/dependencies |
| Three-language workflow | Partial | Complete for primary labels | Primary collector workflow labels translated; detailed demo metadata stays English |
| Spoken information | Partial | Complete | Price and safety speech; service safely no-ops when unavailable |
| Anomaly detection | Missing | Complete (rule-based) | Final values outside seeded ranges trigger a labelled warning |
| Real remote backend | Missing | Not implemented | Repository interface and demo remote are ready for a production API |
| Verified recycler registry | Missing | Not implemented | Requires CPCB/SPCB or another authoritative source |
| Live market prices | Missing | Not implemented | Requires a verified feed; all current prices say Demo Reference Data |
| Real payment gateway | Missing | Not implemented | No money is transferred by this prototype |
| QR camera scanner | Missing | Partial | QR is valid; recycler can open incoming records, but camera scanning needs integration |

## D. Implemented architecture

- `workflow_models.dart`: typed collector, material, price, recycler, lot,
  location, payment, status history, and sync records
- `workflow_repositories.dart`: local/remote contracts, SharedPreferences local
  repository, and deduplicating demo remote
- `workflow_services.dart`: valuation, rule-based recycler recommendation,
  rule-based anomaly detection, and sync queue
- `ministry_controller.dart`: collector/recycler workflow and persistent state
- Screen modules split into dashboard/reference, collection, and traceability
  responsibilities
- Existing secure `DetectionService`, theme, GPS, QR, image picker, and TTS are
  reused rather than replaced

## E. Real and demo functionality

Real/device-backed in the prototype:

- Android/web Flutter UI and navigation
- Local profile/lot persistence
- Camera/gallery image selection and compression
- Device GPS permission and coordinates
- Valid QR generation with lot metadata
- Text-to-speech when the platform supports it
- Roboflow calls when the secure endpoint and credentials are configured

Demo, mock, or rule-based:

- Price records and seven-day history
- Recycler records and authorization details
- Recycler match score
- Anomaly warning
- Remote sync destination
- UPI/digital payment status

## F. Automated and manual scenarios

Automated coverage includes valuation, batch totals, zero-weight validation,
material grouping behavior, recycler scoring, anomaly detection, lot JSON/QR
traceability, failed-sync retry, sync deduplication, duplicate receipt blocking,
cash completion, ledger totals, translations, and Roboflow response handling.

The widget journey executes onboarding, English selection, batch mode, manual
material entry, weight entry, demo GPS, lot/QR creation, recycler selection,
receipt confirmation, cash-paid state, and ledger update at a 360 x 640 logical
viewport. Controller tests also cover offline lot creation and reconnection sync
behavior. Camera hardware, GPS permission dialogs, and real Roboflow inference
require a physical/emulated device and configured credentials.

## G. Updated application flow

Collector:

`Onboarding -> Dashboard -> Batch/Single -> Photos + AI/manual grouping -> Material review + safety -> Material weights + price estimate -> Lot + GPS + QR -> Recycler match -> Handover + final values -> Cash/Digital state -> Ledger`

Recycler:

`Recycler dashboard -> Incoming lot -> Lot/QR record -> Final weight/value -> Rule-based anomaly check -> Confirm receipt -> Payment status -> Completed transaction`

Offline:

`Local workflow -> Pending Sync -> Retry/reconnect -> Demo remote upload -> Synced`,
with lot ID and sync state preventing a second upload.

## H. Recommended next development steps

1. Configure and validate the actual Roboflow model/classes using field images.
2. Replace `DemoRemoteRepository` with authenticated collector/lot APIs.
3. Import verified recycler registrations and contacts from an authoritative registry.
4. Connect a verified price feed while retaining cached reference records.
5. Add a camera QR scanner and deep-linkable server lot route.
6. Run the documented field study with at least two collectors/aggregators.
7. Execute physical Android tests for camera, denied/allowed GPS, Marathi/Hindi TTS,
   offline restart, reconnection, and low-memory behavior.
