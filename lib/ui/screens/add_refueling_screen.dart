import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';
import '../../core/utils/date_text_formatter.dart';
import 'receipt_scanner_screen.dart';
import '../../core/calculator/fuel_price_service.dart';

class AddRefuelingScreen extends StatefulWidget {
  final String? initialVehicleId;
  final CardTransaction? initialCardTransaction;
  final Refueling? editRefueling;
  const AddRefuelingScreen({
    super.key,
    this.initialVehicleId,
    this.initialCardTransaction,
    this.editRefueling,
  });

  @override
  State<AddRefuelingScreen> createState() => _AddRefuelingScreenState();
}

class _AddRefuelingScreenState extends State<AddRefuelingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _odometerController = TextEditingController();
  final _dateController = TextEditingController();

  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  Vehicle? _selectedVehicle;

  DateTime _selectedDate = DateTime.now();
  bool _isFullTank = true;
  bool _isAutoCalculating = false;
  FuelPriceEstimation? _estimation;
  bool _isEstimating = false;
  bool _dontRememberOdometer = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();

    if (widget.initialCardTransaction != null) {
      _selectedDate = widget.initialCardTransaction!.transactionDate;
      _totalPriceController.text = widget.initialCardTransaction!.amount.toStringAsFixed(2);
    }
    _dateController.text = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    // Gelişmiş 3 yönlü otomatik hesaplama dinleyicileri
    _setupCalculationListeners();
  }

  String _formatOdometerValue(int value) {
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
    return '$buffer KM';
  }

  @override
  void dispose() {
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _totalPriceController.dispose();
    _odometerController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final db = DbService().database;
    final currentSession = Supabase.instance.client.auth.currentSession;
    final userId = currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
    final list = await db.getVehiclesForUser(userId);
    setState(() {
      _vehicles = list;
      if (widget.editRefueling != null) {
        _selectedVehicleId = widget.editRefueling!.vehicleId;
      } else if (widget.initialVehicleId != null && list.any((v) => v.vehicleId == widget.initialVehicleId)) {
        _selectedVehicleId = widget.initialVehicleId;
      } else if (list.isNotEmpty) {
        _selectedVehicleId = list.first.vehicleId;
      }
      _updateSelectedVehicle();

      if (widget.editRefueling != null) {
        _litersController.text = widget.editRefueling!.liters.toStringAsFixed(2);
        _pricePerLiterController.text = widget.editRefueling!.unitPrice.toStringAsFixed(2);
        _totalPriceController.text = widget.editRefueling!.totalPrice.toStringAsFixed(2);
        if (widget.editRefueling!.odometer == 0) {
          _dontRememberOdometer = true;
          _odometerController.text = '';
        } else {
          _odometerController.text = _formatOdometerValue(widget.editRefueling!.odometer);
        }
        _selectedDate = widget.editRefueling!.purchaseDate;
        _dateController.text = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
        _isFullTank = widget.editRefueling!.isFullTank;
      }
    });

    if (widget.initialCardTransaction != null) {
      _estimateInitialValues();
    }
  }

  Future<void> _estimateInitialValues() async {
    if (_selectedVehicle == null || widget.initialCardTransaction == null) return;
    
    setState(() {
      _isEstimating = true;
    });

    String fType = 'BENZIN';
    final vehicleFuel = _selectedVehicle!.fuelType.toUpperCase();
    if (vehicleFuel.contains('DIZEL') || vehicleFuel.contains('MAZOT')) {
      fType = 'MAZOT';
    } else if (vehicleFuel.contains('LPG')) {
      fType = 'LPG';
    }

    final tx = widget.initialCardTransaction!;
    final est = await FuelPriceService.estimateRefueling(
      merchantName: tx.merchantName,
      amount: tx.amount,
      transactionDate: tx.transactionDate,
      fuelType: fType,
    );

    if (est != null && mounted) {
      setState(() {
        _estimation = est;
        _isAutoCalculating = true;
        _pricePerLiterController.text = est.unitPrice.toStringAsFixed(2);
        _litersController.text = est.liters.toStringAsFixed(2);
        _selectedDate = est.matchedDate;
        _isAutoCalculating = false;
        _isEstimating = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isEstimating = false;
        });
      }
    }
  }

  void _updateSelectedVehicle() {
    if (_selectedVehicleId != null) {
      _selectedVehicle = _vehicles.firstWhere((v) => v.vehicleId == _selectedVehicleId);
    } else {
      _selectedVehicle = null;
    }
  }

  void _setupCalculationListeners() {
    _litersController.addListener(() {
      if (_isAutoCalculating) return;
      _isAutoCalculating = true;

      final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
      final total = double.tryParse(_totalPriceController.text.replaceAll(',', '.'));
      final unitPrice = double.tryParse(_pricePerLiterController.text.replaceAll(',', '.'));

      if (liters != null && liters > 0) {
        if (total != null && total > 0 && unitPrice == null) {
          final calculatedUnit = total / liters;
          _pricePerLiterController.text = calculatedUnit.toStringAsFixed(2);
        } else if (unitPrice != null && unitPrice > 0) {
          final calculatedTotal = liters * unitPrice;
          _totalPriceController.text = calculatedTotal.toStringAsFixed(2);
        }
      }

      _isAutoCalculating = false;
    });

    _pricePerLiterController.addListener(() {
      if (_isAutoCalculating) return;
      _isAutoCalculating = true;

      final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
      final total = double.tryParse(_totalPriceController.text.replaceAll(',', '.'));
      final unitPrice = double.tryParse(_pricePerLiterController.text.replaceAll(',', '.'));

      if (unitPrice != null && unitPrice > 0) {
        if (total != null && total > 0 && liters == null) {
          final calculatedLiters = total / unitPrice;
          _litersController.text = calculatedLiters.toStringAsFixed(2);
        } else if (liters != null && liters > 0) {
          final calculatedTotal = liters * unitPrice;
          _totalPriceController.text = calculatedTotal.toStringAsFixed(2);
        }
      }

      _isAutoCalculating = false;
    });

    _totalPriceController.addListener(() {
      if (_isAutoCalculating) return;
      _isAutoCalculating = true;

      final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
      final total = double.tryParse(_totalPriceController.text.replaceAll(',', '.'));
      final unitPrice = double.tryParse(_pricePerLiterController.text.replaceAll(',', '.'));

      if (total != null && total > 0) {
        if (liters != null && liters > 0) {
          final calculatedUnit = total / liters;
          _pricePerLiterController.text = calculatedUnit.toStringAsFixed(2);
        } else if (unitPrice != null && unitPrice > 0) {
          final calculatedLiters = total / unitPrice;
          _litersController.text = calculatedLiters.toStringAsFixed(2);
        }
      }

      _isAutoCalculating = false;
    });
  }

  Future<void> _pickDate() async {
    final parsed = parseDate(_dateController.text);
    final initialDate = parsed ?? _selectedDate;

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
        _selectedDate = picked;
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showExplanationDialog() {
    _showPremiumInfoPopup(
      title: 'Akıllı Analiz',
      icon: Icons.info_outline,
      color: AppTheme.primaryCyan,
      children: [
        const Text(
          'Bu sistem, yüklenen ekstre veya SMS\'teki harcamayı analiz ederek pompa fiyatlarını ve aldığınız yakıtı otomatik hesaplar:',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildBulletPoint(
          '1. Konum Tespiti',
          'Harcama yapılan akaryakıt istasyonunun adından işlem yapılan şehir (İstanbul, Ankara, İzmir vb.) otomatik olarak saptanır.',
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          '2. Tarihsel Fiyat Eşleşmesi',
          'İşlem tarihindeki (banka provizyon gecikmelerini de hesaba katarak geriye dönük 4 gündeki) resmi günlük pompa fiyat arşivi taranır.',
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          '3. Güven Endeksi (Litre Analizi)',
          'Toplam tutar, o tarihteki birim fiyatına bölünür. Çıkan litre miktarı fiziki olarak yuvarlak bir sayıya (örneğin tam 40 veya 50 litre gibi) ne kadar yakınsa, eşleşmenin doğruluğu o kadar yüksek kabul edilir.',
        ),
      ],
    );
  }

  void _showPremiumInfoPopup({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.lightSurface,
                  Color(0xFFF1F5F9), // Slate 100
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified,
                                  color: AppTheme.primaryCyan,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderLight, height: 1, thickness: 1),
                  const SizedBox(height: 20),
                  ...children,
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ANLADIM'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryCyan,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _saveRefueling() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir araç seçin.')),
      );
      return;
    }

    final db = DbService().database;
    final liters = double.parse(_litersController.text.replaceAll(',', '.'));
    final unitPrice = double.parse(_pricePerLiterController.text.replaceAll(',', '.'));
    final totalPrice = double.parse(_totalPriceController.text.replaceAll(',', '.'));
    final int odometer;
    if (_dontRememberOdometer) {
      odometer = 0;
    } else {
      final cleanOdoStr = _odometerController.text.replaceAll('.', '').replaceAll(' KM', '').trim();
      odometer = int.parse(cleanOdoStr);
    }

    final parsedDate = parseDate(_dateController.text);
    if (parsedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir tarih girin.')),
      );
      return;
    }

    final refuelingId = widget.editRefueling != null ? widget.editRefueling!.refuelingId : const Uuid().v4();

    try {
      if (widget.editRefueling != null) {
        final updatedRefueling = Refueling(
          refuelingId: refuelingId,
          vehicleId: _selectedVehicleId!,
          liters: liters,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
          odometer: odometer,
          purchaseDate: parsedDate,
          isFullTank: _isFullTank,
          imagePath: widget.editRefueling!.imagePath,
          stationId: widget.editRefueling!.stationId,
        );
        await db.updateRefueling(updatedRefueling);
      } else {
        final refuelingCompanion = RefuelingsCompanion(
          refuelingId: drift.Value(refuelingId),
          vehicleId: drift.Value(_selectedVehicleId!),
          liters: drift.Value(liters),
          unitPrice: drift.Value(unitPrice),
          totalPrice: drift.Value(totalPrice),
          odometer: drift.Value(odometer),
          purchaseDate: drift.Value(parsedDate),
          isFullTank: drift.Value(_isFullTank),
        );
        await db.insertRefueling(refuelingCompanion);
      }

      // Aracın güncel kilometresini güncelle
      final currentVehicle = await db.getVehicleById(_selectedVehicleId!);
      if (currentVehicle != null && odometer > currentVehicle.currentOdometer) {
        await db.updateVehicle(currentVehicle.copyWith(currentOdometer: odometer));
      }

      if (widget.initialCardTransaction != null) {
        final updatedTx = widget.initialCardTransaction!.copyWith(
          refuelingId: drift.Value(refuelingId),
        );
        await db.updateCardTransaction(updatedTx);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editRefueling != null 
                ? 'Yakıt alım kaydı başarıyla güncellendi.'
                : 'Yakıt dolum kaydı başarıyla eklendi.'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editRefueling != null ? 'Yakıt Alımı Düzenle' : 'Yakıt Alımı Ekle'),
      ),
      body: _vehicles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'Önce bir araç tanımlamalısınız.',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('GERİ DÖN'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tüketim Detayları',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // YAPAY ZEKALI FİŞ TARAMA BUTONU (PREMIUM CARD JESTİ)
                    if (widget.editRefueling == null) ...[
                      InkWell(
                        onTap: () async {
                          if (_selectedVehicleId == null || _selectedVehicle == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen önce bir araç seçin.'),
                                backgroundColor: AppTheme.errorRed,
                              ),
                            );
                            return;
                          }
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptScannerScreen(
                                vehicleId: _selectedVehicleId!,
                                vehicle: _selectedVehicle!,
                              ),
                            ),
                          );
                          if (result == true) {
                            if (!context.mounted) return;
                            // Eğer doğrudan kaydedildiyse, bu ekranı da kapatıp ana ekrana dön
                            Navigator.pop(context, true);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCyan.withValues(alpha: 0.05),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryCyan, size: 26),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'AKILLI FİŞ TARAMA',
                                      style: TextStyle(
                                        color: AppTheme.primaryCyan,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Kamera ile fişinizi çekerek bilgileri anında otomatik doldurun.',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryCyan, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ARAÇ SEÇİMİ
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleId,
                      decoration: const InputDecoration(
                        labelText: 'İşlem Yapılacak Araç',
                        prefixIcon: Icon(Icons.directions_car, color: AppTheme.primaryCyan),
                      ),
                      dropdownColor: AppTheme.lightSurface,
                      items: _vehicles.map((v) {
                        return DropdownMenuItem(
                          value: v.vehicleId,
                          child: Text('${v.brand} ${v.model} (${v.plate})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleId = value;
                          _updateSelectedVehicle();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_isEstimating)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tarihsel akaryakıt verileri analiz ediliyor...',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_estimation != null)
                      Builder(
                        builder: (context) {
                          final confidencePct = (_estimation!.confidenceScore * 100).toInt();
                          
                          // Renk ve ikon belirleme mantığı
                          final Color backgroundColor;
                          final Color borderColor;
                          final Color textColor;
                          final Color iconColor;
                          final IconData statusIcon;
                          
                          if (confidencePct >= 80) {
                            backgroundColor = const Color(0xFFECFDF5); // Açık Yeşil (Emerald 50)
                            borderColor = const Color(0xFF10B981); // Zümrüt Yeşil (Emerald 500)
                            textColor = const Color(0xFF064E3B); // Koyu Yeşil Metin (Emerald 900)
                            iconColor = const Color(0xFF059669); // Orta Yeşil İkon (Emerald 600)
                            statusIcon = Icons.verified_user_rounded;
                          } else if (confidencePct < 40) {
                            backgroundColor = const Color(0xFFFEF2F2); // Açık Kırmızı (Red 50)
                            borderColor = const Color(0xFFEF4444); // Kırmızı Sınır (Red 500)
                            textColor = const Color(0xFF7F1D1D); // Koyu Kırmızı Metin (Red 900)
                            iconColor = const Color(0xFFDC2626); // Orta Kırmızı İkon (Red 600)
                            statusIcon = Icons.warning_amber_rounded;
                          } else {
                            backgroundColor = const Color(0xFFFFFBEB); // Açık Turuncu/Sarı (Amber 50)
                            borderColor = const Color(0xFFF59E0B); // Turuncu Sınır (Amber 500)
                            textColor = const Color(0xFF78350F); // Koyu Kahve/Turuncu Metin (Amber 900)
                            iconColor = const Color(0xFFD97706); // Orta Turuncu İkon (Amber 600)
                            statusIcon = Icons.info_outline;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: _showExplanationDialog,
                              onLongPress: _showExplanationDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: borderColor.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      color: iconColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Akaryakıt fiyatı ve miktarı tahmini olarak hesaplandı (Güven Endeksi: %$confidencePct)',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.help_outline_rounded,
                                      color: iconColor.withValues(alpha: 0.8),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),

                    // LİTRE
                    TextFormField(
                      controller: _litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Litre Miktarı',
                        hintText: 'Örn: 42.5',
                        prefixIcon: Icon(Icons.local_gas_station, color: AppTheme.primaryCyan),
                        suffixText: 'LT',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen litre girin.';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) {
                          return 'Lütfen sıfırdan büyük bir sayı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // LİTRE BİRİM FİYATI
                    TextFormField(
                      controller: _pricePerLiterController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Litre Birim Fiyatı',
                        hintText: 'Örn: 44.20',
                        prefixIcon: Icon(Icons.currency_lira, color: AppTheme.primaryCyan),
                        suffixText: 'TL',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen birim fiyatı girin.';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) {
                          return 'Lütfen sıfırdan büyük bir sayı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // TOPLAM TUTAR (Otomatik Hesaplanır)
                    TextFormField(
                      controller: _totalPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Toplam Tutar',
                        prefixIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primaryCyan),
                        suffixText: 'TL',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen toplam tutarı girin.';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) {
                          return 'Lütfen geçerli bir tutar girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // GÜNCEL KİLOMETRE (Validasyonlu)
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
                        labelText: 'Yakıt Alım Kilometresi',
                        hintText: _dontRememberOdometer
                            ? 'Hatırlanmıyor'
                            : (_selectedVehicle != null
                                ? 'En Son: ${_selectedVehicle!.currentOdometer} KM'
                                : 'Örn: 125340'),
                        prefixIcon: const Icon(Icons.speed, color: AppTheme.primaryCyan),
                      ),
                      validator: (value) {
                        if (_dontRememberOdometer) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen sayaç kilometresini girin.';
                        }
                        final cleanValue = value.replaceAll('.', '').replaceAll(' KM', '').trim();
                        final odo = int.tryParse(cleanValue);
                        if (odo == null || odo < 0) {
                          return 'Lütfen geçerli bir kilometre değeri girin.';
                        }
                        // Düzenleme modunda, mevcut kaydın kendi kilometresine eşit olması geçerlidir.
                        if (widget.editRefueling != null && odo == widget.editRefueling!.odometer) {
                          return null;
                        }
                        if (_selectedVehicle != null && odo <= _selectedVehicle!.currentOdometer) {
                          return 'Kilometre sayacı son değerden (${_selectedVehicle!.currentOdometer} KM) büyük olmalıdır!';
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
                        labelText: 'Yakıt Alım Tarihi',
                        hintText: 'GG/AA/YYYY',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryCyan),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_calendar, color: AppTheme.primaryCyan),
                          onPressed: _pickDate,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen yakıt alım tarihini girin.';
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
                    const SizedBox(height: 16),

                    // DEPO TAM DOLU SWITCH
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.battery_full, color: AppTheme.primaryCyan),
                              SizedBox(width: 16),
                              Text(
                                'Depo Tamamen Dolduruldu',
                                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isFullTank,
                            activeThumbColor: AppTheme.primaryCyan,
                            onChanged: (val) {
                              setState(() {
                                _isFullTank = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // KAYDET BUTONU
                    ElevatedButton(
                      onPressed: _saveRefueling,
                      child: const Text('KAYDI KAYDET'),
                    ),
                  ],
                ),
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

    final selectionStart = newValue.selection.start;
    int digitsBeforeCursor = 0;
    if (selectionStart >= 0 && selectionStart <= newValue.text.length) {
      final textBeforeCursor = newValue.text.substring(0, selectionStart);
      digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^0-9]'), '').length;
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanText.isEmpty) {
      return const TextEditingValue();
    }

    final int? val = int.tryParse(cleanText);
    if (val == null) return oldValue;

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
