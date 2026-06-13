import 'dart:io';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';

/// Akaryakıt fişlerinden ayıklanan verileri taşıyan yapı sınıfı
class ReceiptData {
  final double? liters;
  final double? unitPrice;
  final double? totalPrice;
  final DateTime? purchaseDate;
  final String? stationBrand;
  final String? fuelType;

  ReceiptData({
    this.liters,
    this.unitPrice,
    this.totalPrice,
    this.purchaseDate,
    this.stationBrand,
    this.fuelType,
  });

  @override
  String toString() {
    return 'ReceiptData(liters: $liters, unitPrice: $unitPrice, totalPrice: $totalPrice, purchaseDate: $purchaseDate, stationBrand: $stationBrand, fuelType: $fuelType)';
  }
}

/// Google ML Kit ile yerel cihaz üzerinde fiş okuma ve ayrıştırma servisi
class ReceiptOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  // Türkiye'de bilinen popüler akaryakıt istasyonu markaları
  static const List<String> _knownBrands = [
    'SHELL',
    'OPET',
    'BP',
    'PETROL OFISI',
    'TOTAL',
    'AYGAZ',
    'LUKOIL',
    'TP',
    'MILANGAZ',
    'IPRAGAZ',
    'Aytemiz',
    'Sunpet',
    'Kadoil',
    'Starpet',
    'Qplus',
  ];

  /// Verilen fiş dosyasını yerel olarak tarayıp verilerini ayrıştırır.
  /// Lüks Hibrit Yaklaşım: Önce yerel cihaz üzerinde ML Kit ve Heuristic kurallar çalışır (Hızlı ve İnternetsiz).
  /// Eğer hayati alanlardan (Litre, Tutar, Marka) biri eksik kalırsa ve aktif internet bağlantısı varsa,
  /// Google Gemini 2.5 Flash API'yi devreye sokarak yapay zeka ile metinden yapılandırılmış JSON verisi ayıklar.
  Future<ReceiptData> parseReceipt(
    File imageFile, {
    double? cropLeft,
    double? cropTop,
    double? cropWidth,
    double? cropHeight,
    double? screenWidth,
    double? screenHeight,
  }) async {
    // ML Kit, gölgeli veya ışık gradyanı içeren doğal fotoğraflarda binarize edilmiş siyah-beyaz
    // görsellere kıyasla orijinal renkli görsel üzerinde çok daha yüksek doğrulukla çalışır.
    // Bu nedenle binarizasyon filtresini devre dışı bırakıp doğrudan orijinal görseli tarıyoruz.
    final inputImage = InputImage.fromFile(imageFile);

    try {
      // 1. ML Kit ile yerel OCR gerçekleştir
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );
      // Mekansal koordinat gruplaması yaparak satırları dikey/yatay konumlarına göre hizala
      final List<String> sortedLines = _groupElementsIntoHorizontalLines(recognizedText);
      final rawText = sortedLines.join('\n');
      
      print('=== OCR HAM METİN BAŞLANGIÇ ===');
      print(rawText);
      print('=== OCR HAM METİN BİTİŞ ===');

      // 2. Yerel kurallı süzgeç ve matematiksel denklem motorunu çalıştır
      final localData = extractData(rawText);
      
      print('=== YEREL AYRIŞTIRMA SONUÇLARI ===');
      print('Litre: ${localData.liters}');
      print('Birim Fiyat: ${localData.unitPrice}');
      print('Toplam Fiyat: ${localData.totalPrice}');
      print('Tarih: ${localData.purchaseDate}');
      print('Marka: ${localData.stationBrand}');
      print('Yakıt Cinsi: ${localData.fuelType}');
      print('=================================');

      // 3. Eğer her şey tam olarak çözüldüyse anında yerel sonucu dön
      if (localData.liters != null &&
          localData.totalPrice != null &&
          localData.unitPrice != null &&
          localData.stationBrand != null &&
          localData.purchaseDate != null) {
        return localData;
      }

      // 4. Eğer eksik veri varsa ve İnternet bağlantısı aktifse, Gemini 2.5 Flash ile premium analiz yap
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (hasInternet) {
        final aiData = await _parseWithGemini2_5(rawText);
        if (aiData != null) {
          // Yerel veriler ile yapay zeka analizini lüks bir şekilde harmanla (Birbirini tamamlasınlar)
          return ReceiptData(
            liters: localData.liters ?? aiData.liters,
            unitPrice: localData.unitPrice ?? aiData.unitPrice,
            totalPrice: localData.totalPrice ?? aiData.totalPrice,
            purchaseDate: localData.purchaseDate ?? aiData.purchaseDate,
            stationBrand: localData.stationBrand ?? aiData.stationBrand,
            fuelType: localData.fuelType ?? aiData.fuelType,
          );
        }
      }

      return localData;
    } catch (e, stackTrace) {
      print('ReceiptOcrService Exception: $e');
      print(stackTrace);
      return ReceiptData();
    }
  }

  /// Google Gemini 2.5 Flash-Lite API ile ham OCR metnini gelişmiş semantik süzgeçten geçirir
  Future<ReceiptData?> _parseWithGemini2_5(String rawText) async {
    final apiKey = AppConfig.geminiApiKey;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$apiKey',
    );

    try {
      final client = HttpClient();
      final request = await client.postUrl(url);
      request.headers.contentType = ContentType.json;

      final prompt =
          """
Aşağıdaki ham OCR metninden akaryakıt fişi bilgilerini (istasyon markası, litre miktarı, birim fiyatı, toplam tutar, fiş tarihi ve yakıt türü) ayıkla.
Bulamadığın alanlar için null döndür. Fiş tarihi DD.MM.YYYY formatında ise YYYY-MM-DD olarak çevir.
Yakıt türü metinde BENZİN/KURŞUNSUZ vb. geçiyorsa "BENZİN", MOTORİN/MAZOT/DIZEL geçiyorsa "MAZOT", LPG/OTOGAZ geçiyorsa "LPG" döndür.
YALNIZCA aşağıdaki şemaya birebir uyan geçerli bir JSON objesi döndür, başka hiçbir açıklama metni yazma:
{
  "liters": double veya null,
  "unitPrice": double veya null,
  "totalPrice": double veya null,
  "purchaseDate": "YYYY-MM-DD" veya null,
  "stationBrand": "SHELL" veya "OPET" veya "BP" veya "TOTAL" veya "PETROL OFISI" veya null,
  "fuelType": "BENZİN" veya "MAZOT" veya "LPG" veya null
}

Ham OCR Metni:
$rawText
""";

      final payload = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {"responseMimeType": "application/json"},
      };

      request.write(jsonEncode(payload));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        final candidates = jsonResponse['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final String jsonText = parts[0]['text'] as String;
            final Map<String, dynamic> data = jsonDecode(jsonText.trim());

            double? liters = data['liters'] != null
                ? double.tryParse(data['liters'].toString())
                : null;
            double? unitPrice = data['unitPrice'] != null
                ? double.tryParse(data['unitPrice'].toString())
                : null;
            double? totalPrice = data['totalPrice'] != null
                ? double.tryParse(data['totalPrice'].toString())
                : null;

            DateTime? purchaseDate;
            if (data['purchaseDate'] != null) {
              purchaseDate = DateTime.tryParse(data['purchaseDate'].toString());
            }

            String? stationBrand = data['stationBrand']?.toString();
            String? fuelType = data['fuelType']?.toString();

            return ReceiptData(
              liters: liters,
              unitPrice: unitPrice,
              totalPrice: totalPrice,
              purchaseDate: purchaseDate,
              stationBrand: stationBrand,
              fuelType: fuelType,
            );
          }
        }
      }
    } catch (e) {
      // Hata durumunda yoksay, yerel analiz dönsün
    }
    return null;
  }

  /// Türkçe / Latin karakter kümesindeki harfleri collation uyumsuzluklarını önlemek için standart İngilizce büyük harfe çevirir
  String _toEnglishUpper(String text) {
    return text
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'G')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'C')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'O')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'U');
  }

  /// OCR metninden regex ve metin tarama ile akaryakıt verilerini ayıklar
  ReceiptData extractData(String rawText) {
    // 1. Türkçe karakter hataları ve sık yapılan OCR okuma kusurlarını normalleştir
    final normalizedText = _normalizeOcrText(rawText);
    final List<String> lines = normalizedText.split('\n');

    double? liters;
    double? unitPrice;
    double? totalPrice;
    DateTime? purchaseDate;
    String? stationBrand;

    // 2. İstasyon markası tespiti (Tüm metinde ve Türkçe collation uyumlu ara)
    final normalizedRawUpper = _toEnglishUpper(normalizedText);
    for (final brand in _knownBrands) {
      final brandUpper = _toEnglishUpper(brand);
      if (normalizedRawUpper.contains(brandUpper)) {
        stationBrand = brand;
        break;
      }
    }

    // 3. Yakıt Cinsi Tespiti (Heuristic - Gürültü Filtreli)
    String? fuelType;
    for (final line in lines) {
      final lineUpper = _toEnglishUpper(line);
      // Sadece vergi oranı (%), LT birimi veya işlem karakteri (X, *) içeren satırlarda yakıt ara
      // Bu sayede URL veya sekmelerdeki dosya isimlerindeki (.lpg vb.) gürültülerin yanlış eşleşmesi önlenir
      if (lineUpper.contains('%') || 
          lineUpper.contains('LT') || 
          lineUpper.contains('LITRE') || 
          lineUpper.contains('LİTRE') ||
          lineUpper.contains('X') ||
          lineUpper.contains('*')) {
        
        if (lineUpper.contains('MOTORIN') ||
            lineUpper.contains('MAZOT') ||
            lineUpper.contains('DIZEL') ||
            lineUpper.contains('EURODIESEL')) {
          fuelType = 'MAZOT';
          break;
        } else if (lineUpper.contains('LPG') ||
                   lineUpper.contains('OTOGAZ')) {
          fuelType = 'LPG';
          break;
        } else if (lineUpper.contains('BENZIN') ||
                   lineUpper.contains('KURSUNSUZ') ||
                   lineUpper.contains('95') ||
                   lineUpper.contains('97')) {
          fuelType = 'BENZİN';
          break;
        }
      }
    }

    // Eğer yukarıdaki güvenli satırlardan bulunamadıysa, son çare olarak genel metinde ara
    if (fuelType == null) {
      if (normalizedRawUpper.contains('MOTORIN') ||
          normalizedRawUpper.contains('MAZOT') ||
          normalizedRawUpper.contains('DIZEL') ||
          normalizedRawUpper.contains('EURODIESEL')) {
        fuelType = 'MAZOT';
      } else if (normalizedRawUpper.contains('LPG') ||
          normalizedRawUpper.contains('OTOGAZ')) {
        fuelType = 'LPG';
      } else if (normalizedRawUpper.contains('BENZIN') ||
          normalizedRawUpper.contains('KURSUNSUZ') ||
          normalizedRawUpper.contains('95') ||
          normalizedRawUpper.contains('97')) {
        fuelType = 'BENZİN';
      }
    }

    // 4. Fişteki sayısal alanlar ve tarihler için Regex Tanımları
    // Tarih Regex: DD.MM.YYYY, DD/MM/YYYY veya DD-MM-YYYY (virgül, boşluk ve tire toleranslı)
    final dateRegex = RegExp(r'(\d{2})[\.\/,\s\-]+(\d{2})[\.\/,\s\-]+(\d{4}|\d{2})');
    final dateRegexYmd = RegExp(r'(\d{4})[\.\/,\s\-]+(\d{2})[\.\/,\s\-]+(\d{2})');

    // Litre Regex: "45,23 LT", "50.12 LITRE", "45.00 L" vb.
    // Ondalık ayrıcı olarak virgül veya nokta gelebilir.
    final litersRegex = RegExp(
      r'(?:LITRE|LİTRE|LT|L)\s*[:\s]*\s*(\d+[\.,]\d{2,3})|(\d+[\.,]\d{2,3})\s*(?:LT|L|LITRE|LİTRE)',
      caseSensitive: false,
    );

    // Birim Fiyat Regex: "42,39 TL/LT", "FİYAT 41.90", "TL/L: 42.50"
    final unitPriceRegex = RegExp(
      r'(?:FIYAT|FİYAT|TL\s*/\s*LT|TL\s*/\s*L)\s*[:\s]*\s*(\d+[\.,]\d{2,4})|(\d+[\.,]\d{2,4})\s*(?:TL\s*/\s*LT|TL\s*/\s*L)',
      caseSensitive: false,
    );

    // Örn: "50,630 LT X 36,550" veya "45.20 LT * 38.50" (boşluk sınırlandırmalı)
    final mathLineRegex = RegExp(
      r'(\d+[\.,]\d{2,3})\s*(?:LT|L|LITRE)?\s*(?:\s+[xX]\s+|\s+[*]\s+|\s+x\s+)\s*(\d+[\.,]\d{2,3})',
      caseSensitive: false,
    );

    // Toplam Tutar Regex: "TOPLAM *1.850,53", "TUTAR: 1.500,00 TL" (yıldız, eşittir, TOP ve NAKİT uyumlu)
    final totalPriceRegex = RegExp(
      r'(?:TUTAR|TOPLAM|TOP|TOTAL|ODENEN|NAKİT|NAKIT)\s*(?:TL)?\s*[\*:\s=]*\s*(\d+(?:[\.,]\d{3})*(?:[\.,]\d{2}))',
      caseSensitive: false,
    );

    // Satırları tek tek tarayarak regex eşleşmelerini yakala
    for (final line in lines) {
      // A. Çarpım Denklemi Tespiti (Örn: "50,630 LT X 36,550")
      final mathMatch = mathLineRegex.firstMatch(line);
      if (mathMatch != null) {
        final parsedLiters = _parseDouble(mathMatch.group(1) ?? '');
        final parsedPrice = _parseDouble(mathMatch.group(2) ?? '');
        if (parsedLiters != null && parsedLiters > 0) liters ??= parsedLiters;
        if (parsedPrice != null && parsedPrice > 0) unitPrice ??= parsedPrice;
      }
      // A. Tarih Ayrıştırma (Gelişmiş 2 haneli ve 4 haneli yıl uyumu)
      if (purchaseDate == null) {
        // DD.MM.YYYY veya DD.MM.YY formatını ara
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) {
          final day = int.tryParse(dateMatch.group(1) ?? '');
          final month = int.tryParse(dateMatch.group(2) ?? '');
          final yearStr = dateMatch.group(3) ?? '';
          int? year = int.tryParse(yearStr);
          if (day != null && month != null && year != null) {
            if (yearStr.length == 2) {
              year += 2000; // yy -> yyyy dönüşümü (26 -> 2026)
            }
            if (day >= 1 &&
                day <= 31 &&
                month >= 1 &&
                month <= 12 &&
                year >= 2000 &&
                year <= 2100) {
              try {
                purchaseDate = DateTime(year, month, day);
              } catch (_) {}
            }
          }
        }

        // Alternatif olarak YYYY.MM.DD formatını ara
        if (purchaseDate == null) {
          final dateMatchYmd = dateRegexYmd.firstMatch(line);
          if (dateMatchYmd != null) {
            final year = int.tryParse(dateMatchYmd.group(1) ?? '');
            final month = int.tryParse(dateMatchYmd.group(2) ?? '');
            final day = int.tryParse(dateMatchYmd.group(3) ?? '');
            if (year != null && month != null && day != null) {
              if (day >= 1 &&
                  day <= 31 &&
                  month >= 1 &&
                  month <= 12 &&
                  year >= 2000 &&
                  year <= 2100) {
                try {
                  purchaseDate = DateTime(year, month, day);
                } catch (_) {}
              }
            }
          }
        }
      }

      // B. Litre Ayrıştırma
      if (liters == null) {
        final litersMatch = litersRegex.firstMatch(line);
        if (litersMatch != null) {
          final valStr = litersMatch.group(1) ?? litersMatch.group(2);
          if (valStr != null) {
            liters = _parseDouble(valStr);
          }
        }
      }

      // C. Birim Fiyat Ayrıştırma
      if (unitPrice == null) {
        final priceMatch = unitPriceRegex.firstMatch(line);
        if (priceMatch != null) {
          final valStr = priceMatch.group(1) ?? priceMatch.group(2);
          if (valStr != null) {
            unitPrice = _parseDouble(valStr);
          }
        }
      }

      // D. Toplam Tutar Ayrıştırma
      if (totalPrice == null) {
        final totalMatch = totalPriceRegex.firstMatch(line);
        if (totalMatch != null) {
          final valStr = totalMatch.group(1);
          if (valStr != null) {
            totalPrice = _parseDouble(valStr);
          }
        }
      }
    }

    // 4. Heuristic / Matematiksel Eşleşme Çözücüsü (Eksik veya Columnar Tablo Formatları İçin)
    // Fiş metnindeki tüm parasal/ondalıklı sayıları çıkarıyoruz
    final numberRegex = RegExp(r'\b\d+[\.,]\d{2,4}\b');
    final List<double> extractedNumbers = [];
    for (final match in numberRegex.allMatches(normalizedText)) {
      final valStr = match.group(0);
      if (valStr != null) {
        final val = _parseDouble(valStr);
        if (val != null && val > 0 && !extractedNumbers.contains(val)) {
          extractedNumbers.add(val);
        }
      }
    }

    // A. Litre bulundu ama Birim Fiyat ve Toplam Tutar eksikse (Kullanıcının ekranındaki durum!)
    if (liters != null && unitPrice == null && totalPrice == null) {
      for (final n in extractedNumbers) {
        if ((n - liters).abs() < 0.05) continue;
        final expectedTotal = liters * n;
        for (final t in extractedNumbers) {
          if ((t - expectedTotal).abs() < 2.0) {
            // 2 TL yuvarlama toleransı
            unitPrice = n;
            totalPrice = t;
            break;
          }
        }
        if (unitPrice != null) break;
      }
    }

    // B. Toplam Tutar bulundu ama Litre ve Birim Fiyat eksikse
    if (totalPrice != null && liters == null && unitPrice == null) {
      for (final l in extractedNumbers) {
        if ((l - totalPrice).abs() < 0.5) continue;
        for (final u in extractedNumbers) {
          if ((u - totalPrice).abs() < 0.5) continue;
          if ((l - u).abs() < 0.1) continue;
          final expectedTotal = l * u;
          if ((expectedTotal - totalPrice).abs() < 2.0) {
            liters = l;
            unitPrice = u;
            break;
          }
        }
        if (liters != null) break;
      }
    }

    // C. Hiçbiri bulunamadıysa tüm kombinasyonları dene (Genel Çözücü)
    if (liters == null &&
        unitPrice == null &&
        totalPrice == null &&
        extractedNumbers.length >= 3) {
      for (int i = 0; i < extractedNumbers.length; i++) {
        for (int j = 0; j < extractedNumbers.length; j++) {
          if (i == j) continue;
          final valA = extractedNumbers[i];
          final valB = extractedNumbers[j];
          final expectedTotal = valA * valB;

          for (int k = 0; k < extractedNumbers.length; k++) {
            if (k == i || k == j) continue;
            final valC = extractedNumbers[k];

            if ((valC - expectedTotal).abs() < 2.0) {
              totalPrice = valC;
              // Türkiye akaryakıt birim fiyat aralığına göre çarpanları ata (örn: 35-55 TL)
              if (valA >= 30 && valA <= 60) {
                unitPrice = valA;
                liters = valB;
              } else if (valB >= 30 && valB <= 60) {
                unitPrice = valB;
                liters = valA;
              } else {
                if (valA < valB) {
                  unitPrice = valA;
                  liters = valB;
                } else {
                  unitPrice = valB;
                  liters = valA;
                }
              }
              break;
            }
          }
          if (totalPrice != null) break;
        }
        if (totalPrice != null) break;
      }
    }

    // 5. Tutarlılık ve Eksik Tamamlama Kontrolleri (Akıllı Hesaplama)
    // Eğer Litre ve Birim Fiyat varsa ama Toplam Tutar yoksa otomatik hesapla
    if (totalPrice == null && liters != null && unitPrice != null) {
      totalPrice = double.parse((liters * unitPrice).toStringAsFixed(2));
    }
    // Eğer Toplam Tutar ve Birim Fiyat varsa ama Litre yoksa otomatik hesapla
    if (liters == null &&
        totalPrice != null &&
        unitPrice != null &&
        unitPrice > 0) {
      liters = double.parse((totalPrice / unitPrice).toStringAsFixed(3));
    }
    // Eğer Toplam Tutar ve Litre varsa ama Birim Fiyat yoksa otomatik hesapla
    if (unitPrice == null &&
        totalPrice != null &&
        liters != null &&
        liters > 0) {
      unitPrice = double.parse((totalPrice / liters).toStringAsFixed(4));
    }

    return ReceiptData(
      liters: liters,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      purchaseDate: purchaseDate,
      stationBrand: stationBrand,
      fuelType: fuelType,
    );
  }

  /// OCR metinlerindeki sık yapılan okuma hatalarını normalize eder
  String _normalizeOcrText(String input) {
    return input
        .replaceAll('LT.', 'LT')
        .replaceAll('Lt.', 'LT')
        .replaceAll('lt.', 'LT')
        .replaceAll('TL/LT', ' TL/LT')
        .replaceAll('KDV DAHIL', 'TUTAR')
        .replaceAll('KDV DAHİL', 'TUTAR')
        .replaceAll('TOPLAM TUTAR', 'TUTAR')
        .replaceAll('nakıt', 'TUTAR')
        .replaceAll('NAKIT', 'TUTAR')
        .replaceAll('nakit', 'TUTAR')
        .replaceAll('NAKİT', 'TUTAR')
        .replaceAll('FIŞ', 'FIS')
        .replaceAll('tutar', 'TUTAR')
        .replaceAll('toplam', 'TOPLAM');
  }

  /// Türkçe / Avrupa sayı biçimlerindeki virgülü noktaya çevirerek güvenle double parse eder
  double? _parseDouble(String value) {
    String cleanVal = value.trim();
    // Eğer binlik ayırıcı olarak nokta, ondalık olarak virgül varsa (Örn: 1.250,50)
    if (cleanVal.contains('.') && cleanVal.contains(',')) {
      cleanVal = cleanVal.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // Sadece tek bir virgül varsa ondalık kabul et (Örn: 42,39)
      cleanVal = cleanVal.replaceAll(',', '.');
    }
    return double.tryParse(cleanVal);
  }

  /// Kelimeleri dikey orta noktalarına göre gruplayıp yatayda sıralayan mekansal algoritma.
  List<String> _groupElementsIntoHorizontalLines(RecognizedText recognizedText) {
    final Map<int, List<TextElement>> rowBins = {};
    
    // Ortalama kelime yüksekliğini hesaplayarak dikey tolerans eşiğini dinamikleştiriyoruz
    double totalHeight = 0;
    int elementCount = 0;
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;
          totalHeight += box.height;
          elementCount++;
        }
      }
    }
    
    final double averageHeight = elementCount > 0 ? (totalHeight / elementCount) : 20.0;
    // Eşik değerini ortalama kelime yüksekliğinin %45'i olarak belirle (8px ile 40px arasına sıkıştır)
    final int verticalThreshold = (averageHeight * 0.45).toInt().clamp(8, 40);

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;
          final int centerY = (box.top + (box.height / 2)).toInt();

          int matchedBinKey = -1;
          for (final binKey in rowBins.keys) {
            if ((centerY - binKey).abs() < verticalThreshold) {
              matchedBinKey = binKey;
              break;
            }
          }

          if (matchedBinKey != -1) {
            rowBins[matchedBinKey]!.add(element);
          } else {
            rowBins[centerY] = [element];
          }
        }
      }
    }

    final List<String> sortedLines = [];
    final List<int> sortedYKeys = rowBins.keys.toList()..sort();

    for (final yKey in sortedYKeys) {
      final List<TextElement> elements = rowBins[yKey]!;
      elements.sort((a, b) {
        final boxA = a.boundingBox;
        final boxB = b.boundingBox;
        return boxA.left.compareTo(boxB.left);
      });
      
      final String lineText = elements.map((e) => e.text).join(' ');
      if (lineText.trim().isNotEmpty) {
        sortedLines.add(lineText);
      }
    }

    return sortedLines;
  }

  /// Bellek yönetimi için servisi serbest bırakır
  void dispose() {
    _textRecognizer.close();
  }
}
