
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

