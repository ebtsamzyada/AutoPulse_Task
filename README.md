## Task 01 — Maintenance Record Extraction

An app that extracts maintenance record data from scanned documents using on-device OCR and local pattern matching. No internet or API keys required — works completely offline. 

## Architecture

**Two-Stage Pipeline (100% Offline):**
1. **ML Kit OCR** - Extracts text from images (on-device, English only)
2. **Regex Patterns** - Structures 7 fields using pure Dart regex (zero API calls)

**Why Offline?** Although APIs would have been ideal and more accurate, Tested APIs (Gemini blocked by region, Groq deprecated, Claude paid) — local processing was the only viable option.

** English Only** - ML Kit supports Latin script only. Arabic text is ignored for now
one possible solution is using Tesseract, yet when tested, it was too unstable and crashed the emulator on Android, so it was not a viable option for this project.

## Build & Run

```bash
cd autopulse_challenge
flutter pub get
flutter build apk --release          # APK: build/app/outputs/flutter-apk/app-release.apk
adb install -r build/app/outputs/flutter-apk/app-release.apk
flutter run -d emulator-5554         # Debug mode
```

## Usage

1. Launch app → Select source (camera, gallery, or PDF)
2. Scan document
3. Review & edit 7 extracted fields
4. Done

---

## Tech Stack

- **Flutter 3.0+** - UI framework
- **Google ML Kit v0.13.1** - OCR engine (offline, on-device)
- **Dart Regex** - Field extraction (100% offline, zero API calls, zero dependencies)
- **image_picker, file_picker** - Image/PDF selection
- **pdfx v2.6.0** - PDF support

---

## Project Structure

```
lib/
├── main.dart
├── core/theme/app_theme.dart
└── features/ocr_scan/
    ├── data/services/
    │   ├── ocr_service.dart        (ML Kit OCR wrapper)
    │   ├── llm_parser_service.dart (Regex-based field extraction - 100% offline)
    │   └── pdf_converter.dart      (PDF → images)
    ├── domain/maintenance_record.dart
    └── presentation/
        ├── screens/ (scan_screen, review_screen)
        └── widgets/ (source_picker, field_tile, progress)
```

## Extraction Patterns

7 Regex patterns extract fields from raw OCR text (all 100% offline):
- **Service Date**: Flexible date formats (DD/MM/YYYY, DD-MM-YYYY, etc.)
- **Mileage**: Numbers with commas/spaces (e.g., "42, 500 km")
- **Labour Cost**: Decimal amounts
- **Parts Cost**: Decimal amounts
- **Workshop Name**: Free-text extraction
- **Next Service Due**: Flexible number formats with comma-space handling
- **Parts List**: Keyword matching (oil, filter, brake, tire, battery, coolant, spark plug, transmission, engine, alternator, compressor, fan, belt, pad, rotor, hose, pump, seal, gasket)

---

## Data Model

```dart
MaintenanceRecord {
  id: String
  serviceDate: String?
  mileageKm: int?
  partsReplaced: List<String>
  labourCostEgp: double?
  partsCostEgp: double?
  workshopName: String?
  nextServiceDueKm: int?
  fieldConfidence: Map<String, double>  // 0.0 = missing, 0.9 = found
}
```

---

## Limitations

- **English only** - Arabic text not supported
- **Handwriting accuracy** - Depends on image quality
- **No persistence** - Records reviewed but not automatically saved

---

## Task 02 — Predictive Maintenance Schedule

The goal here was to build a personalized maintenance schedule for a 2012 Jeep with 195,000 km based on 4 years of real service history (25 invoices from verified garages).

### Why Not Machine Learning?

The honest answer: we only have one vehicle and ~25 data points. Statistical models like regression need a large population of vehicles to work properly — otherwise they just fit the noise in your data and produce useless predictions. Instead, we built a **rule-based multiplicative degradation model** grounded in actual engineering literature and validated against what actually happened to this vehicle.

### Why Multiplicative Degradation?

Wear doesn't add up — it compounds. Running an engine on hot degraded oil in dusty air kills it faster than running it on hot oil alone, or dusty air alone. Multiplying the stress factors together captures this interaction correctly. If we just added them up, we'd be too optimistic about what this vehicle can handle.

### How We Calibrated the Multipliers

Two things informed every number:

1. **Engineering & OEM specs** — SAE tribology papers tell us oil degrades exponentially above 110°C, Jeep's severe-duty guidelines give baseline intervals, etc.

2. **The actual service history as ground truth** — We looked at what actually failed and when:
   - **Cooling system:** Radiator failed Dec 2024, manifold gasket Mar 2025, coolant flushed twice → clearly thermal overstress → tightened coolant interval
   - **Brake pads:** Lasted from ~133,000 km to 175,851 km with zero prior replacement → smooth, gentle braking confirmed → extended pad life multiplier
   - **Tie rods:** Replaced at 164,092 km instead of the typical 80,000+ km life → but the service history shows constant bump damage on Egyptian roads → confirmed the hard-impact multiplier is real
   - **Oil intervals:** Observed 6,000–8,000 km gaps with evidence of thermal stress → justified the 2,500 km adjusted interval

### Key Decisions We Made

| What We Did | Why |
|---|---|
| **Oil → 2,500 km** | Overspeeding (0.70) × urban Cairo (0.85) × high mileage (0.90) = 0.535 of the baseline 5,000 km |
| **Shocks/ball joints reset from 196,772 km** | They were just replaced Aug 2025 — starting the count from the baseline 195,000 km would be cheating |
| **Brake pads reset from 175,851 km** | Replaced Jun 2024, already 19,149 km consumed — track the new life, not the whole life |
| **Cooling interval tightened** | Three failures in 12 months means this system is maxed out; can't relax |
| **Smooth braking extends pad life ~40%** | No replacement found in 42k km of recorded history — the data supports it |
| **Skip service listed separately** | Current overdue items (oil, air filter) are deficiencies, not future wear rates — handled as Day 0 emergencies |

The point: every decision ties back to something observable in the real invoices.

