/// SMS'ten ayıklanan işlem verisi
class SmsTransaction {
  final DateTime date;
  final String merchantName;
  final double amount;
  final String? rawBody;

  SmsTransaction({
    required this.date,
    required this.merchantName,
    required this.amount,
    this.rawBody,
  });

  @override
  String toString() {
    return 'SmsTransaction(date: $date, merchantName: $merchantName, amount: $amount, rawBody: $rawBody)';
  }
}

/// Türkiye bankalarından gelen işlem bildirim SMS'lerini analiz eden ayrıştırma motoru
class SmsParserService {
  // Türkiye'de bilinen popüler akaryakıt istasyonu marka anahtar kelimeleri
  static const List<String> _fuelBrands = [
    'SHELL',
    'OPET',
    'BP',
    'PETROL OFISI',
    'PETROL OFISİ',
    'TOTAL',
    'AYGAZ',
    'LUKOIL',
    'TP',
    'MILANGAZ',
    'IPRAGAZ',
    'AYTEMIZ',
    'AYTEMİZ',
    'SUNPET',
    'KADOIL',
    'STARPET',
  ];

  // Türkiye'de yaygın bankaların SMS başlık ve metin anahtar kelimeleri
  static const List<String> _bankKeywords = [
    'HALKBANK',
    'GARANTI',
    'AKBANK',
    'YAPI KREDI',
    'YAPIBANK',
    'ISBANK',
    'İS BANK',
    'ZIRAAT',
    'VAKIFBANK',
    'QNB',
    'FINANSBANK',
    'TEB',
    'HSBC',
    'DENIZBANK',
    'SEKERBANK',
    'ING',
  ];

