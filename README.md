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
# Task 02: Predictive Maintenance Schedule

**Vehicle:** Jeep Grand Cherokee 2012 (WK) · 195,000 km  
**Data Source:** 25 service invoices (Apr 2021 – Aug 2025) from 3 verified garages  
**Report:** See `AutoPulse_Task02_Predictive_Maintenance.pdf`

---

## What This Is

A **rule-based predictive maintenance schedule** for a specific vehicle built from its actual service history. Instead of generic OEM intervals, each component gets personalized recommendations based on:

- How the vehicle is actually driven (overspeeding, smooth braking, bump stress)
- Where it's driven (Cairo urban environment, dust, stop-start traffic)
- The vehicle's age and mileage (195,000 km, 13+ years)

---

## Why This Approach?

With one vehicle and ~25 data points, statistical regression would overfit and produce useless predictions. Instead, we built a **rule-based multiplicative degradation model**:

- **Physics-grounded:** Each multiplier comes from SAE tribology literature + OEM specs
- **Auditable:** Every number has a documented reason
- **Validated:** Predictions match observed failures in the service history

Example: The model predicted tight cooling intervals before the radiator failed Dec 2024 and manifold gasket failed Mar 2025. Those failures confirmed the model was right.

---

## The Multipliers

Each maintenance interval is calculated as:

```
Adjusted Interval = OEM Baseline × M₁ × M₂ × ... × Mₙ
```

| Factor | Multiplier | Why |
|--------|-----------|-----|
| **Overspeeding** | 0.70–0.85 | Oil >110°C; 3 cooling failures in 12 months |
| **Hard bump impacts** | 0.60–0.70 | Egyptian roads; tie rods replaced early |
| **Smooth braking** | 1.25–1.40 | Brake pads lasted 60k+ km with no prior replacement |
| **Urban Cairo** | 0.70–0.85 | Stop-start acid + Saharan dust; air filter overdue |
| **High mileage (195k)** | 0.90 | Seals/gaskets sensitive at 13+ years |

---

## Key Findings

### CRITICAL (Do Immediately)
- Engine oil + filter — overdue, sludge risk
- Air filter — overdue, MAF sensor fouling risk
- Battery load test — ~30 months old

### HIGH PRIORITY (Next 15,000 km)
- Engine oil every **2,500 km** (compressed from OEM 5,000 km)
- Wheel alignment every **11,000 km** (protect tires from bump-induced wear)
- Coolant flush at **226,500 km** (monitor closely; 3 recent failures)

### MEDIUM
- Transmission fluid at 235,000 km (Mopar ATF+4 only)
- Spark plugs at ~235,000 km

### TIRES & BRAKES
- Current tires: ~51,000 km on current set, approaching end of life
- Front brake pads: Next change at ~219,851 km (extended life due to smooth braking)

---

## Files

- **AutoPulse_Task02_Predictive_Maintenance.pdf** — Full report with:
  - Section 01: Parsed service history (25 invoices, 3 garages)
  - Section 02: Modelling logic & variable accounting
  - Section 03: Adjusted maintenance schedule (next 80k km)
  - Section 04: Chronological service timeline
  - Section 05: Key findings & recommendations

- **generate_report.py** *(to be added)* — Script that produced the PDF (all calculations documented)

---

## How It Works

1. **Parse invoices** → extract dates, ODO, service type, cost
2. **Identify driving profile** → overspeeding (cooling failures), bump stress (suspension wear), braking style (pad life)
3. **Identify environment** → urban Cairo, dust, stop-start
4. **Apply multipliers** → each component gets its own M₁ × M₂ × ... × Mₙ
5. **Generate schedule** → prioritized (CRITICAL/HIGH/MEDIUM/LOW) + chronological timeline

---

## Limitations

- **One vehicle only** — Multipliers derived from this vehicle's history; generalization needs fleet data
- **Profile stability assumed** — Model assumes driving/environment profile remains consistent
- **Catastrophic failures not modeled** — Only degradation over normal use
- **No fault diagnostics** — Assumes systems are healthy before scheduling begins

