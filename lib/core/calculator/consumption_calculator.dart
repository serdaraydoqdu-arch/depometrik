/// DepoMetrik Akaryakıt Tüketim Hesaplama Motoru
/// Bu modül "Depodan Depoya" ve "Kayan Ağırlıklı Ortalama" formüllerini çalıştırır.
class OdometerAndLiters {
  final int odometer;
  final double liters;
  final DateTime? date;

  OdometerAndLiters({
    required this.odometer,
    required this.liters,
    this.date,
  });
}

class InvalidOdometerException implements Exception {
  final String message;
  InvalidOdometerException(this.message);

  @override
  String toString() => 'InvalidOdometerException: $message';
}

class ConsumptionCalculator {
  /// **Depodan Depoya (Full-to-Full) Hesaplama Metodu**
  /// İki ardışık "Depo Dolu" yakıt alımı arasındaki tüketim oranını hesaplar.
  /// Formül: C_i = (Litre * 100) / (Güncel Kilometre - Önceki Kilometre)
  static double calculateFullToFull({
    required double liters,
    required int currentOdometer,
    required int previousOdometer,
  }) {
    if (liters <= 0) {
      throw ArgumentError("Yakıt miktarı (litre) sıfırdan büyük olmalıdır.");
    }
    if (currentOdometer <= previousOdometer) {
      throw InvalidOdometerException(
        "Güncel kilometre ($currentOdometer), önceki kilometreden ($previousOdometer) büyük olmalıdır."
      );
    }

    final distance = currentOdometer - previousOdometer;
    return (liters * 100.0) / distance;
  }

  /// **Kayan Ağırlıklı Ortalama (Rolling Average) Hesaplama Metodu**
  /// Deponun tam doldurulmadığı kısmi alımlarda, belirli bir izleme periyodundaki (n adet işlem) tüketimi hesaplar.
  /// Formül: C_rolling = (Toplam Litre * 100) / (K_n - K_0)
  /// Burada K_0 ilk işlemin kilometresi, K_n son işlemin kilometresidir.
  /// Toplam Litre, 1. indisten n. indise kadar eklenen tüm yakıt litrajlarının toplamıdır.
  static double calculateRollingAverage(List<OdometerAndLiters> refuelings) {
    if (refuelings.length < 2) {
      throw ArgumentError("Kayan ağırlıklı ortalama için en az iki yakıt alım kaydı gereklidir.");
    }

    // Tarihe göre sıralıyoruz (Eğer tarihler mevcutsa), yoksa verilen sırayı koruyoruz
    final sorted = List<OdometerAndLiters>.from(refuelings);
    if (sorted.any((e) => e.date != null)) {
      sorted.sort((a, b) => (a.date ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.date ?? DateTime.fromMillisecondsSinceEpoch(0)));
    }

    // Kilometrenin kronolojik olarak strictly increasing (sürekli artan) olduğunu doğruluyoruz
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].odometer <= sorted[i - 1].odometer) {
        throw InvalidOdometerException(
          "Kilometre sayaç değerleri kronolojik olarak artmalıdır. Önceki: ${sorted[i - 1].odometer}, Güncel: ${sorted[i].odometer}"
        );
      }
      if (sorted[i].liters < 0) {
        throw ArgumentError("Yakıt miktarı (litre) negatif olamaz.");
      }
    }

    // İlk yakıt kaydı K0 başlangıç referansıdır. Tüketilen yakıt ise sonraki alımların toplamıdır.
    final k0 = sorted.first.odometer;
    final kn = sorted.last.odometer;

    double totalLiters = 0.0;
    for (int i = 1; i < sorted.length; i++) {
      // Rolling average için kısmi alımlarda litrelerin pozitif olması gerekir (0 başlangıç alımı hariç)
      if (sorted[i].liters <= 0) {
        throw ArgumentError("Tüketim hesaplaması için eklenen yakıt miktarı sıfırdan büyük olmalıdır.");
      }
      totalLiters += sorted[i].liters;
    }

    final distance = kn - k0;
    return (totalLiters * 100.0) / distance;
  }
}