  /// Gelen bir SMS metnini analiz edip akaryakıt harcaması ise verileri ayıklar
  SmsTransaction? parseSms(String smsBody, {DateTime? smsDate, String? sender}) {
    final bodyUpper = smsBody.toUpperCase();
    final senderUpper = sender?.toUpperCase() ?? '';
    final transactionDate = smsDate ?? DateTime.now();

    // 0. Kampanya ve Tanıtım Mesajı Filtresi (Harcama Olmayan Reklam/Promosyonları Ele)
    final negativeKeywords = [
      'KAMPANYA', 'KAZAN', 'HEDIYE', 'HEDİYE', 'FIRSAT', 'KATIL', 
      'RET YAZ', 'MERSIS', 'MERSİS', '3404', 'BEDAVA', 'INDIRIM', 
      'İNDİRİM', 'HAK KAZAN', 'YAPACAGINIZ', 'YAPACAĞINIZ',
      'ALISVERISINIZE', 'ALIŞVERİŞİNİZE', 'KAMPANYASINA'
    ];
    for (final kw in negativeKeywords) {
      if (bodyUpper.contains(kw)) {
        return null; // Reklam veya kampanya mesajıdır, harcama değil!
      }
    }

    // 1. Banka Harcama Doğrulaması (Eğer sender başlığı varsa banka/kart sorgusu veya finansal kalıp ile süz)
    bool isBankOrValidTransaction = false;
    for (final bank in _bankKeywords) {
      if (senderUpper.contains(bank) || bodyUpper.contains(bank)) {
        isBankOrValidTransaction = true;
        break;
      }
    }

    // Kredi kartı markaları ve SMS BTK operatör kodları (Türkiye'deki banka mesajları B001-B003 gibi kodlar taşır)
    if (!isBankOrValidTransaction) {
      final terms = [
        'BONUS', 'MAXIMUM', 'WORLD', 'AXESS', 'PARAF', 'CARDFINANS', 'WINGS',
        'B001', 'B002', 'B003', 'B018', 'B030', 'B043', 'B250'
      ];
      for (final term in terms) {
        if (senderUpper.contains(term) || bodyUpper.contains(term)) {
          isBankOrValidTransaction = true;
          break;
        }
      }
    }

    // Gönderen doğrudan akaryakıt markası ise kabul et
    if (!isBankOrValidTransaction && senderUpper.isNotEmpty) {
      for (final brand in _fuelBrands) {
        if (senderUpper.contains(brand)) {
          isBankOrValidTransaction = true;
          break;
        }
      }
    }

    // Eğer ne banka/kart ne de akaryakıt göndereni eşleştiyse, gönderen doluysa
    // genel SMS spamlarını (sohbet vb.) engellemek için finansal kelime/tutar kontrolü yap
    if (!isBankOrValidTransaction && senderUpper.isNotEmpty) {
      final hasFinancialKeyword = bodyUpper.contains('TL') || 
                                 bodyUpper.contains('TUTAR') || 
                                 bodyUpper.contains('HARCAMA') || 
                                 bodyUpper.contains('ISLEM') || 
                                 bodyUpper.contains('İŞLEM') ||
                                 bodyUpper.contains('KART');
      if (!hasFinancialKeyword) return null;
    }
    
    // 2. Akaryakıt markası tespiti
    String? matchedBrand;
    for (final brand in _fuelBrands) {
      if (bodyUpper.contains(brand)) {
        // Özel Önlem: Link veya protokollerin (TP:// veya TPS://) yanlışlıkla 'TP' markası sanılmasını engelle
        if (brand == 'TP') {
          if (bodyUpper.contains('TP://') || bodyUpper.contains('TPS://') || bodyUpper.contains('HTTP') || bodyUpper.contains('WWW.')) {
            continue;
          }
          final regexTp = RegExp(r'\bTP\b');
          if (!regexTp.hasMatch(bodyUpper)) {
            continue;
          }
        }
        matchedBrand = brand;
        break;
      }
    }

    // Eğer akaryakıt markası içermiyorsa bu SMS bir akaryakıt harcaması değildir
    if (matchedBrand == null) return null;

    // 2. Harcama Tutarını Ayıklama (Örn: "1.250,50 TL", "850.00 TL", "1250,00 TL", "750 TL")
    // Parasal miktarları TL/tutar ifadesi ile eşleşen regexler ile ara
    final amountRegexes = [
      RegExp(r'(\d+(?:\.\d{3})*,\d{2})\s*(?:TL|TUTARINDA)'), // 1.250,50 TL veya 1.250,50 tutarında
      RegExp(r'(\d+,\d{2})\s*(?:TL|TUTARINDA)'),            // 850,00 TL
      RegExp(r'(\d+\.\d{2})\s*(?:TL|TUTARINDA)'),            // 850.00 TL
      RegExp(r'(\d+)\s*(?:TL|TUTARINDA)'),                  // 850 TL
    ];

    double? parsedAmount;
    for (final regex in amountRegexes) {
      final match = regex.firstMatch(bodyUpper);
      if (match != null) {
        final valStr = match.group(1);
        if (valStr != null) {
          final val = _parseDouble(valStr);
          if (val != null && val > 0) {
            parsedAmount = val;
            break;
          }
        }
      }
    }

    // Eğer tutar ayıklanamadıysa alternatif olarak tüm parasal ifadeleri dene
    if (parsedAmount == null) {
      final genericAmountRegex = RegExp(r'(\d{1,3}(?:\.\d{3})*,\d{2})|(\d+,\d{2})|(\d+\.\d{2})|(\d+)\s*TL');
      final matches = genericAmountRegex.allMatches(smsBody).toList();
      for (final match in matches) {
        final matchStr = match.group(0)?.replaceAll('TL', '').trim();
        if (matchStr != null) {
          final val = _parseDouble(matchStr);
          if (val != null && val > 0) {
            parsedAmount = val;
            break;
          }
        }
      }
    }

    if (parsedAmount == null || parsedAmount <= 0) return null;

    // 3. İşyeri İsmini Temizleme (Eğer SMS'te detaylı şube bilgisi varsa alalım)
    String merchantName = matchedBrand;
    final brandIndex = bodyUpper.indexOf(matchedBrand);
    if (brandIndex != -1) {
      // Marka adından sonra gelen kelimeleri süzerek şube/istasyon adını belirle
      // Genelde şöyledir: "... SHELL ANKARA ISTASYONUNDAN ... TL harcama yapıldı"
      // Markanın etrafındaki kelimeleri (yaklaşık 35 karakter) alıp temizleyelim
      final startIdx = brandIndex;
      final endIdx = (brandIndex + 35 < smsBody.length) ? brandIndex + 35 : smsBody.length;
      String contextSnippet = smsBody.substring(startIdx, endIdx).trim();
      
      // Tutar, TL ve "harcama", "işlem" gibi kelimeleri temizle
      contextSnippet = contextSnippet
          .replaceAll(RegExp(r'\d+.*'), '')
          .replaceAll(RegExp(r'(?:TL|TUTARINDA|HARCAMA|ISLEM|İŞLEM|YAPILDI|HARCANDI|LTD|AST|AS\b|A\.S\.)', caseSensitive: false), '')
          .trim();

      if (contextSnippet.endsWith('-') || contextSnippet.endsWith(',') || contextSnippet.endsWith('.')) {
        contextSnippet = contextSnippet.substring(0, contextSnippet.length - 1).trim();
      }

      if (contextSnippet.isNotEmpty) {
        merchantName = contextSnippet.toUpperCase();
      }
    }

    return SmsTransaction(
      date: transactionDate,
      merchantName: merchantName,
      amount: parsedAmount,
      rawBody: smsBody,
    );
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
}
