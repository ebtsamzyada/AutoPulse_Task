import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EditableFieldTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String confidence;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const EditableFieldTile({
    super.key,
    required this.label,
    required this.controller,
    required this.confidence,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  Color get _indicatorColor => switch (confidence) {
        'high' => AppTheme.accent,
        'low' => AppTheme.warning,
        _ => AppTheme.error,
      };

  Widget get _badge => switch (confidence) {
        'high' =>
          const Icon(Icons.check_circle, color: AppTheme.accent, size: 15),
        'low' => const Icon(Icons.warning_amber_rounded,
            color: AppTheme.warning, size: 15),
        _ => const Icon(Icons.error_outline, color: AppTheme.error, size: 15),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _indicatorColor, width: 3),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.bodyMuted.copyWith(fontSize: 12),
          prefixIcon:
              Icon(icon, color: AppTheme.accent.withOpacity(0.7), size: 16),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _badge,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
