import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/maintenance_record.dart';
import '../widgets/editable_field_tile.dart';

class ReviewScreen extends StatefulWidget {
  final MaintenanceRecord record;
  const ReviewScreen({super.key, required this.record});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _dateCtrl;
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _labourCtrl;
  late final TextEditingController _partsCtrl;
  late final TextEditingController _workshopCtrl;
  late final TextEditingController _nextServiceCtrl;
  late final TextEditingController _partsListCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _dateCtrl = TextEditingController(text: r.serviceDate ?? '');
    _mileageCtrl = TextEditingController(text: r.mileageKm?.toString() ?? '');
    _labourCtrl =
        TextEditingController(text: r.labourCostEgp?.toString() ?? '');
    _partsCtrl = TextEditingController(text: r.partsCostEgp?.toString() ?? '');
    _workshopCtrl = TextEditingController(text: r.workshopName ?? '');
    _nextServiceCtrl =
        TextEditingController(text: r.nextServiceDueKm?.toString() ?? '');
    _partsListCtrl = TextEditingController(text: r.partsReplaced.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _dateCtrl,
      _mileageCtrl,
      _labourCtrl,
      _partsCtrl,
      _workshopCtrl,
      _nextServiceCtrl,
      _partsListCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _conf(String field) {
    final confidence = widget.record.fieldConfidence[field] ?? 0.0;
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.3) return 'low';
    return 'missing';
  }

  bool get _hasMissing =>
      widget.record.fieldConfidence.values.any((v) => v < 0.3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('REVIEW RECORD',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Re-scan',
                style: TextStyle(color: AppTheme.accent, fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasMissing) _warningBanner(),
          _vehicleSummaryCard(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                _sectionLabel('SERVICE INFO'),
                EditableFieldTile(
                        label: 'Service Date',
                        controller: _dateCtrl,
                        confidence: _conf('service_date'),
                        icon: Icons.calendar_today_outlined)
                    .animate()
                    .fadeIn(delay: 50.ms)
                    .slideX(begin: -0.04),
                EditableFieldTile(
                        label: 'Mileage (km)',
                        controller: _mileageCtrl,
                        confidence: _conf('mileage_km'),
                        icon: Icons.speed_outlined,
                        keyboardType: TextInputType.number)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.04),
                EditableFieldTile(
                        label: 'Workshop Name',
                        controller: _workshopCtrl,
                        confidence: _conf('workshop_name'),
                        icon: Icons.store_outlined)
                    .animate()
                    .fadeIn(delay: 150.ms)
                    .slideX(begin: -0.04),
                _sectionLabel('COSTS'),
                EditableFieldTile(
                        label: 'Labour Cost (EGP)',
                        controller: _labourCtrl,
                        confidence: _conf('labour_cost_egp'),
                        icon: Icons.handyman_outlined,
                        keyboardType: TextInputType.number)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(begin: -0.04),
                EditableFieldTile(
                        label: 'Parts Cost (EGP)',
                        controller: _partsCtrl,
                        confidence: _conf('parts_cost_egp'),
                        icon: Icons.build_circle_outlined,
                        keyboardType: TextInputType.number)
                    .animate()
                    .fadeIn(delay: 250.ms)
                    .slideX(begin: -0.04),
                _sectionLabel('PARTS & NEXT SERVICE'),
                EditableFieldTile(
                        label: 'Parts Replaced',
                        controller: _partsListCtrl,
                        confidence: _conf('parts_replaced'),
                        icon: Icons.list_alt_outlined,
                        maxLines: 3)
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideX(begin: -0.04),
                EditableFieldTile(
                        label: 'Next Service (km)',
                        controller: _nextServiceCtrl,
                        confidence: _conf('next_service_due_km'),
                        icon: Icons.update_outlined,
                        keyboardType: TextInputType.number)
                    .animate()
                    .fadeIn(delay: 350.ms)
                    .slideX(begin: -0.04),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _warningBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.warning, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Some fields couldn\'t be read — please fill in the highlighted ones.',
              style: AppTheme.bodyMuted.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.vehicleCardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined,
              color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scanned Record',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text('Review and correct extracted fields',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.record.fieldConfidence.values.where((v) => v >= 0.8).length}/7 fields',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 2),
      child: Text(label, style: AppTheme.sectionLabel),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Save the record with updated values from controllers
            try {
              widget.record.copyWith(
                serviceDate: _dateCtrl.text.isNotEmpty
                    ? _dateCtrl.text
                    : widget.record.serviceDate,
                mileageKm: _mileageCtrl.text.isNotEmpty
                    ? int.tryParse(_mileageCtrl.text)
                    : widget.record.mileageKm,
                labourCostEgp: _labourCtrl.text.isNotEmpty
                    ? double.tryParse(_labourCtrl.text)
                    : widget.record.labourCostEgp,
                partsCostEgp: _partsCtrl.text.isNotEmpty
                    ? double.tryParse(_partsCtrl.text)
                    : widget.record.partsCostEgp,
                workshopName: _workshopCtrl.text.isNotEmpty
                    ? _workshopCtrl.text
                    : widget.record.workshopName,
                nextServiceDueKm: _nextServiceCtrl.text.isNotEmpty
                    ? int.tryParse(_nextServiceCtrl.text)
                    : widget.record.nextServiceDueKm,
                partsReplaced: _partsListCtrl.text.isNotEmpty
                    ? _partsListCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList()
                    : widget.record.partsReplaced,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Record saved'),
                    backgroundColor: AppTheme.accent),
              );
              Navigator.popUntil(context, (r) => r.isFirst);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Save failed: $e'),
                    backgroundColor: AppTheme.error),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('CONFIRM & SAVE',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
        ),
      ),
    );
  }
}
