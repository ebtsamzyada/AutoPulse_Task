import 'dart:io';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

class PdfConverter {
  /// Renders page 0 of a PDF to a temp image file
  Future<File> pdfToImage(File pdfFile) async {
    final doc = await PdfDocument.openFile(pdfFile.path);
    final page = await doc.getPage(1); // 1-indexed
    final pageImage = await page.render(
      width: page.width * 2, // 2x for better OCR accuracy
      height: page.height * 2,
      format: PdfPageImageFormat.jpeg,
    );
    await page.close();
    await doc.close();

    final dir = await getTemporaryDirectory();
    final imgFile = File('${dir.path}/ocr_input.jpg');
    await imgFile.writeAsBytes(pageImage!.bytes);
    return imgFile;
  }
}
