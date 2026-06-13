import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';

/// Ekstreden ayıklanan akaryakıt işlemini temsil eden geçici veri yapısı
class PdfTransaction {
  final String id;
  final DateTime date;
  final String merchantName;
  final double amount;

  PdfTransaction({
    String? id,
    required this.date,
    required this.merchantName,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  @override
  String toString() {
    return 'PdfTransaction(id: $id, date: $date, merchantName: $merchantName, amount: $amount)';
  }
}

/// KVKK uyumlu yerel ekstre analiz motoru
class PdfStatementParser {
  // Türkiye'deki popüler akaryakıt istasyonu marka anahtar kelimeleri (Aytemiz hariç)
  static const List<String> _fuelKeywords = [
    'SHELL',
    'OPET',
    'BP',
    'PETROL OFIS',
    'PETROL OFİS',
    'TOTAL',
    'AYGAZ',
    'LUKOIL',
    'TP',
    'MILANGAZ',
    'IPRAGAZ',
    'SUNPET',
    'KADOIL',
    'STARPET',
    'QPLUS',
  ];

  /// Yerel PDF dosyasını yükler, RAM üzerinde satır satır süzerek akaryakıt harcamalarını ayıklar.
  /// KVKK gereği akaryakıt dışı tüm satırlar RAM bellekten anında atılır.
  Future<List<PdfTransaction>> parseStatement(File file, {bool parseAll = false}) async {
    final List<PdfTransaction> refuelingTransactions = [];

    try {
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      // 1. Dokümandaki en yaygın 4 haneli yılı tespit et (kısa DD.MM tarihleri için kullanılacak)
      int inferredYear = DateTime.now().year;
      final StringBuffer allTextBuffer = StringBuffer();
      // Performans için ilk 5 sayfayı taramak yeterlidir
      final int scanPagesCount = document.pages.count > 5 ? 5 : document.pages.count;
      for (int i = 0; i < scanPagesCount; i++) {
        allTextBuffer.writeln(extractor.extractText(startPageIndex: i, endPageIndex: i));
      }
      inferredYear = _inferYearFromText(allTextBuffer.toString());

      // Tutar regex: Sayı grubu, nokta/virgül binlik ve ondalık ayraçlar (Örn: 1.250,50 veya 850,00)
      // Satırın genellikle sonlarında yer alan parasal tutarı yakalar.
      final amountRegex = RegExp(r'(\d{1,3}(?:\.\d{3})*,\d{2})|(\d+,\d{2})|(\d+\.\d{2})');

      // Çok satırlı/sütunlu ekstrelerde işlem verilerini birleştirmek için state machine değişkenleri
      DateTime? pendingDate;
      String? pendingMerchant;

      for (int i = 0; i < document.pages.count; i++) {
        // Her sayfayı tek tek süzgece tabi tutarak RAM optimizasyonu sağla
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        final List<String> lines = pageText.split('\n');

        for (final line in lines) {
          final cleanLine = line.trim();
          if (cleanLine.isEmpty) continue;

          // A. Satırdaki tarihi ayıklayıp güncel tut
          final parsedDate = _parseDateFromLine(cleanLine, inferredYear);

          // B. Tarihi Satırdan Kaldırıp Kalanı Alma (Tutar ve açıklama ile karışmaması için)
          final datePattern = RegExp(r'\b\d{1,4}[\.\/-]\d{1,2}[\.\/-]\d{1,4}\b|\b\d{1,2}[\.\/-]\d{1,2}\b');
          final lineWithoutDate = cleanLine.replaceAll(datePattern, '').trim();

          // C. Tutar Ayıklama (Tarih kaldırılmış satırdan)
          double? currentLineAmount;
          final amountMatches = amountRegex.allMatches(lineWithoutDate).toList();
          if (amountMatches.isNotEmpty) {
            for (int m = amountMatches.length - 1; m >= 0; m--) {
              final matchStr = amountMatches[m].group(0);
              if (matchStr != null) {
                final val = _parseDouble(matchStr);
                if (val != null && val > 0) {
                  currentLineAmount = val;
                  break;
                }
              }
            }
          }

          // D. Durum Yönetimi (State Machine)
          if (parsedDate != null) {
            pendingDate = parsedDate;
            pendingMerchant = null;

            // Eğer aynı satırda tutar da varsa (tek satırlı ekstreler)
            if (currentLineAmount != null) {
              final merchant = _extractDescription(cleanLine, parsedDate, amountMatches);
              refuelingTransactions.add(
                PdfTransaction(
                  date: parsedDate,
                  merchantName: merchant.isNotEmpty ? merchant : 'Harcama',
                  amount: currentLineAmount,
                ),
              );
            }
          } else if (currentLineAmount != null) {
            // Satırda tutar var ama tarih yok. Bekleyen bir tarihimiz varsa işlemi kaydederiz.
            if (pendingDate != null) {
              refuelingTransactions.add(
                PdfTransaction(
                  date: pendingDate,
                  merchantName: (pendingMerchant != null && pendingMerchant.isNotEmpty)
                      ? pendingMerchant
                      : 'Harcama',
                  amount: currentLineAmount,
                ),
              );
              pendingMerchant = null; // Bir kere kullandık, temizleyelim
            }
          } else {
            // Satırda ne tarih ne tutar var. Bu satır bir açıklama/işyeri adıdır.
            if (pendingDate != null) {
              // Sistem metinlerini filtrele
              final upperLine = cleanLine.toUpperCase();
              if (!upperLine.contains('HALKBANK') &&
                  !upperLine.contains('SAYFA') &&
                  !upperLine.contains('TOPLAM') &&
                  !upperLine.contains('FAİZLER VE PROVİZYON')) {
                pendingMerchant = cleanLine;
              }
            }
          }
        }
      }

      document.dispose();
    } catch (e) {
      // Hata durumunda boş liste döner
    }

    if (parseAll) {
      return refuelingTransactions;
    } else {
      // Sadece akaryakıt olanları filtrele
      final List<PdfTransaction> fuelOnly = [];
      for (final tx in refuelingTransactions) {
        final txUpper = tx.merchantName.toUpperCase();
        bool isFuel = false;
        for (final keyword in _fuelKeywords) {
          if (txUpper.contains(keyword)) {
            isFuel = true;
            break;
          }
        }
        if (isFuel) {
          fuelOnly.add(tx);
        }
      }
      return fuelOnly;
    }
  }

  /// Ekstre metnindeki en sık geçen yılı tespit eder (2020-2035 arası)
  int _inferYearFromText(String allText) {
    final yearRegex = RegExp(r'\b(202[0-9]|203[0-5])\b');
    final matches = yearRegex.allMatches(allText);
    if (matches.isEmpty) {
      return DateTime.now().year;
    }

    final Map<int, int> yearCounts = {};
    for (final match in matches) {
      final year = int.tryParse(match.group(1) ?? '');
      if (year != null) {
        yearCounts[year] = (yearCounts[year] ?? 0) + 1;
      }
    }

    int bestYear = DateTime.now().year;
    int maxCount = 0;
    yearCounts.forEach((year, count) {
      if (count > maxCount) {
        maxCount = count;
        bestYear = year;
      }
    });

    return bestYear;
  }

  /// İşyeri adındaki fazla rakamları ve karakterleri temizler
  /// Bir işyeri adının akaryakıt firması olup olmadığını kontrol eder
  static bool isFuelMerchant(String merchantName) {
    final txUpper = merchantName.toUpperCase();
    for (final keyword in _fuelKeywords) {
      if (txUpper.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Satır içerisinden farklı tarih formatlarını yakalar
  DateTime? _parseDateFromLine(String line, int inferredYear) {
    final cleanLine = line.trim();

    // 1. Format: YYYY.MM.DD veya YYYY/MM/DD veya YYYY-MM-DD
    final ymdRegex = RegExp(r'\b(\d{4})[\.\/-](\d{1,2})[\.\/-](\d{1,2})\b');
    final ymdMatch = ymdRegex.firstMatch(cleanLine);
    if (ymdMatch != null) {
      final year = int.tryParse(ymdMatch.group(1) ?? '');
      final month = int.tryParse(ymdMatch.group(2) ?? '');
      final day = int.tryParse(ymdMatch.group(3) ?? '');
      if (year != null && month != null && day != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    // 2. Format: DD.MM.YYYY veya DD/MM/YYYY veya DD-MM-YYYY
    final dmyRegex = RegExp(r'\b(\d{1,2})[\.\/-](\d{1,2})[\.\/-](\d{4})\b');
    final dmyMatch = dmyRegex.firstMatch(cleanLine);
    if (dmyMatch != null) {
      final day = int.tryParse(dmyMatch.group(1) ?? '');
      final month = int.tryParse(dmyMatch.group(2) ?? '');
      final year = int.tryParse(dmyMatch.group(3) ?? '');
      if (day != null && month != null && year != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    // 3. Format: DD.MM.YY veya DD/MM/YY veya DD-MM-YY
    final dmyyRegex = RegExp(r'\b(\d{1,2})[\.\/-](\d{1,2})[\.\/-](\d{2})\b');
    final dmyyMatch = dmyyRegex.firstMatch(cleanLine);
    if (dmyyMatch != null) {
      final day = int.tryParse(dmyyMatch.group(1) ?? '');
      final month = int.tryParse(dmyyMatch.group(2) ?? '');
      final yearVal = int.tryParse(dmyyMatch.group(3) ?? '');
      if (day != null && month != null && yearVal != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final year = yearVal < 100 ? 2000 + yearVal : yearVal;
          return DateTime(year, month, day);
        }
      }
    }

    // 4. Format: DD.MM veya DD/MM veya DD-MM (Sadece satırın başında arayarak tutarla karışmasını önleriz)
    final dmRegex = RegExp(r'\b(\d{1,2})[\.\/-](\d{1,2})\b');
    final dmMatches = dmRegex.allMatches(cleanLine);
    for (final dmMatch in dmMatches) {
      if (dmMatch.start < 20) {
        final day = int.tryParse(dmMatch.group(1) ?? '');
        final month = int.tryParse(dmMatch.group(2) ?? '');
        if (day != null && month != null) {
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            // Bir sonraki karakterin nokta/eğik çizgi olmadığından emin ol (örn: DD.MM.YYYY formatının parçası olmasın)
            final postMatchIndex = dmMatch.end;
            if (postMatchIndex < cleanLine.length) {
              final nextChar = cleanLine[postMatchIndex];
              if (nextChar == '.' || nextChar == '/' || nextChar == '-') {
                continue;
              }
            }
            return DateTime(inferredYear, month, day);
          }
        }
      }
    }

    return null;
  }

  /// Sayı formatını ayrıştırıp double değere güvenle çevirir
  double? _parseDouble(String value) {
    String cleanVal = value.trim();
    if (cleanVal.contains('.') && cleanVal.contains(',')) {
      cleanVal = cleanVal.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleanVal = cleanVal.replaceAll(',', '.');
    }
    return double.tryParse(cleanVal);
  }

  String _extractDescription(String line, DateTime date, List<RegExpMatch> amountMatches) {
    String clean = line;
    final datePattern = RegExp(r'\b\d{1,4}[\.\/-]\d{1,2}[\.\/-]\d{1,4}\b|\b\d{1,2}[\.\/-]\d{1,2}\b');
    clean = clean.replaceAll(datePattern, '');

    for (final match in amountMatches) {
      final matchStr = match.group(0);
      if (matchStr != null) {
        clean = clean.replaceAll(matchStr, '');
      }
    }

    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length > 50) {
      clean = clean.substring(0, 50).trim();
    }
    return clean.isEmpty ? 'Harcama' : clean;
  }
}
