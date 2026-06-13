import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../calculator/fuel_price_sync_service.dart';

class CityPreference {
  static String _currentCity = 'ISTANBUL';

  static String get currentCity => _currentCity;

  static Future<void> setCity(String city) async {
    final normalized = LocationService.normalizeCityName(city);
    _currentCity = normalized;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_city.txt');
      await file.writeAsString(normalized);
      print('CityPreference: Varsayılan şehir kaydedildi: $normalized');
      
      // Fiyatları arka planda otomatik senkronize et
      FuelPriceSyncService.syncPricesForCity(normalized);
    } catch (e) {
      print('CityPreference: Şehir kaydedilirken hata oluştu: $e');
    }
  }

  static Future<void> loadCity() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_city.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          _currentCity = LocationService.normalizeCityName(content.trim());
          print('CityPreference: Kayıtlı şehir yüklendi: $_currentCity');
          
          // Fiyatları arka planda otomatik senkronize et
          FuelPriceSyncService.syncPricesForCity(_currentCity);
          return;
        }
      }
      // Dosya yoksa veya boşsa varsayılan olarak ISTANBUL ayarlayıp senkronize edelim
      await setCity('ISTANBUL');
    } catch (e) {
      print('CityPreference: Kayıtlı şehir yüklenirken hata oluştu: $e');
      // Hata durumunda da bellek içi varsayılanı senkronize edelim
      FuelPriceSyncService.syncPricesForCity(_currentCity);
    }
  }
}

class LocationService {
  /// Türkçe karakterleri ASCII büyük harflere dönüştürür ve temizler.
  static String normalizeCityName(String city) {
    String text = city
        .replaceAll('i', 'I')
        .replaceAll('ı', 'I')
        .replaceAll('İ', 'I')
        .replaceAll('ş', 'S')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', 'G')
        .replaceAll('Ğ', 'G')
        .replaceAll('ç', 'C')
        .replaceAll('Ç', 'C')
        .replaceAll('ö', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('ü', 'U')
        .replaceAll('Ü', 'U');
    
    text = text.toUpperCase().trim();
    // Yaygın ekleri ve temizlikleri yapalım
    text = text.replaceAll(RegExp(r'\s+ILI$'), '');
    text = text.replaceAll(RegExp(r'\s+VALILIGI$'), '');
    return text;
  }

  /// Kullanıcının konum servisinin açık olup olmadığını ve izinlerini denetler, 
  /// ardından geçerli konumu çözerek il ismini döndürür.
  static Future<String?> detectCurrentCity() async {
    try {
      // 1. Konum servisleri etkin mi?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationService: Konum servisleri devre dışı.');
        return null;
      }

      // 2. İzin kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('LocationService: Konum izni reddedildi.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('LocationService: Konum izni kalıcı olarak reddedildi.');
        return null;
      }

      // 3. Konum bilgisini al (Önce son bilinen konumu hızlıca sorgula, yoksa GPS kilidi bekle)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        print('LocationService: Son bilinen konum bulunamadı, GPS aranıyor (timeLimit: 15s)...');
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } else {
        print('LocationService: Son bilinen konum başarıyla önbellekten okundu.');
      }

      // 4. Koordinatlardan adresi çöz (Reverse Geocoding)
      String? cityName;
      try {
        await setLocaleIdentifier('tr_TR');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName = placemark.administrativeArea ?? placemark.subAdministrativeArea;
        }
      } catch (geocodingError) {
        print('LocationService: Yerel geocoding başarısız, OpenStreetMap fallback deneniyor: $geocodingError');
        // Fallback: OpenStreetMap Nominatim API
        try {
          final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
          final response = await http.get(url, headers: {
            'User-Agent': 'DepometrikApp/1.0 (serdar@depometrik.com)'
          }).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data != null && data['address'] != null) {
              final addr = data['address'];
              cityName = addr['province'] ?? addr['city'] ?? addr['state_district'] ?? addr['state'];
            }
          }
        } catch (osmError) {
          print('LocationService: OSM geocoding de başarısız: $osmError');
        }
      }

      if (cityName != null && cityName.isNotEmpty) {
        final normalized = normalizeCityName(cityName);
        print('LocationService: Başarıyla algılanan şehir: $normalized ($cityName)');
        return normalized;
      }
      return null;
    } catch (e) {
      print('LocationService: Şehir algılanırken genel hata oluştu: $e');
      return null;
    }
  }
}
