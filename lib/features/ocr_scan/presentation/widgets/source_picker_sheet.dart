import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SourcePickerSheet extends StatelessWidget {
  final VoidCallback onCamera, onGallery, onPdf;
  const SourcePickerSheet(
      {super.key,
      required this.onCamera,
      required this.onGallery,
      required this.onPdf});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF141B24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('CHOOSE SOURCE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 20),
          _tile(Icons.camera_alt_outlined, 'Camera', 'Capture a photo now',
              onCamera),
          const SizedBox(height: 10),
          _tile(Icons.photo_library_outlined, 'Photo Library',
              'Select from your gallery', onGallery),
          const SizedBox(height: 10),
          _tile(Icons.picture_as_pdf_outlined, 'PDF Document',
              'Upload from files', onPdf),
        ],
      ),
    );
  }

  static Widget _tile(
      IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(sub, style: AppTheme.bodyMuted.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textSecondary.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}
