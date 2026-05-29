class MaintenanceRecord {
  final String id;
  final String? serviceDate;
  final int? mileageKm;
  final List<String> partsReplaced;
  final double? labourCostEgp;
  final double? partsCostEgp;
  final String? workshopName;
  final int? nextServiceDueKm;
  final Map<String, double> fieldConfidence; // confidence scores per field

  MaintenanceRecord({
    required this.id,
    this.serviceDate,
    this.mileageKm,
    this.partsReplaced = const [],
    this.labourCostEgp,
    this.partsCostEgp,
    this.workshopName,
    this.nextServiceDueKm,
    this.fieldConfidence = const {},
  });

  // Factory to create from JSON (from LLM)
  factory MaintenanceRecord.fromJson(Map<String, dynamic> json, {String? id}) {
    // Convert string confidence values to doubles (high=0.9, low=0.5, missing=0.0)
    final confMap = json['fieldConfidence'] as Map<String, dynamic>? ?? {};
    final confidenceScores = <String, double>{};
    confMap.forEach((key, value) {
      if (value is String) {
        confidenceScores[key] = value == 'high'
            ? 0.9
            : value == 'low'
                ? 0.5
                : 0.0;
      }
    });

    return MaintenanceRecord(
      id: id ?? '',
      serviceDate: json['service_date'],
      mileageKm: json['mileage_km'],
      partsReplaced: List<String>.from(json['parts_replaced'] ?? []),
      labourCostEgp: json['labour_cost_egp']?.toDouble(),
      partsCostEgp: json['parts_cost_egp']?.toDouble(),
      workshopName: json['workshop_name'],
      nextServiceDueKm: json['next_service_due_km'],
      fieldConfidence: confidenceScores,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_date': serviceDate,
      'mileage_km': mileageKm,
      'parts_replaced': partsReplaced,
      'labour_cost_egp': labourCostEgp,
      'parts_cost_egp': partsCostEgp,
      'workshop_name': workshopName,
      'next_service_due_km': nextServiceDueKm,
    };
  }

  // Calculate confidence for a field
  double getFieldConfidence(String field) {
    return fieldConfidence[field] ?? 0.0;
  }

  // Create a copy with modifications
  MaintenanceRecord copyWith({
    String? id,
    String? serviceDate,
    int? mileageKm,
    List<String>? partsReplaced,
    double? labourCostEgp,
    double? partsCostEgp,
    String? workshopName,
    int? nextServiceDueKm,
    Map<String, double>? fieldConfidence,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      serviceDate: serviceDate ?? this.serviceDate,
      mileageKm: mileageKm ?? this.mileageKm,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      labourCostEgp: labourCostEgp ?? this.labourCostEgp,
      partsCostEgp: partsCostEgp ?? this.partsCostEgp,
      workshopName: workshopName ?? this.workshopName,
      nextServiceDueKm: nextServiceDueKm ?? this.nextServiceDueKm,
      fieldConfidence: fieldConfidence ?? this.fieldConfidence,
    );
  }
}
