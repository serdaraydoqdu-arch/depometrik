import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/calculator/consumption_calculator.dart';

void main() {
  group('ConsumptionCalculator - Depodan Depoya (Full-to-Full) Testleri', () {
    test('Doğru girdilerle tüketim hesabı başarılı olmalıdır', () {
      final result = ConsumptionCalculator.calculateFullToFull(
        liters: 45.0,
        currentOdometer: 10500,
        previousOdometer: 10000,
      );
      // 45 litre yakıt ile 500 km yol gidildi. Ortalama: 9.0 L / 100km
      expect(result, equals(9.0));
    });

    test('Litre sıfır veya negatif olduğunda ArgumentError fırlatmalıdır', () {
      expect(
        () => ConsumptionCalculator.calculateFullToFull(
          liters: 0,
          currentOdometer: 10500,
          previousOdometer: 10000,
        ),
        throwsArgumentError,
      );

      expect(
        () => ConsumptionCalculator.calculateFullToFull(
          liters: -5.0,
          currentOdometer: 10500,
          previousOdometer: 10000,
        ),
        throwsArgumentError,
      );
    });

    test('Güncel kilometre önceki kilometreden küçük veya eşit olduğunda InvalidOdometerException fırlatmalıdır', () {
      expect(
        () => ConsumptionCalculator.calculateFullToFull(
          liters: 40.0,
          currentOdometer: 10000,
          previousOdometer: 10000,
        ),
        throwsA(isA<InvalidOdometerException>()),
      );

      expect(
        () => ConsumptionCalculator.calculateFullToFull(
          liters: 40.0,
          currentOdometer: 9900,
          previousOdometer: 10000,
        ),
        throwsA(isA<InvalidOdometerException>()),
      );
    });
  });

  group('ConsumptionCalculator - Kayan Ağırlıklı Ortalama (Rolling Average) Testleri', () {
    test('Ardışık kısmi alımlarla kayan ağırlıklı ortalama doğru hesaplanmalıdır', () {
      final refuelings = [
        OdometerAndLiters(odometer: 10000, liters: 0.0, date: DateTime(2026, 6, 1)), // Başlangıç noktası
        OdometerAndLiters(odometer: 10300, liters: 25.0, date: DateTime(2026, 6, 2)), // Kısmi alım 1
        OdometerAndLiters(odometer: 10600, liters: 35.0, date: DateTime(2026, 6, 3)), // Kısmi alım 2
      ];

      final result = ConsumptionCalculator.calculateRollingAverage(refuelings);

      // Toplam mesafe: 600 km
      // Eklenen toplam litre (K0 hariç): 25 + 35 = 60 Litre
      // Tüketim: (60 * 100) / 600 = 10.0 L/100km
      expect(result, equals(10.0));
    });

    test('Sıralanmamış liste verildiğinde otomatik sıralayıp doğru hesaplamalıdır', () {
      final refuelings = [
        OdometerAndLiters(odometer: 10600, liters: 35.0, date: DateTime(2026, 6, 3)), // Son
        OdometerAndLiters(odometer: 10000, liters: 0.0, date: DateTime(2026, 6, 1)),  // İlk
        OdometerAndLiters(odometer: 10300, liters: 25.0, date: DateTime(2026, 6, 2)), // Orta
      ];

      final result = ConsumptionCalculator.calculateRollingAverage(refuelings);
      expect(result, equals(10.0));
    });

    test('En az iki kayıt olmadığında ArgumentError fırlatmalıdır', () {
      expect(
        () => ConsumptionCalculator.calculateRollingAverage([
          OdometerAndLiters(odometer: 10000, liters: 40.0, date: DateTime(2026, 6, 1)),
        ]),
        throwsArgumentError,
      );
    });

    test('Son kilometre başlangıç kilometresinden küçük veya eşit olduğunda InvalidOdometerException fırlatmalıdır', () {
      final invalidList = [
        OdometerAndLiters(odometer: 10000, liters: 0.0, date: DateTime(2026, 6, 1)),
        OdometerAndLiters(odometer: 9900, liters: 40.0, date: DateTime(2026, 6, 2)), // Tarihi daha yeni ama kilometresi eski
      ];

      expect(
        () => ConsumptionCalculator.calculateRollingAverage(invalidList),
        throwsA(isA<InvalidOdometerException>()),
      );
    });
  });
}
