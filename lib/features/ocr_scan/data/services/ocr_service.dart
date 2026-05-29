import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  /// Extracts text from image using Google ML Kit
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();

      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      String extractedText = '';
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      return extractedText.trim();
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }
}
