import 'package:flutter/material.dart';
import 'package:autopulse_challenge/core/theme/app_theme.dart';
import 'features/ocr_scan/presentation/screens/scan_screen.dart';

void main() => runApp(const AutoPulseApp());

class AutoPulseApp extends StatelessWidget {
  const AutoPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ScanScreen(),
    );
  }
}
