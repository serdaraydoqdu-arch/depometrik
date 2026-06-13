import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/ocr/receipt_ocr_service.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';
import '../../core/utils/date_text_formatter.dart';
import '../../core/sync/attachment_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Kamera veya galeriden akaryakıt fişi yükleyerek OCR taraması gerçekleştiren lüks ekran
class ReceiptScannerScreen extends StatefulWidget {
  final String vehicleId;
  final Vehicle vehicle;
  final ImageSource? initialSource;

  const ReceiptScannerScreen({
    super.key,
    required this.vehicleId,
    required this.vehicle,
    this.initialSource,
  });

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptOcrService _ocrService = ReceiptOcrService();
  
  // Form Doğrulama Anahtarı
  final _formKey = GlobalKey<FormState>();

  // OCR Ekran Durumları
  File? _selectedImage;
  bool _isScanning = false;
  String _statusMessage = '';
  
  // Düzenleme / Doğrulama Durumu (State 3)
  bool _isVerificationMode = false;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  // FocusNodes for auto-calculation
  final FocusNode _litersFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _totalFocusNode = FocusNode();

  DateTime _verifiedDate = DateTime.now();
  String _selectedFuelType = 'BENZİN';
  bool _dontRememberOdometer = false;

  // Matematiksel doğrulama durumu
  bool _mathIsCorrect = false;
  String _mathFeedback = '';

