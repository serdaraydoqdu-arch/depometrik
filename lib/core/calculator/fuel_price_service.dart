import '../../data/local/db/db_service.dart';
import '../utils/location_service.dart';

class FuelPriceEstimation {
  final double unitPrice;
  final double liters;
  final DateTime matchedDate;
  final double confidenceScore;
  final String province;

  FuelPriceEstimation({
    required this.unitPrice,
    required this.liters,
    required this.matchedDate,
    required this.confidenceScore,
    required this.province,
  });
}

class FuelPriceService {
  // İlçe ve kısaltmaları şehirlere eşleyen sözlük
  static const Map<String, String> _districtToProvince = {
    'ISTANBUL': 'ISTANBUL',
    'IST': 'ISTANBUL',
    'KARTAL': 'ISTANBUL',
    'PENDIK': 'ISTANBUL',
    'KADIKOY': 'ISTANBUL',
    'TASDELEN': 'ISTANBUL',
    'BESIKTAS': 'ISTANBUL',
    'SISLI': 'ISTANBUL',
    'USKUDAR': 'ISTANBUL',
    'FATIH': 'ISTANBUL',
    'SARIYER': 'ISTANBUL',
    'MALTEPE': 'ISTANBUL',
    'ANKARA': 'ANKARA',
    'ANK': 'ANKARA',
    'CANKAYA': 'ANKARA',
    'YENIMAHALLE': 'ANKARA',
    'KECIOREN': 'ANKARA',
    'MAMAK': 'ANKARA',
    'ETIMESGUT': 'ANKARA',
    'SINCAN': 'ANKARA',
    'IZMIR': 'IZMIR',
    'IZM': 'IZMIR',
    'KONAK': 'IZMIR',
    'BORNOVA': 'IZMIR',
    'KARSIYAKA': 'IZMIR',
    'BUCA': 'IZMIR',
    'ALACATI': 'IZMIR',
    'CESME': 'IZMIR'
  };

  /// Türkçe karakterleri ASCII büyük harfe normalize eder
  static String normalizeString(String text) {
    return text.toUpperCase()
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

  /// İşyeri adından ili çıkarır
  static String extractProvince(String merchantName) {
    final normalized = normalizeString(merchantName);
    
    // Kelimeleri ayır ve ara
    final words = normalized.split(RegExp(r'[^A-Z0-9]+'));
    
    for (final word in words) {
      if (_districtToProvince.containsKey(word)) {
        return _districtToProvince[word]!;
      }
    }

    // Bulunamazsa varsayılan CityPreference.currentCity
    return CityPreference.currentCity;
  }

  /// İşlem tarihi, tutar ve işyeri adına göre yakıt birim fiyatını ve litreyi tahmin eder
  static Future<FuelPriceEstimation?> estimateRefueling({
    required String merchantName,
    required double amount,
    required DateTime transactionDate,
    required String fuelType, // BENZIN, MAZOT, LPG
  }) async {
    final province = extractProvince(merchantName);
    final db = DbService().database;

    FuelPriceEstimation? bestMatch;
    double highestConfidence = -1.0;

    // 4 günlük pencerede geriye dönük arama yap (Provizyon kaymalarını yakalamak için)
    for (int i = 0; i < 4; i++) {
      final dateToCheck = transactionDate.subtract(Duration(days: i));
      final price = await db.getFuelPrice(province, fuelType, dateToCheck);
      if (price == null || price <= 0) continue;

      final estimatedLiters = amount / price;
      final roundedLiters = estimatedLiters.roundToDouble();
      final fractionalPart = (estimatedLiters - roundedLiters).abs();

      double confidence = 0.5; // Baz güven skoru

      // Eğer litre tam sayıya veya yarım litreye çok yakınsa güveni yükselt
      if (fractionalPart < 0.02) {
        confidence += 0.40; // Yüksek güven
      } else if (fractionalPart < 0.05) {
        confidence += 0.25;
      } else if (fractionalPart < 0.1) {
        confidence += 0.10;
      }

      // Litre değeri 5'in katı ise (Örn: 40 LT, 45 LT, 50 LT) ekstra güven ver
      if (roundedLiters.toInt() % 5 == 0 && fractionalPart < 0.05) {
        confidence += 0.05;
      }

      // Tarih kayması sıfır ise küçük bir öncelik ver
      if (i == 0) {
        confidence += 0.02;
      }

      if (confidence > highestConfidence) {
        highestConfidence = confidence;
        bestMatch = FuelPriceEstimation(
          unitPrice: price,
          liters: double.parse(estimatedLiters.toStringAsFixed(2)),
          matchedDate: dateToCheck,
          confidenceScore: confidence > 1.0 ? 1.0 : confidence,
          province: province,
        );
      }
    }

    // Fiyat bulunamadıysa kullanıcının varsayılan ili ile fallback yap
    if (bestMatch == null) {
      final fallbackProvince = CityPreference.currentCity;
      final fallbackPrice = await db.getFuelPrice(fallbackProvince, fuelType, transactionDate);
      if (fallbackPrice != null && fallbackPrice > 0) {
        return FuelPriceEstimation(
          unitPrice: fallbackPrice,
          liters: double.parse((amount / fallbackPrice).toStringAsFixed(2)),
          matchedDate: transactionDate,
          confidenceScore: 0.35, // Düşük güven
          province: fallbackProvince,
        );
      }
    }

    return bestMatch;
  }
}
