import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../utils/location_service.dart';

class FuelPriceSyncService {
  /// Petrol Ofisi web sitesinden güncel fiyatları çeker ve yerel Drift veritabanına yazar.
  static Future<void> syncPricesForCity(String city) async {
    final normalizedCity = LocationService.normalizeCityName(city);
    print('FuelPriceSyncService: $normalizedCity şehri için fiyatlar güncelleniyor (Petrol Ofisi)...');

    try {
      final url = Uri.parse('https://www.petrolofisi.com.tr/akaryakit-fiyatlari');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('FuelPriceSyncService: HTTP Hatası: ${response.statusCode}');
        return;
      }

      // Whitespace ve yeni satırları temizleyelim
      final bodyClean = response.body.replaceAll(RegExp(r'\s+'), ' ');

      final rowRegex = RegExp(r'<tr class="price-row[^"]*"[^>]*data-disctrict-name="([^"]*)"[^>]*>(.*?)</tr>');
      final tdRegex = RegExp(r'<td>(.*?)</td>');
      final taxRegex = RegExp(r'<span class="with-tax">(.*?)</span>');

      final rowMatches = rowRegex.allMatches(bodyClean);
      if (rowMatches.isEmpty) {
        print('FuelPriceSyncService: Fiyat tablosu satırları bulunamadı.');
        return;
      }

      final Map<String, List<Map<String, double>>> cityPrices = {};

      for (final match in rowMatches) {
        final poCity = match.group(1)!;
        final rowHtml = match.group(2)!;

        final tdMatches = tdRegex.allMatches(rowHtml);
        final List<String> prices = [];

        for (final tdMatch in tdMatches) {
          final tdHtml = tdMatch.group(1)!;
          final taxMatch = taxRegex.firstMatch(tdHtml);
          if (taxMatch != null) {
            prices.add(taxMatch.group(1)!.trim());
          } else {
            // HTML etiketlerini temizle
            final cleanVal = tdHtml.replaceAll(RegExp(r'<[^>]+>'), '').trim();
            if (cleanVal.isNotEmpty) {
              prices.add(cleanVal);
            }
          }
        }

        if (prices.length >= 7) {
          final appCity = _mapPoCityToAppCity(poCity);
          final benzinVal = double.tryParse(prices[1].replaceAll(',', '.'));
          final motorinVal = double.tryParse(prices[2].replaceAll(',', '.'));
          final lpgVal = double.tryParse(prices[6].replaceAll(',', '.'));

          if (appCity != null && benzinVal != null && motorinVal != null && lpgVal != null) {
            cityPrices.putIfAbsent(appCity, () => []).add({
              'benzin': benzinVal,
              'motorin': motorinVal,
              'lpg': lpgVal,
            });
          }
        }
      }

      // Şehir fiyatlarını hesaplayalım (İstanbul için AVRUPA ve ANADOLU ortalamasını alacak)
      if (!cityPrices.containsKey(normalizedCity)) {
        print('FuelPriceSyncService: $normalizedCity için fiyat bilgisi bulunamadı.');
        return;
      }

      final cityDataList = cityPrices[normalizedCity]!;
      double sumBenzin = 0;
      double sumMotorin = 0;
      double sumLpg = 0;
      for (final item in cityDataList) {
        sumBenzin += item['benzin']!;
        sumMotorin += item['motorin']!;
        sumLpg += item['lpg']!;
      }

      final avgBenzin = double.parse((sumBenzin / cityDataList.length).toStringAsFixed(2));
      final avgMotorin = double.parse((sumMotorin / cityDataList.length).toStringAsFixed(2));
      final avgLpg = double.parse((sumLpg / cityDataList.length).toStringAsFixed(2));

      final db = DbService().database;
      final today = DateTime.now();
      final cleanToday = DateTime(today.year, today.month, today.day);

      await db.batch((batch) {
        batch.insert(
          db.fuelPrices,
          FuelPricesCompanion.insert(
            provinceCode: normalizedCity,
            fuelType: 'BENZIN',
            priceDate: cleanToday,
            price: avgBenzin,
          ),
          mode: InsertMode.insertOrReplace,
        );
        batch.insert(
          db.fuelPrices,
          FuelPricesCompanion.insert(
            provinceCode: normalizedCity,
            fuelType: 'MAZOT',
            priceDate: cleanToday,
            price: avgMotorin,
          ),
          mode: InsertMode.insertOrReplace,
        );
        batch.insert(
          db.fuelPrices,
          FuelPricesCompanion.insert(
            provinceCode: normalizedCity,
            fuelType: 'LPG',
            priceDate: cleanToday,
            price: avgLpg,
          ),
          mode: InsertMode.insertOrReplace,
        );
      });

      print('FuelPriceSyncService: $normalizedCity için güncel fiyatlar başarıyla kaydedildi: Benzin $avgBenzin, Motorin $avgMotorin, LPG $avgLpg');
    } catch (e) {
      print('FuelPriceSyncService: Fiyat senkronizasyonu sırasında hata oluştu: $e');
    }
  }

  static String? _mapPoCityToAppCity(String poCity) {
    final clean = poCity.trim().toUpperCase();
    if (clean == 'ISTANBUL (AVRUPA)' || clean == 'ISTANBUL (ANADOLU)') {
      return 'ISTANBUL';
    }
    if (clean == 'AFYON') {
      return 'AFYONKARAHISAR';
    }
    return clean;
  }
}
