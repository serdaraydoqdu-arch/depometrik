import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateFieldKey = GlobalKey<FormFieldState<String>>();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _odometerController = TextEditingController();
  final _plateFocusNode = FocusNode();
  
  String _selectedFuelType = 'BENZIN';
  bool _isSubmitting = false;

  final List<String> _fuelTypes = ['BENZIN', 'DIZEL', 'LPG', 'ELEKTRIK'];

  @override
  void initState() {
    super.initState();
    _plateFocusNode.addListener(() {
      if (!_plateFocusNode.hasFocus) {
        _plateFieldKey.currentState?.validate(); // Sadece plaka alanını doğrula!
      }
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _odometerController.dispose();
    _plateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    setState(() {
      _isSubmitting = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final currentSession = Supabase.instance.client.auth.currentSession;
    final userId = currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
    final userEmail = currentSession?.user.email ?? 'serdar@depometrik.com';

    // Plakayı boşluksuz temizleyip standart formata getiriyoruz (Örn: 34ABC123)
    final formattedPlate = _plateController.text.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final formattedBrand = _brandController.text.trim().toUpperCase();
    final rawModel = _modelController.text.trim();
    final formattedModel = rawModel.isEmpty
        ? ''
        : rawModel[0].toUpperCase() + rawModel.substring(1).toLowerCase();
    
    // Odometer'daki binlik ayırıcı noktaları ve KM takısını siliyoruz
    final cleanOdoStr = _odometerController.text.replaceAll('.', '').replaceAll(' KM', '').trim();
    final initialOdo = int.parse(cleanOdoStr);

    // Önce kullanıcı kaydını oluşturuyoruz (Kısıtlamaları aşmak için Drift'te)
    final db = DbService().database;
    final profile = await db.getProfileById(userId);
    if (profile == null) {
      await db.insertProfile(
        ProfilesCompanion(
          userId: drift.Value(userId),
          email: drift.Value(userEmail),
          premiumStatus: const drift.Value(true),
        ),
      );
    }

    final vehicleCompanion = VehiclesCompanion(
      vehicleId: drift.Value(const Uuid().v4()),
      userId: drift.Value(userId),
      plate: drift.Value(formattedPlate),
      brand: drift.Value(formattedBrand),
      model: drift.Value(formattedModel),
      fuelType: drift.Value(_selectedFuelType),
      initialOdometer: drift.Value(initialOdo),
      currentOdometer: drift.Value(initialOdo),
    );

    try {
      await db.insertVehicle(vehicleCompanion);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Araç başarıyla kaydedildi.'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Araç Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Araç Bilgileri',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tüketim hesaplamalarını başlatabilmek için aracınızı tanımlayın.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // TEST ARACI BUTONU (GEÇİCİ)
              ElevatedButton.icon(
                onPressed: () {
                  _plateController.text = '34TEST123';
                  _brandController.text = 'TEST';
                  _modelController.text = 'Model';
                  _odometerController.text = '100000';
                  setState(() {
                    _selectedFuelType = 'BENZIN';
                  });
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Test Aracı Bilgilerini Doldur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // PLAKA
              TextFormField(
                key: _plateFieldKey,
                controller: _plateController,
                focusNode: _plateFocusNode,
                textCapitalization: TextCapitalization.characters,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  TurkishPlateFormatter(),
                ],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  labelText: 'Plaka',
                  hintText: 'Örn: 34ABC123',
                  prefixIcon: Icon(Icons.directions_car, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen araç plakasını girin.';
                  }
                  
                  // Komut 2 (Boşluk Temizleme)
                  final cleanPlate = value.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
                  
                  if (cleanPlate.length < 2) {
                    return _plateFocusNode.hasFocus && !_isSubmitting ? null : 'Geçersiz plaka formatı.';
                  }

                  // Komut 4 (Geçerli İl Kodları)
                  final cityCodeStr = cleanPlate.substring(0, 2);
                  final cityCode = int.tryParse(cityCodeStr);
                  if (cityCode == null || cityCode < 1 || cityCode > 81) {
                    return 'Geçersiz İl Kodu! (01-81 arası olmalıdır)';
                  }

                  // Komut 5 (Yasaklı Harf Blokajı)
                  if (RegExp(r'[ÇĞİÖŞÜ]').hasMatch(cleanPlate)) {
                    return 'Tescil kuralları gereği Ç, Ğ, İ, Ö, Ş, Ü harfleri kullanılamaz!';
                  }

                  // KULLANICI ODAKLANMIŞSA VE YAZIYORSA:
                  // 82 gibi mutlak hataları yukarıda anında uyarıyoruz.
                  // Ancak 81 gibi henüz eksik olan sivil plaka kombinasyon uyarılarını
                  // kullanıcı yazmayı bitirene kadar (odağı kaybedene dek) erteliyoruz.
                  if (_plateFocusNode.hasFocus && !_isSubmitting) {
                    return null;
                  }

                  // Komut 6 (Son Hane Sayısal Kontrolü)
                  if (!RegExp(r'[0-9]{2}$').hasMatch(cleanPlate)) {
                    return 'Plakanın en az son iki hanesi rakam olmalıdır.';
                  }

                  // 3. Geçerli Kombinasyon Formasyonları
                  final isPattern1 = RegExp(r'^\d{2}[A-Z]\d{4}$').hasMatch(cleanPlate); // 99 X 9999
                  final isPattern2 = RegExp(r'^\d{2}[A-Z]{2}\d{3}$').hasMatch(cleanPlate); // 99 XX 999
                  final isPattern3 = RegExp(r'^\d{2}[A-Z]{2}\d{4}$').hasMatch(cleanPlate); // 99 XX 9999
                  final isPattern4 = RegExp(r'^\d{2}[A-Z]{3}\d{2}$').hasMatch(cleanPlate); // 99 XXX 99
                  final isPattern5 = RegExp(r'^\d{2}[A-Z]{3}\d{3}$').hasMatch(cleanPlate); // 99 XXX 999
                  final isPattern6 = RegExp(r'^\d{2}[A-Z]\d{5}$').hasMatch(cleanPlate); // 99 X 99999

                  if (!isPattern1 && !isPattern2 && !isPattern3 && !isPattern4 && !isPattern5 && !isPattern6) {
                    return 'Geçersiz sivil plaka kombinasyonu!';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // MARKA
              TextFormField(
                controller: _brandController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  StrictLatinFormatter(toUppercase: true),
                ],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  hintText: 'Örn: FIAT, RENAULT, BMW',
                  prefixIcon: Icon(Icons.branding_watermark, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen araç markasını girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // MODEL
              TextFormField(
                controller: _modelController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  StrictLatinFormatter(toUppercase: false, toTitleCase: true),
                ],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Örn: Egea, Clio, 320i',
                  prefixIcon: Icon(Icons.model_training, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen araç modelini girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // YAKIT TÜRÜ
              DropdownButtonFormField<String>(
                initialValue: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: 'Yakıt Türü',
                  prefixIcon: Icon(Icons.local_gas_station, color: AppTheme.primaryCyan),
                ),
                dropdownColor: AppTheme.lightSurface,
                items: _fuelTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // BAŞLANGIÇ KİLOMETRESİ
              TextFormField(
                controller: _odometerController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  ThousandsSeparatorFormatter(),
                ],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  labelText: 'Başlangıç Kilometresi',
                  hintText: 'Örn: 125.000',
                  prefixIcon: Icon(Icons.speed, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen aracın güncel kilometresini girin.';
                  }
                  final cleanValue = value.replaceAll('.', '').replaceAll(' KM', '').trim();
                  if (int.tryParse(cleanValue) == null || int.parse(cleanValue) < 0) {
                    return 'Lütfen geçerli bir kilometre değeri girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // KAYDET BUTONU
              ElevatedButton(
                onPressed: _saveVehicle,
                child: const Text('ARACI KAYDET'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. TÜRKİYE PLAKA GİRİŞ BİÇİMLENDİRİCİSİ (INPUT FORMATTER - STRICT ASCII CHECK)
class TurkishPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Türkçe karakterleri doğrudan Latin karşılıklarına veya boşluğa dönüştür/sil
    String text = newValue.text
        .replaceAll('i', 'I')
        .replaceAll('ı', 'I')
        .replaceAll('İ', 'I')
        .replaceAll('ş', '')
        .replaceAll('Ş', '')
        .replaceAll('ğ', '')
        .replaceAll('Ğ', '')
        .replaceAll('ç', '')
        .replaceAll('Ç', '')
        .replaceAll('ö', '')
        .replaceAll('Ö', '')
        .replaceAll('ü', '')
        .replaceAll('Ü', '');

    // 2. Büyük harfe zorla
    text = text.toUpperCase();

    // 3. Sadece İngilizce A-Z (65-90) ve 0-9 (48-57) karakterlerini kabul et (Strict ASCII check)
    final strictAsciiBuffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if ((code >= 65 && code <= 90) || (code >= 48 && code <= 57)) {
        strictAsciiBuffer.write(text[i]);
      }
    }
    text = strictAsciiBuffer.toString();

    // KURAL: İlk iki hane yazılmadan harf yazılmasını engelleme (İlk 2 karakter sadece rakam olmalı)
    if (text.isNotEmpty && !RegExp(r'^\d').hasMatch(text)) {
      return oldValue; // İlk karakter rakam değilse reddet
    }
    if (text.length > 1 && !RegExp(r'^\d{2}').hasMatch(text)) {
      return oldValue; // İlk iki karakter rakam değilse reddet
    }

    // KURAL: En fazla 3 harfe izin verme (3'ten fazla harf almamalı)
    final letters = text.replaceAll(RegExp(r'[^A-Z]'), '');
    if (letters.length > 3) {
      return oldValue; // 3 harften fazlasını reddet
    }

    // Komut 3 (Maksimum Karakter Sınırı - Boşluksuz max 8 karakter)
    if (text.length > 8) {
      return oldValue; // 8 karakterden fazlasını reddet
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// 5. BİNLİK AYIRICI FORMATLAYICI (THOUSANDS SEPARATOR FORMATTER)
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Kullanıcı yeni metinde imleci nereye konumlandırdıysa, imlecin solundaki rakam sayısını buluyoruz.
    final selectionStart = newValue.selection.start;
    int digitsBeforeCursor = 0;
    if (selectionStart >= 0 && selectionStart <= newValue.text.length) {
      final textBeforeCursor = newValue.text.substring(0, selectionStart);
      digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^0-9]'), '').length;
    }

    // Rakam dışındaki tüm karakterleri temizliyoruz
    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanText.isEmpty) {
      return const TextEditingValue();
    }

    final int? val = int.tryParse(cleanText);
    if (val == null) return oldValue;

    // Binlik ayırıcıyı nokta (.) olarak el ile biçimlendiriyoruz
    final buffer = StringBuffer();
    final length = cleanText.length;
    
    for (int i = 0; i < length; i++) {
      buffer.write(cleanText[i]);
      final remaining = length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.'); // Her 3 rakamda bir nokta koy
      }
    }

    final formattedNumber = buffer.toString();
    final formattedWithSuffix = '$formattedNumber KM';

    // Yeni biçimlendirilmiş metinde imlecin konumlanacağı doğru ofseti hesaplıyoruz (imlecin solundaki rakam sayısına göre)
    int newSelectionOffset = 0;
    int digitsSeen = 0;
    for (int i = 0; i < formattedNumber.length; i++) {
      if (digitsSeen == digitsBeforeCursor) {
        newSelectionOffset = i;
        break;
      }
      if (RegExp(r'[0-9]').hasMatch(formattedNumber[i])) {
        digitsSeen++;
      }
    }
    
    // Güvenlik ve sınır kontrolleri: İmleç en sonda ise veya " KM" son ekinin içindeyse, sayının bittiği yere sabitliyoruz.
    if (digitsSeen == digitsBeforeCursor && newSelectionOffset == 0 && digitsBeforeCursor > 0) {
      newSelectionOffset = formattedNumber.length;
    } else if (digitsSeen < digitsBeforeCursor || selectionStart > newValue.text.length - 3) {
      newSelectionOffset = formattedNumber.length;
    }

    return TextEditingValue(
      text: formattedWithSuffix,
      selection: TextSelection.collapsed(offset: newSelectionOffset),
    );
  }
}

// 6. DETAYLI ARAMALI SEÇİM PANELİ (MÜŞTERİ TALEBİ ÜZERİNE GEÇİCİ OLARAK PASİFE ALINDI)
// Gelecek fazlarda manuel giriş yerine arama listesi eklenebilir.

// 7. STRICT ASCII LATIN KARAKTER DÖNÜŞTÜRÜCÜ & FORMATLAYICI (STRICT LATIN FORMATTER WITH CURSOR PRESERVATION)
class StrictLatinFormatter extends TextInputFormatter {
  final bool toUppercase;
  final bool toTitleCase;

  StrictLatinFormatter({this.toUppercase = false, this.toTitleCase = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Türkçe karakterleri doğrudan Latin karşılıklarına veya boşluğa dönüştür/sil
    text = text
        .replaceAll('i', 'I')
        .replaceAll('ı', 'I')
        .replaceAll('İ', 'I')
        .replaceAll('ş', toUppercase ? 'S' : 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', toUppercase ? 'G' : 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ç', toUppercase ? 'C' : 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ö', toUppercase ? 'O' : 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ü', toUppercase ? 'U' : 'u')
        .replaceAll('Ü', 'U');

    if (toUppercase) {
      text = text.toUpperCase();
    }

    // Sadece İngilizce A-Z (65-90), a-z (97-122), 0-9 (48-57), boşluk (32), tire (45), eğik çizgi (47) ve nokta (46) karakterlerini kabul et (Strict ASCII check)
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if ((code >= 65 && code <= 90) || 
          (code >= 97 && code <= 122) || 
          (code >= 48 && code <= 57) || 
          code == 32 || 
          code == 45 || 
          code == 47 ||
          code == 46) {
        buffer.write(text[i]);
      }
    }
    
    String formattedText = buffer.toString();
    if (toTitleCase && formattedText.isNotEmpty) {
      formattedText = formattedText[0].toUpperCase() + formattedText.substring(1).toLowerCase();
    }

    // İmleç konumunu akıllıca koruma
    final selectionStart = newValue.selection.start;
    int validCharsBeforeCursor = 0;
    if (selectionStart >= 0 && selectionStart <= newValue.text.length) {
      final textBeforeCursor = newValue.text.substring(0, selectionStart);
      for (int i = 0; i < textBeforeCursor.length; i++) {
        final char = textBeforeCursor[i];
        final code = char.codeUnitAt(0);
        if ((code >= 65 && code <= 90) || 
            (code >= 97 && code <= 122) || 
            (code >= 48 && code <= 57) || 
            code == 32 || code == 45 || code == 47 || code == 46 ||
            'iıİşŞğĞçÇöÖüÜ'.contains(char)) {
          validCharsBeforeCursor++;
        }
      }
    }

    int newSelectionOffset = validCharsBeforeCursor;
    if (newSelectionOffset > formattedText.length) {
      newSelectionOffset = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionOffset),
    );
  }
}
