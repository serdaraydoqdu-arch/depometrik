import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:depometrik/data/local/db/app_database.dart';
import 'package:depometrik/data/local/db/db_service.dart';
import 'package:depometrik/core/calculator/fuel_price_service.dart';

void main() {
  group('FuelPriceService - Akıllı Akaryakıt Fiyatlandırma ve Konum Eşleştirme Testleri', () {
    late AppDatabase testDb;

    setUp(() async {
      // Testler için izole in-memory veritabanı ilklendir
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
      DbService().setDatabase(testDb);

      // Tabloları oluştur
      await testDb.customStatement('PRAGMA foreign_keys = ON');
    });

    tearDown(() async {
      await testDb.close();
    });

    test('extractProvince - İşyeri adından ili doğru ayıklamalıdır', () {
      expect(FuelPriceService.extractProvince('SHELL KARTAL ISTANBUL'), equals('ISTANBUL'));
      expect(FuelPriceService.extractProvince('OPET CANKAYA ANKARA'), equals('ANKARA'));
      expect(FuelPriceService.extractProvince('BP BORNOVA IZMIR'), equals('IZMIR'));
      
      // İlçe eşleştirmeleriyle ili tahmin etme
      expect(FuelPriceService.extractProvince('OPET TASDELEN'), equals('ISTANBUL')); // Kartal/Taşdelen -> ISTANBUL
      expect(FuelPriceService.extractProvince('BP KONAK PETROL'), equals('IZMIR')); // Konak -> IZMIR
      
      // Bulunamayan durumlarda varsayılan Istanbul döndürmeli
      expect(FuelPriceService.extractProvince('AYTEMIZ ANADOLU YOLU'), equals('ISTANBUL'));
    });

    test('estimateRefueling - 4 günlük zaman penceresiyle en doğru yuvarlak litreyi eşleştirmelidir', () async {
      final targetDate = DateTime(2026, 5, 18);
      
      // Test fiyatlarını veritabanına ekle
      // 18 Mayıs fiyatı: 43.00 TL (2150.00 TL / 43 = 50 Litre tam sayı!)
      // 17 Mayıs fiyatı: 42.50 TL (2150.00 TL / 42.50 = 50.58 Litre küsuratlı)
      await testDb.into(testDb.fuelPrices).insert(
        FuelPricesCompanion.insert(
          provinceCode: 'ISTANBUL',
          fuelType: 'MAZOT',
          priceDate: targetDate,
          price: 43.00,
        ),
        mode: InsertMode.insertOrReplace,
      );

      await testDb.into(testDb.fuelPrices).insert(
        FuelPricesCompanion.insert(
          provinceCode: 'ISTANBUL',
          fuelType: 'MAZOT',
          priceDate: targetDate.subtract(const Duration(days: 1)),
          price: 42.50,
        ),
        mode: InsertMode.insertOrReplace,
      );

      // İşlemi tahmin et (Tarih provizyon gecikmesi nedeniyle 1 gün kaymış olabilir)
      final estimation = await FuelPriceService.estimateRefueling(
        merchantName: 'OPET KARTAL ISTANBUL',
        amount: 2150.00,
        transactionDate: targetDate.add(const Duration(days: 1)), // Fiş tarihi 19 Mayıs (1 gün kaymış)
        fuelType: 'MAZOT',
      );

      expect(estimation, isNotNull);
      expect(estimation!.province, equals('ISTANBUL'));
      // En yüksek güven skorunu veren 18 Mayıs (43.00 TL) seçilmiş olmalı
      expect(estimation.unitPrice, equals(43.00));
      expect(estimation.liters, equals(50.00));
      expect(estimation.matchedDate.day, equals(18));
      expect(estimation.confidenceScore, greaterThan(0.9)); // Yüksek güven
    });
  });
}
