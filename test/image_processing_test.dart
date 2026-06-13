import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:depometrik/core/ocr/image_processing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageProcessingService - Otsu Binarization Tests', () {
    late File testInputFile;
    late File? testOutputFile;

    setUp(() async {
      // Create a dummy image with some gradients/text patterns
      final image = img.Image(width: 100, height: 100);
      
      // Draw background (light gray: 200) and foreground (dark gray: 50)
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          final isForeground = (x > 30 && x < 70 && y > 30 && y < 70);
          final color = isForeground ? img.ColorRgb8(50, 50, 50) : img.ColorRgb8(200, 200, 200);
          image.setPixel(x, y, color);
        }
      }

      final bytes = img.encodeJpg(image);
      final tempDir = Directory.systemTemp;
      testInputFile = File('${tempDir.path}/test_receipt_input.jpg');
      await testInputFile.writeAsBytes(bytes);
      testOutputFile = null;
    });

    tearDown(() async {
      if (await testInputFile.exists()) {
        await testInputFile.delete();
      }
      if (testOutputFile != null && await testOutputFile!.exists()) {
        await testOutputFile!.delete();
      }
    });

    test('Binarize image should produce a file with only black and white pixels', () async {
      final processedFile = await ImageProcessingService.binarizeImage(testInputFile);
      testOutputFile = processedFile;

      expect(await processedFile.exists(), isTrue);

      final processedBytes = await processedFile.readAsBytes();
      final processedImage = img.decodeImage(processedBytes);
      expect(processedImage, isNotNull);

      // Verify that all pixels in the processed image are binary (either 0 or 255)
      for (final pixel in processedImage!) {
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        expect(r == g && g == b, isTrue, reason: 'Image should be grayscale');
        expect(r < 30 || r > 225, isTrue, reason: 'Pixels must be binarized (near 0 or 255)');
      }
    });
  });
}