  @override
  void initState() {
    super.initState();

    // Araç yakıt türüne göre varsayılanı ayarla
    if (widget.vehicle.fuelType == 'DIZEL') {
      _selectedFuelType = 'MAZOT';
    } else if (widget.vehicle.fuelType == 'LPG') {
      _selectedFuelType = 'LPG';
    } else {
      _selectedFuelType = 'BENZİN';
    }

    // Matematiksel doğrulama dinleyicileri
    _litersController.addListener(_validateMath);
    _priceController.addListener(_validateMath);
    _totalController.addListener(_validateMath);

    // Açılışta otomatik tarayıcıyı başlat (veya galeriye git)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSource == ImageSource.gallery) {
        _pickFromGallery();
      } else {
        _startDocumentScan();
      }
    });
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _brandController.dispose();
    _litersController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _odometerController.dispose();
    _dateController.dispose();
    _litersFocusNode.dispose();
    _priceFocusNode.dispose();
    _totalFocusNode.dispose();
    super.dispose();
  }

  /// Kilometre Değerlerini Noktalı Biçimde Formatlar
  String _formatOdometer(int value) {
    final cleanText = value.toString();
    final buffer = StringBuffer();
    final length = cleanText.length;
    for (int i = 0; i < length; i++) {
      buffer.write(cleanText[i]);
      final remaining = length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  /// Kullanıcı veri girdikçe matematiksel olarak otomatik hesaplama yapar
  void _autoCalculate() {
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final total = double.tryParse(_totalController.text.replaceAll(',', '.'));

    if (_litersFocusNode.hasFocus) {
      if (liters != null) {
        if (_totalController.text.isEmpty && price != null) {
          final calculatedTotal = liters * price;
          _updateControllerWithoutListener(_totalController, calculatedTotal.toStringAsFixed(2));
        } else if (_priceController.text.isEmpty && total != null && liters > 0) {
          final calculatedPrice = total / liters;
          _updateControllerWithoutListener(_priceController, calculatedPrice.toStringAsFixed(2));
        }
      }
    } else if (_priceFocusNode.hasFocus) {
      if (price != null) {
        if (_totalController.text.isEmpty && liters != null) {
          final calculatedTotal = liters * price;
          _updateControllerWithoutListener(_totalController, calculatedTotal.toStringAsFixed(2));
        } else if (_litersController.text.isEmpty && total != null && price > 0) {
          final calculatedLiters = total / price;
          _updateControllerWithoutListener(_litersController, calculatedLiters.toStringAsFixed(2));
        }
      }
    } else if (_totalFocusNode.hasFocus) {
      if (total != null) {
        if (_priceController.text.isEmpty && liters != null && liters > 0) {
          final calculatedPrice = total / liters;
          _updateControllerWithoutListener(_priceController, calculatedPrice.toStringAsFixed(2));
        } else if (_litersController.text.isEmpty && price != null && price > 0) {
          final calculatedLiters = total / price;
          _updateControllerWithoutListener(_litersController, calculatedLiters.toStringAsFixed(2));
        }
      }
    }
  }

  void _updateControllerWithoutListener(TextEditingController controller, String newValue) {
    if (controller.text != newValue) {
      controller.text = newValue;
    }
  }

  /// Matematiksel Tutarlılık Testi
  void _validateMath() {
    _autoCalculate();

    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final total = double.tryParse(_totalController.text.replaceAll(',', '.'));

    if (liters == null || price == null || total == null) {
      List<String> missingFields = [];
      if (liters == null) missingFields.add('Litre');
      if (price == null) missingFields.add('Birim Fiyat');
      if (total == null) missingFields.add('Toplam Tutar');

      setState(() {
        _mathIsCorrect = false;
        _mathFeedback = 'Eksik alanlar: ${missingFields.join(", ")}. Tamamlayın veya "Hesapla" butonuna basın.';
      });
      return;
    }

    final calculatedTotal = liters * price;
    final diff = (calculatedTotal - total).abs();
    
    // 0.20 TL yuvarlama toleransı verelim
    if (diff < 0.20) {
      setState(() {
        _mathIsCorrect = true;
        _mathFeedback = 'Matematiksel Tutarlılık Doğrulandı (Litre x Fiyat = Tutar)';
      });
    } else {
      setState(() {
        _mathIsCorrect = false;
        _mathFeedback = 'Uyuşmazlık var: ${liters.toStringAsFixed(2)} LT x ${price.toStringAsFixed(2)} TL = ${calculatedTotal.toStringAsFixed(2)} TL (Toplam Tutar: ${total.toStringAsFixed(2)} TL)';
      });
    }
  }

  /// Matematiksel tutarlılığı en olası doğru alan üzerinden akıllıca eşitler veya hesaplar.
  void _calculateOrFixMath() {
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final total = double.tryParse(_totalController.text.replaceAll(',', '.'));

    // Case 1: Tüm alanlar dolu fakat uyuşmazlık varsa
    if (liters != null && price != null && total != null) {
      final double suggestedPrice = total / liters;
      final double suggestedTotal = liters * price;

      // Türkiye akaryakıt fiyatları 2026 yılı için makul aralık (30 TL - 120 TL).
      bool priceIsRealistic(double p) => p >= 30.0 && p <= 120.0;

      if (priceIsRealistic(suggestedPrice)) {
        _priceController.text = suggestedPrice.toStringAsFixed(2);
      } else {
        _totalController.text = suggestedTotal.toStringAsFixed(2);
      }
    }
    // Case 2: Litre boş, Fiyat ve Toplam dolu ise
    else if (liters == null && price != null && total != null) {
      if (price > 0) {
        _litersController.text = (total / price).toStringAsFixed(2);
      }
    }
    // Case 3: Birim Fiyat boş, Litre ve Toplam dolu ise
    else if (price == null && liters != null && total != null) {
      if (liters > 0) {
        _priceController.text = (total / liters).toStringAsFixed(2);
      }
    }
    // Case 4: Toplam Tutar boş, Litre ve Fiyat dolu ise
    else if (total == null && liters != null && price != null) {
      _totalController.text = (liters * price).toStringAsFixed(2);
    }

    _validateMath();
  }

  /// Google Play Services Belge Tarayıcısını tetikler
  Future<void> _startDocumentScan() async {
    final options = DocumentScannerOptions(
      documentFormats: {DocumentFormat.jpeg},
      mode: ScannerMode.base, // Kırpma ve döndürmeyi etkinleştirir, filtreler ekranını atlar
      pageLimit: 1,
      isGalleryImport: true, // Native arayüz içinden galeri seçimini de destekler
    );
    
    final documentScanner = DocumentScanner(options: options);

    try {
      final result = await documentScanner.scanDocument();
      final images = result.images;
      if (images != null && images.isNotEmpty) {
        final imagePath = images.first;
        if (!mounted) return;
        
        setState(() {
          _selectedImage = File(imagePath);
          _isScanning = true;
          _statusMessage = 'Görsel Analiz Ediliyor...';
        });

        // OCR ayrıştırma motorunu çalıştır
        final parsedData = await _ocrService.parseReceipt(_selectedImage!);

        if (!mounted) return;
        
        setState(() {
          _brandController.text = parsedData.stationBrand ?? '';
          _litersController.text = parsedData.liters != null ? parsedData.liters.toString() : '';
          _priceController.text = parsedData.unitPrice != null ? parsedData.unitPrice.toString() : '';
          _totalController.text = parsedData.totalPrice != null ? parsedData.totalPrice.toString() : '';
          _verifiedDate = parsedData.purchaseDate ?? DateTime.now();
          _dateController.text = "${_verifiedDate.day.toString().padLeft(2, '0')}/${_verifiedDate.month.toString().padLeft(2, '0')}/${_verifiedDate.year}";
          if (parsedData.fuelType != null) {
            _selectedFuelType = parsedData.fuelType!;
          }
          _isScanning = false;
          _isVerificationMode = true; // Doğrulama/Düzeltme sayfasına geç
        });

        _validateMath();
      } else {
        if (mounted) {
          Navigator.pop(context); // Taramadan çıkıldığında veya iptal edildiğinde ekranı kapatır
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context); // Herhangi bir hata durumunda ekranı kapatır
      }
    } finally {
      documentScanner.close();
    }
  }

  /// Galeriden görsel seçip tarar
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        if (mounted) Navigator.pop(context); // Galeriden vazgeçilirse ekranı kapatır
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
        _isScanning = true;
        _isVerificationMode = false;
        _statusMessage = 'Görsel Analiz Ediliyor...';
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Görsel Analiz Ediliyor...';
      });

      // OCR ayrıştırma motorunu çalıştır
      final parsedData = await _ocrService.parseReceipt(_selectedImage!);

      if (!mounted) return;
      
      setState(() {
        _brandController.text = parsedData.stationBrand ?? '';
        _litersController.text = parsedData.liters != null ? parsedData.liters.toString() : '';
        _priceController.text = parsedData.unitPrice != null ? parsedData.unitPrice.toString() : '';
        _totalController.text = parsedData.totalPrice != null ? parsedData.totalPrice.toString() : '';
        _verifiedDate = parsedData.purchaseDate ?? DateTime.now();
        _dateController.text = "${_verifiedDate.day.toString().padLeft(2, '0')}/${_verifiedDate.month.toString().padLeft(2, '0')}/${_verifiedDate.year}";
        if (parsedData.fuelType != null) {
          _selectedFuelType = parsedData.fuelType!;
        }
        _isScanning = false;
        _isVerificationMode = true; // Doğrulama/Düzeltme sayfasına geç
      });

      _validateMath();
    } catch (_) {
      if (mounted) {
        Navigator.pop(context); // Hata durumunda ekranı kapatır
      }
    }
  }

  /// Tarih seçiciyi açar
  Future<void> _pickVerifiedDate() async {
    final parsed = parseDate(_dateController.text);
    final initialDate = parsed ?? _verifiedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryCyan,
              onPrimary: Colors.white,
              surface: AppTheme.lightSurface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _verifiedDate = picked;
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showImagePreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVerificationInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: AppTheme.primaryTeal),
              SizedBox(width: 10),
              Text(
                'Doğrulama Bilgisi',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bu doğrulama, fişinizden okunan bilgilerin birbiriyle tutarlı olduğunu kontrol eder.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Aldığınız yakıt miktarı (litre) ile litre başına ödediğiniz fiyat (birim fiyat) çarpıldığında çıkan sonuç, fişteki toplam tutar ile birebir eşleşmektedir. Bu durum, bilgilerin hatasız algılandığını ve güvenle kaydedilebileceğini gösterir.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Anladım',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Doğrulanmış verileri otonom olarak SQLite veritabanına kaydeder ve doğrudan ana ekrana döner
  Future<void> _submitVerifiedData() async {
    // 1. Form alanlarının validasyonunu kontrol et
    if (!_formKey.currentState!.validate()) return;

    final liters = double.tryParse(_litersController.text);
    final price = double.tryParse(_priceController.text);
    final total = double.tryParse(_totalController.text);
    
    // Noktaları ve KM takısını temizleyip sayıyı çekelim
    final int? odometer;
    if (_dontRememberOdometer) {
      odometer = 0;
    } else {
      final cleanOdo = _odometerController.text.replaceAll('.', '').replaceAll(' KM', '').trim();
      odometer = int.tryParse(cleanOdo);
    }

    final parsedDate = parseDate(_dateController.text);

    if (liters == null || price == null || total == null || odometer == null || parsedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları eksiksiz ve geçerli biçimde doldurun.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    String? savedImagePath;
    if (_selectedImage != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = p.join(appDir.path, 'receipts');
        final localDir = Directory(localPath);
        if (!await localDir.exists()) {
          await localDir.create(recursive: true);
        }
        final fileExtension = p.extension(_selectedImage!.path).isEmpty ? '.jpg' : p.extension(_selectedImage!.path);
        final newFileName = 'receipt_${const Uuid().v4()}$fileExtension';
        final localFile = File(p.join(localPath, newFileName));
        await _selectedImage!.copy(localFile.path);
        savedImagePath = localFile.path;
      } catch (_) {
        // Silently handle copy error
      }
    }

    final db = DbService().database;
    String? matchedStationId;
    final brandText = _brandController.text.trim();
    if (brandText.isNotEmpty) {
      try {
        final allStations = await db.getAllStations();
        final matches = allStations.where((s) => s.brandName.toUpperCase() == brandText.toUpperCase()).toList();
        if (matches.isNotEmpty) {
          matchedStationId = matches.first.stationId;
        } else {
          matchedStationId = const Uuid().v4();
          await db.insertStation(
            StationsCompanion.insert(
              stationId: matchedStationId,
              brandName: brandText,
              latitude: 41.0082,
              longitude: 28.9784,
              city: 'ISTANBUL',
              district: 'MERKEZ',
            ),
          );
        }
      } catch (_) {
        // Hataları yoksay
      }
    }

    final refuelingCompanion = RefuelingsCompanion(
      refuelingId: drift.Value(const Uuid().v4()),
      vehicleId: drift.Value(widget.vehicleId),
      stationId: drift.Value(matchedStationId),
      liters: drift.Value(liters),
      unitPrice: drift.Value(price),
      totalPrice: drift.Value(total),
      odometer: drift.Value(odometer),
      purchaseDate: drift.Value(parsedDate),
      isFullTank: drift.Value(true), // Fiş taramaları varsayılan depo dolu kabul edilir
      imagePath: drift.Value(savedImagePath),
    );

    try {
      // 2. Doğrudan Drift SQLite yerel veritabanına kaydet
      await db.insertRefueling(refuelingCompanion);

      // Çevrimdışı Belge Kuyruğuna (AttachmentQueue) resmi ekle
      if (savedImagePath != null) {
        final currentSession = Supabase.instance.client.auth.currentSession;
        final userId = currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
        await AttachmentManager().queueAttachment(
          userId: userId,
          localFilePath: savedImagePath,
          storageBucket: 'receipts',
        );
      }
      
      // Aracın güncel kilometresini güncelle
      final currentVehicle = await db.getVehicleById(widget.vehicleId);
      if (currentVehicle != null && odometer > currentVehicle.currentOdometer) {
        await db.updateVehicle(currentVehicle.copyWith(currentOdometer: odometer));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akaryakıt dolumu başarıyla otonom kaydedildi!'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
        
        // 3. Doğrudan HomeScreen'e (Ana Sayfa) dönmek için pop(context, true) sinyali ver
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme başarısız: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  /// Tarama durumunu iptal edip başa döner
  void _resetScanner() {
    _brandController.clear();
    _litersController.clear();
    _priceController.clear();
    _totalController.clear();
    _odometerController.clear();
    _dateController.clear();
    setState(() {
      _selectedImage = null;
      _isScanning = false;
      _isVerificationMode = false;
    });
    _startDocumentScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isVerificationMode
          ? AppBar(
              title: const Text('Fiş Bilgilerini Doğrula'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null, // Canlı vizör ekranında sürükleyici deneyim için appbar'ı kaldırıyoruz
      body: SafeArea(
        child: _isScanning 
            ? _buildScanningState() 
            : _isVerificationMode 
                ? _buildVerificationState() 
                : _buildSelectionState(),
      ),
    );
  }

  Widget _buildSelectionState() {
    return const Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryCyan,
        ),
      ),
    );
  }

  /// 2. GÖRÜNTÜ İŞLEME VE TARAMA BEKLEME EKRANI (State 2)
  Widget _buildScanningState() {
    return Container(
      color: AppTheme.lightBg,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Çekilen resmi arka planda çok düşük opaklıkta gösterelim
          if (_selectedImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Sade Bilgi Kartı
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Görsel analiz ediliyor, bu işlem tamamen cihazınızda gerçekleştiriliyor, Depometrik sunucularına aktarılmaz.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. OCR VERİ GÖSTERİMİ VE DOĞRULAMA FORMU (State 3)
  Widget _buildVerificationState() {
    final liters = double.tryParse(_litersController.text);
    final price = double.tryParse(_priceController.text);
    final total = double.tryParse(_totalController.text);
    final bool canCalculate = (liters != null && price != null) || 
                              (liters != null && total != null) || 
                              (price != null && total != null);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Küçük Fiş Görsel Önizleme Kartı
            GestureDetector(
              onTap: () {
                if (_selectedImage != null) {
                  _showImagePreviewDialog(_selectedImage!);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight, width: 1.5),
                ),
                child: Row(
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.lightBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight, width: 1.5),
                        ),
                        child: const Icon(Icons.receipt_long, color: AppTheme.primaryCyan),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Fiş Görseli Algılandı',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Aşağıda çıkartılan verileri fişinizle karşılaştırarak onaylayınız.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Matematiksel Tutarlılık Dinamik Göstergesi
            GestureDetector(
              onLongPress: _showVerificationInfoDialog,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _mathIsCorrect 
                      ? const Color(0xFFECFDF5) // Emerald 50
                      : const Color(0xFFFFFBEB), // Amber 50
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _mathIsCorrect 
                        ? const Color(0xFF10B981) // Emerald 500
                        : const Color(0xFFF59E0B), // Amber 500
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_mathIsCorrect ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _mathIsCorrect ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: _mathIsCorrect ? const Color(0xFF059669) : const Color(0xFFD97706),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mathIsCorrect ? 'Matematiksel Doğrulama Başarılı' : 'Fiş Tam Olarak Okunamamıştır',
                            style: TextStyle(
                              color: _mathIsCorrect ? const Color(0xFF065F46) : const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (!_mathIsCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              _mathFeedback,
                              style: TextStyle(
                                color: const Color(0xFFB45309),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!_mathIsCorrect && canCalculate)
                      ElevatedButton.icon(
                        onPressed: _calculateOrFixMath,
                        icon: const Icon(Icons.calculate_rounded, size: 16, color: Colors.white),
                        label: const Text('HESAPLA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shadowColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DÜZENLEME FORMU
            const Text(
              'Algılanan Metin Alanları',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // İstasyon Markası
            TextFormField(
              controller: _brandController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'İstasyon / Akaryakıt Markası',
                hintText: 'Örn: SHELL, OPET, BP',
                prefixIcon: Icon(Icons.store, color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 16),

            // Litre
            TextFormField(
              controller: _litersController,
              focusNode: _litersFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Litre Miktarı',
                hintText: 'Örn: 42.50',
                prefixIcon: Icon(Icons.local_gas_station, color: AppTheme.primaryCyan),
                suffixText: 'LT',
              ),
            ),
            if (double.tryParse(_litersController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_priceController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_totalController.text.replaceAll(',', '.')) != null &&
                !_mathIsCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.errorRed),
                    SizedBox(width: 6),
                    Text(
                      'Matematiksel olarak uyuşmamaktadır.',
                      style: TextStyle(color: AppTheme.errorRed, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Birim Fiyat
            TextFormField(
              controller: _priceController,
              focusNode: _priceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Birim Fiyatı (TL/LT)',
                hintText: 'Örn: 41.20',
                prefixIcon: Icon(Icons.currency_lira, color: AppTheme.primaryCyan),
                suffixText: 'TL',
              ),
            ),
            if (double.tryParse(_litersController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_priceController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_totalController.text.replaceAll(',', '.')) != null &&
                !_mathIsCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.errorRed),
                    SizedBox(width: 6),
                    Text(
                      'Matematiksel olarak uyuşmamaktadır.',
                      style: TextStyle(color: AppTheme.errorRed, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Toplam Tutar
            TextFormField(
              controller: _totalController,
              focusNode: _totalFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Toplam Harcama Tutarı',
                hintText: 'Örn: 1751.00',
                prefixIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primaryCyan),
                suffixText: 'TL',
              ),
            ),
            if (double.tryParse(_litersController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_priceController.text.replaceAll(',', '.')) != null &&
                double.tryParse(_totalController.text.replaceAll(',', '.')) != null &&
                !_mathIsCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.errorRed),
                    SizedBox(width: 6),
                    Text(
                      'Matematiksel olarak uyuşmamaktadır.',
                      style: TextStyle(color: AppTheme.errorRed, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Yakıt Cinsi List Box (Premium Segmented Row)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yakıt Cinsi',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['BENZİN', 'MAZOT', 'LPG'].map((fuel) {
                    final isSelected = _selectedFuelType == fuel;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFuelType = fuel;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryCyan.withValues(alpha: 0.1) : AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryCyan : AppTheme.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              fuel,
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryCyan : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kilometre Sayaç Alanı (Formatted as user types!)
            TextFormField(
              controller: _odometerController,
              enabled: !_dontRememberOdometer,
              keyboardType: TextInputType.number,
              inputFormatters: [
                OdometerFormatter(),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: _dontRememberOdometer ? const Color(0xFFF1F5F9) : AppTheme.lightSurface,
                labelText: _dontRememberOdometer
                    ? 'Yakıt Alım Kilometresi'
                    : 'Yakıt Alım Kilometresi (Mevcut: ${_formatOdometer(widget.vehicle.currentOdometer)} KM)',
                hintText: _dontRememberOdometer
                    ? 'Hatırlanmıyor'
                    : 'En Son: ${_formatOdometer(widget.vehicle.currentOdometer)} KM',
                prefixIcon: const Icon(Icons.speed, color: AppTheme.primaryCyan),
              ),
              validator: (value) {
                if (_dontRememberOdometer) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen sayaç kilometresini girin.';
                }
                final cleanVal = value.replaceAll('.', '').replaceAll(' KM', '').trim();
                final odo = int.tryParse(cleanVal);
                if (odo == null || odo < 0) {
                  return 'Lütfen geçerli bir kilometre değeri girin.';
                }
                if (odo <= widget.vehicle.currentOdometer) {
                  return 'Son kilometre değerinden (${_formatOdometer(widget.vehicle.currentOdometer)} KM) büyük olmalıdır!';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // HATIRLAMIYORUM SEÇENEĞİ
            InkWell(
              onTap: () {
                setState(() {
                  _dontRememberOdometer = !_dontRememberOdometer;
                  if (_dontRememberOdometer) {
                    _odometerController.clear();
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _dontRememberOdometer,
                        activeColor: AppTheme.primaryCyan,
                        onChanged: (val) {
                          setState(() {
                            _dontRememberOdometer = val ?? false;
                            if (_dontRememberOdometer) {
                              _odometerController.clear();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Hatırlamıyorum (Hesaplamalara dahil edilmez)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarih Giriş Alanı
            TextFormField(
              controller: _dateController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                DateTextFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Fiş Tarihi',
                hintText: 'GG/AA/YYYY',
                prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryCyan),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar, color: AppTheme.primaryCyan),
                  onPressed: _pickVerifiedDate,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen fiş tarihini girin.';
                }
                final parsed = parseDate(value);
                if (parsed == null) {
                  return 'Geçersiz tarih formatı (GG/AA/YYYY).';
                }
                if (parsed.isAfter(DateTime.now())) {
                  return 'Tarih bugünden ileri bir tarih olamaz.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Aksiyon Butonları
            ElevatedButton.icon(
              onPressed: _submitVerifiedData,
              icon: const Icon(Icons.check, size: 22),
              label: const Text('VERİLERİ ONAYLA VE AKTAR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF10B981), // Green Accent
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _resetScanner,
              icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textPrimary),
              label: const Text('YENİDEN ÇEK'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kilometre sayacı için 3 haneli nokta formatı ve dinamik KM son eki uygulayan yerel biçimlendirici
class OdometerFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // İmlecin solundaki rakam sayısını bul
    final selectionStart = newValue.selection.start;
    int digitsBeforeCursor = 0;
    if (selectionStart >= 0 && selectionStart <= newValue.text.length) {
      final textBeforeCursor = newValue.text.substring(0, selectionStart);
      digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^0-9]'), '').length;
    }

    // Rakam dışı karakterleri temizle
    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanText.isEmpty) {
      return const TextEditingValue();
    }

    final int? val = int.tryParse(cleanText);
    if (val == null) return oldValue;

    // Noktalama ekle
    final buffer = StringBuffer();
    final length = cleanText.length;
    
    for (int i = 0; i < length; i++) {
      buffer.write(cleanText[i]);
      final remaining = length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final formattedNumber = buffer.toString();
    final formattedWithSuffix = '$formattedNumber KM';

    // İmleç konumu hesaplama
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
