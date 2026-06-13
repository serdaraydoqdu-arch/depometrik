import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:isolate';

/// Saf Dart dilinde yazılmış görüntü işleme servisi.
/// Fiş tarama öncesinde görüntüleri gri tonlamaya çevirir ve Otsu Eşikleme
/// algoritması ile binarize ederek OCR okuma başarısını en üst düzeye çıkarır.
class ImageProcessingService {
  /// Görseli verilen ekran vizör alanına göre kırpar ve binarize eder.
  static Future<File> cropAndBinarizeImage({
    required File inputFile,
    required double cropLeft,
    required double cropTop,
    required double cropWidth,
    required double cropHeight,
    required double screenWidth,
    required double screenHeight,
  }) async {
    final String inputPath = inputFile.path;
    final String outputPath = inputPath.replaceAll(
      RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false),
      '_processed.jpg',
    );

    final String processedPath = await Isolate.run(() async {
      final File file = File(inputPath);
      if (!await file.exists()) {
        throw Exception("Girdi dosyası bulunamadı: $inputPath");
      }

      final Uint8List bytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception("Görsel çözümlenemedi.");
      }

      // EXIF yönelimini uygula (Görüntüyü fiziksel olarak doğru açıya döndürür)
      originalImage = img.bakeOrientation(originalImage);

      final int I_w = originalImage.width;
      final int I_h = originalImage.height;

      double scale;
      double offsetX = 0;
      double offsetY = 0;

      if (I_w / I_h > screenWidth / screenHeight) {
        // Görsel ekrandan daha geniş (örneğin yatay çekim): Yüksekliği eşitle, yanları kırp
        scale = I_h / screenHeight;
        offsetX = (I_w - screenWidth * scale) / 2;
      } else {
        // Görsel ekrandan daha dar: Genişliği eşitle, üst/altları kırp
        scale = I_w / screenWidth;
        offsetY = (I_h - screenHeight * scale) / 2;
      }

      final int imgLeft = (cropLeft * scale + offsetX).round().clamp(0, I_w);
      final int imgTop = (cropTop * scale + offsetY).round().clamp(0, I_h);
      final int imgWidth = (cropWidth * scale).round().clamp(1, I_w - imgLeft);
      final int imgHeight = (cropHeight * scale).round().clamp(1, I_h - imgTop);

      // 1. Görseli Kırp
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: imgLeft,
        y: imgTop,
        width: imgWidth,
        height: imgHeight,
      );

      // 2. Gri Tonlamaya Dönüştür
      final img.Image grayscaleImage = img.grayscale(croppedImage);

      // 3. Otsu Eşik Değerini Hesapla
      final int threshold = _computeOtsuThreshold(grayscaleImage);

      // 4. Eşiklemeyi Uygula (Siyah-Beyazlaştır)
      _applyThreshold(grayscaleImage, threshold);

      // 5. JPEG Olarak Kaydet
      final Uint8List processedBytes = Uint8List.fromList(
        img.encodeJpg(grayscaleImage, quality: 90),
      );

      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(processedBytes);
      return outputPath;
    });

    return File(processedPath);
  }

  /// Görüntüyü arka planda bir Dart Isolate içinde binarize eder.
  /// İşlem tamamlandığında binarize edilmiş geçici dosyanın referansını döner.
  static Future<File> binarizeImage(File inputFile) async {
    final String inputPath = inputFile.path;
    final String outputPath = inputPath.replaceAll(
      RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false),
      '_processed.jpg',
    );

    final String processedPath = await Isolate.run(() async {
      final File file = File(inputPath);
      if (!await file.exists()) {
        throw Exception("Girdi dosyası bulunamadı: $inputPath");
      }

      final Uint8List bytes = await file.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception("Görsel çözümlenemedi (decode başarısız).");
      }

      // 1. Gri Tonlamaya Dönüştür
      final img.Image grayscaleImage = img.grayscale(originalImage);

      // 2. Otsu Eşik Değerini Hesapla
      final int threshold = _computeOtsuThreshold(grayscaleImage);

      // 3. Eşiklemeyi Uygula (Siyah-Beyazlaştır)
      _applyThreshold(grayscaleImage, threshold);

      // 4. JPEG Olarak Kaydet
      final Uint8List processedBytes = Uint8List.fromList(
        img.encodeJpg(grayscaleImage, quality: 90),
      );

      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(processedBytes);
      return outputPath;
    });

    return File(processedPath);
  }

  /// Otsu's thresholding algoritması ile ideal eşik değerini hesaplar.
  static int _computeOtsuThreshold(img.Image image) {
    final List<int> histogram = List<int>.filled(256, 0);
    int totalPixels = 0;

    // Histogramı doldur (Luminance veya kırmızı kanalı kullanıyoruz)
    for (final pixel in image) {
      final int gray = pixel.r.toInt();
      histogram[gray]++;
      totalPixels++;
    }

    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }

    double sumB = 0;
    int wB = 0;
    int wF = 0;

    double maxVariance = 0.0;
    int threshold = 127; // Varsayılan eşik değeri

    for (int t = 0; t < 256; t++) {
      wB += histogram[t];
      if (wB == 0) continue;

      wF = totalPixels - wB;
      if (wF == 0) break;

      sumB += t * histogram[t];

      final double mB = sumB / wB;
      final double mF = (sum - sumB) / wF;

      // Sınıflar arası varyans (Between-class variance)
      final double varianceBetween = wB.toDouble() * wF.toDouble() * (mB - mF) * (mB - mF);

      if (varianceBetween > maxVariance) {
        maxVariance = varianceBetween;
        threshold = t;
      }
    }

    return threshold;
  }

  /// Piksel piksel eşiklemeyi uygular.
  static void _applyThreshold(img.Image image, int threshold) {
    for (final pixel in image) {
      final int gray = pixel.r.toInt();
      final int newValue = (gray < threshold) ? 0 : 255;
      pixel.r = newValue;
      pixel.g = newValue;
      pixel.b = newValue;
    }
  }
}
