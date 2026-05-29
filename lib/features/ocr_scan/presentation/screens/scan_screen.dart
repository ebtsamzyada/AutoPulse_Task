import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/services/llm_parser_service.dart';
import '../../data/services/ocr_service.dart';
import '../../data/services/pdf_converter.dart';
import '../widgets/source_picker_sheet.dart';
import '../widgets/ocr_progress_indicator.dart';
import 'review_screen.dart';

enum ScanState { idle, processing }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanState _state = ScanState.idle;
  String _progressStep = '';
  File? _previewImage;

  final _ocr = OcrService();
  final _llm = LlmParserService();
  final _pdfConverter = PdfConverter();

  Future<void> _processFile(File file, {bool isPdf = false}) async {
    setState(() {
      _state = ScanState.processing;
      _progressStep = 'Reading document...';
    });
    try {
      File imageFile = file;
      if (isPdf) {
        setState(() => _progressStep = 'Converting PDF...');
        imageFile = await _pdfConverter.pdfToImage(file);
      }
      setState(() {
        _previewImage = imageFile;
        _progressStep = 'Extracting text...';
      });

      // Step 1: Extract text using Tesseract OCR
      final ocrText = await _ocr.extractText(imageFile);

      setState(() => _progressStep = 'Structuring data...');

      // Step 2: Parse text with Groq LLM
      final record = await _llm.parse(ocrText);

      if (!mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ReviewScreen(record: record)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      setState(() => _state = ScanState.idle);
    }
  }

  Future<void> _pickFromCamera() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 90);
    if (x != null) _processFile(File(x.path));
  }

  Future<void> _requestMediaPermission() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gallery permission required'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    await _requestMediaPermission();
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x != null) _processFile(File(x.path));
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (r != null) _processFile(File(r.files.single.path!), isPdf: true);
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SourcePickerSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickFromCamera();
        },
        onGallery: () {
          Navigator.pop(context);
          _pickFromGallery();
        },
        onPdf: () {
          Navigator.pop(context);
          _pickPdf();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(),
      body: _state == ScanState.processing
          ? OcrProgressIndicator(
              step: _progressStep, previewImage: _previewImage)
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'AUTO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            TextSpan(
              text: 'PULSE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.memory, color: Colors.white, size: 22),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCAN MAINTENANCE RECORD', style: AppTheme.sectionLabel),
          const SizedBox(height: 4),
          const Text(
            'Upload or photograph your service record',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _buildDropZone(),
          const SizedBox(height: 16),
          _buildSourceTiles(),
          const SizedBox(height: 24),
          const Text('TIPS', style: AppTheme.sectionLabel),
          const SizedBox(height: 10),
          _buildTipCard(Icons.wb_sunny_outlined, 'Good lighting',
              'Ensure the document is well-lit and flat'),
          const SizedBox(height: 8),
          _buildTipCard(Icons.crop_rotate_outlined, 'Alignment',
              'Keep the camera parallel to the document'),
          const SizedBox(height: 8),
          _buildTipCard(Icons.text_fields_outlined, 'Clarity',
              'Handwriting and Arabic text are supported'),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _showSourcePicker,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.document_scanner_outlined,
                  color: AppTheme.accent, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap to scan or upload',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('PDF · Photo · Camera', style: AppTheme.bodyMuted),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildSourceTiles() {
    return Row(
      children: [
        _sourceTile(Icons.camera_alt_outlined, 'Camera', _pickFromCamera),
        const SizedBox(width: 12),
        _sourceTile(Icons.photo_library_outlined, 'Gallery', _pickFromGallery),
        const SizedBox(width: 12),
        _sourceTile(Icons.picture_as_pdf_outlined, 'PDF', _pickPdf),
      ],
    );
  }

  Widget _sourceTile(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.accent, size: 24),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: AppTheme.sectionLabel.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text(subtitle, style: AppTheme.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}
