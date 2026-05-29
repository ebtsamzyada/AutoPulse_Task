import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class OcrProgressIndicator extends StatelessWidget {
  final String step;
  final File? previewImage;
  const OcrProgressIndicator(
      {super.key, required this.step, this.previewImage});

  int get _currentStep {
    if (step.contains('Reading')) return 1;
    if (step.contains('Converting') || step.contains('PDF')) return 2;
    if (step.contains('Extracting')) return 3;
    if (step.contains('Identifying')) return 4;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (previewImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    Image.file(previewImage!, height: 180, fit: BoxFit.cover),
              ).animate().fadeIn(),
            const SizedBox(height: 32),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.accent,
                backgroundColor: AppTheme.accent.withOpacity(0.15),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              step.toUpperCase(),
              style: AppTheme.sectionLabel.copyWith(fontSize: 12),
            ).animate(key: ValueKey(step)).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  4,
                  (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: i < _currentStep
                              ? AppTheme.accent
                              : AppTheme.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
