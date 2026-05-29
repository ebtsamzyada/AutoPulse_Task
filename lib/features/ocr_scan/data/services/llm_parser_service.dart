import 'package:flutter/foundation.dart';
import '../../domain/maintenance_record.dart';

class LlmParserService {
  /// Parse OCR text into structured maintenance record using local pattern matching
  /// Works 100% offline — no API calls
  Future<MaintenanceRecord> parse(String ocrText) async {
    if (kDebugMode) {
      print('[Parser] Input text: $ocrText');
    }

    try {
      // Generate unique ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Extract fields using pattern matching
      final lowerText = ocrText.toLowerCase();

      // Service Date - match any date format (DD/MM/YYYY or MM/DD/YYYY)
      final serviceDateMatch = RegExp(
        r'(?:date|تاريخ)\s*[:=]?\s*(\d{1,4}[-/]\d{1,2}[-/]\d{1,4})',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Mileage - extract numbers, ignore commas/spaces in the capture
      final mileageMatch = RegExp(
        r'(?:mileage|km|كيلومتر|car mileage)\s*[:=]?\s*([\d,\s]+?)(?:\s|$|km)',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Labour Cost
      final labourCostMatch = RegExp(
        r'(?:labour|labor|labour cost|عمل)\s*[:=]?\s*([\d.]+)',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Parts Cost
      final partsCostMatch = RegExp(
        r'(?:parts|parts cost|أجزاء)\s*[:=]?\s*([\d.]+)',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Workshop Name
      final workshopMatch = RegExp(
        r'(?:workshop|garage|ورشة)\s*[:=]?\s*([^\n]+?)(?:\n|date|$)',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Next Service - handle commas/spaces in numbers (e.g., "42, 500" or "42,500")
      final nextServiceMatch = RegExp(
        r'(?:next\s+service|service\s+due|الخدمة\s+التالية)\s*[:=]?\s*([\d,\s]+?)\s*km',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(lowerText);

      // Parts replaced
      final partsList = _extractParts(ocrText);

      // Parse extracted values
      final serviceDateStr = serviceDateMatch?.group(1)?.trim() ?? '';
      final mileageStr =
          mileageMatch?.group(1)?.replaceAll(RegExp(r'[,\s]'), '') ?? '';
      final labourCostStr = labourCostMatch?.group(1)?.trim() ?? '';
      final partsCostStr = partsCostMatch?.group(1)?.trim() ?? '';
      final workshopStr =
          workshopMatch?.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
      final nextServiceStr =
          nextServiceMatch?.group(1)?.replaceAll(RegExp(r'[,\s]'), '') ?? '';

      if (kDebugMode) {
        print(
            '[Parser] Extracted: date=$serviceDateStr, mileage=$mileageStr, labour=$labourCostStr, parts=$partsCostStr, workshop=$workshopStr, nextService=$nextServiceStr');
      }

      return MaintenanceRecord(
        id: id,
        serviceDate: serviceDateStr.isNotEmpty ? serviceDateStr : null,
        mileageKm: mileageStr.isNotEmpty ? int.tryParse(mileageStr) : null,
        partsReplaced: partsList,
        labourCostEgp:
            labourCostStr.isNotEmpty ? double.tryParse(labourCostStr) : null,
        partsCostEgp:
            partsCostStr.isNotEmpty ? double.tryParse(partsCostStr) : null,
        workshopName: workshopStr.isNotEmpty ? workshopStr : null,
        nextServiceDueKm:
            nextServiceStr.isNotEmpty ? int.tryParse(nextServiceStr) : null,
        fieldConfidence: {
          'service_date': serviceDateStr.isNotEmpty ? 0.9 : 0.0,
          'mileage_km': mileageStr.isNotEmpty ? 0.9 : 0.0,
          'parts_replaced': partsList.isNotEmpty ? 0.9 : 0.0,
          'labour_cost_egp': labourCostStr.isNotEmpty ? 0.9 : 0.0,
          'parts_cost_egp': partsCostStr.isNotEmpty ? 0.9 : 0.0,
          'workshop_name': workshopStr.isNotEmpty ? 0.9 : 0.0,
          'next_service_due_km': nextServiceStr.isNotEmpty ? 0.9 : 0.0,
        },
      );
    } catch (e) {
      if (kDebugMode) print('[Parser] Error: $e');
      throw Exception('Text parsing failed: $e');
    }
  }

  /// Extract parts list from OCR text
  List<String> _extractParts(String text) {
    final keywords = [
      'oil',
      'filter',
      'brake',
      'tire',
      'battery',
      'coolant',
      'spark plug',
      'transmission',
      'engine',
      'alternator',
      'compressor',
      'fan',
      'belt',
      'pad',
      'rotor',
      'hose',
      'pump',
      'seal',
      'gasket',
      'زيت',
      'فلتر',
      'فرامل',
      'إطار',
      'بطارية',
      'مبرد',
      'شمعة',
      'محرك'
    ];

    final parts = <String>[];
    for (final keyword in keywords) {
      if (text.toLowerCase().contains(keyword)) {
        parts.add(keyword);
      }
    }
    return parts;
  }
}
