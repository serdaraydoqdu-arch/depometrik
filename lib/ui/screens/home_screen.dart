import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../core/calculator/consumption_calculator.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';
import '../../core/sms/sms_parser_service.dart';
import '../../core/parser/pdf_statement_parser.dart';
import 'add_refueling_screen.dart';
import 'add_vehicle_screen.dart';
import 'pdf_upload_screen.dart';
import 'receipt_scanner_screen.dart';
import 'auth_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/sync/powersync_service.dart';
import '../../core/utils/aes_helper.dart';
import '../../core/utils/location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'campaigns_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String get _currentUserId {
    return Supabase.instance.client.auth.currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
  }

  String get _currentUserEmail {
    return Supabase.instance.client.auth.currentSession?.user.email ?? 'serdar@depometrik.com';
  }

  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  Vehicle? _selectedVehicle;

  List<Refueling> _refuelings = [];
  double? _lastFullToFull;
  double? _rollingAverage;
  List<CardTransaction> _unapprovedTransactions = [];
  


  // Clipboard ve SMS Takip Motoru Durumları
  final SmsParserService _smsParser = SmsParserService();
  SmsTransaction? _detectedSmsTx;
  String? _lastClipboardContent;
  bool _isClipboardExpanded = false;

  StreamSubscription? _vehiclesSubscription;
  StreamSubscription? _refuelingsSubscription;
  StreamSubscription? _transactionsSubscription;
  StreamSubscription? _fuelPricesSubscription;
  Profile? _userProfile;

  double? _dailyBenzinPrice;
  double? _dailyMazotPrice;
  double? _dailyLpgPrice;

  @override
  void initState() {
    super.initState();
    _ensureProfileExists();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
    
    // Veritabanı değişikliklerini (PowerSync & Yerel) canlı dinle ve arayüzü güncelle
    final db = DbService().database;
    _vehiclesSubscription = db.select(db.vehicles).watch().listen((_) => _refreshData());
    _refuelingsSubscription = db.select(db.refuelings).watch().listen((_) => _refreshData());
    _transactionsSubscription = db.select(db.cardTransactions).watch().listen((_) => _refreshData());
    _fuelPricesSubscription = db.select(db.fuelPrices).watch().listen((_) => _refreshData());

    // İlk açılışta da panoyu kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForRefuelingSms();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vehiclesSubscription?.cancel();
    _refuelingsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _fuelPricesSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForRefuelingSms();
    }
  }

  Future<void> _checkClipboardForRefuelingSms() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text;
      if (text == null || text.trim().isEmpty || text == _lastClipboardContent) return;

      // SMS Parser motorunu çalıştır
      final smsTx = _smsParser.parseSms(text);
      if (smsTx != null) {
        setState(() {
          _lastClipboardContent = text; // Bir kere algılandıktan sonra tekrar uyarmasın
          _detectedSmsTx = smsTx;
          _isClipboardExpanded = false; // Yeni algılamada kapalı başla
        });
      }
    } catch (_) {
      // Pano okuma hatalarını yoksay
    }
  }

  Future<void> _saveClipboardTransaction() async {
    if (_detectedSmsTx == null) return;
    
    final db = DbService().database;
    final userId = _currentUserId;

    final companion = CardTransactionsCompanion(
      transactionId: drift.Value(const Uuid().v4()),
      userId: drift.Value(userId),
      transactionDate: drift.Value(_detectedSmsTx!.date),
      amount: drift.Value(_detectedSmsTx!.amount),
      merchantName: drift.Value(_detectedSmsTx!.merchantName),
      source: drift.Value('SMS'),
    );

    try {
      await db.insertCardTransaction(companion);
      setState(() {
        _detectedSmsTx = null;
        _isClipboardExpanded = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pano harcaması başarıyla finansal kayıtlara eklendi!'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
        _refreshData();
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

  Future<void> _refreshData() async {
    final db = DbService().database;
    final userId = _currentUserId;
    print('HomeScreen: _refreshData called. userId = $userId');

    // Profil bilgilerini getir
    var profile = await db.getProfileById(userId);
    if (profile == null) {
      try {
        final supabaseProfile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
            
        if (supabaseProfile != null) {
          final fullName = supabaseProfile['full_name'] as String?;
          final phoneNumber = supabaseProfile['phone_number'] as String?;
          final rawTckn = supabaseProfile['tckn'] as String?;
          final email = supabaseProfile['email'] as String? ?? _currentUserEmail;
          final premium = supabaseProfile['premium_status'] as bool? ?? false;
          
          await db.insertProfile(
            ProfilesCompanion(
              userId: drift.Value(userId),
              email: drift.Value(email),
              fullName: drift.Value(fullName),
              phoneNumber: drift.Value(phoneNumber),
              tckn: drift.Value(rawTckn),
              premiumStatus: drift.Value(premium),
            ),
          );
          profile = await db.getProfileById(userId);
        }
      } catch (_) {}
    }

    // Güncel şehir fiyatlarını yükle
    double? benzin;
    double? mazot;
    double? lpg;
    try {
      final today = DateTime.now();
      final currentCity = CityPreference.currentCity;
      benzin = await db.getFuelPrice(currentCity, 'BENZIN', today);
      mazot = await db.getFuelPrice(currentCity, 'MAZOT', today);
      lpg = await db.getFuelPrice(currentCity, 'LPG', today);
    } catch (e) {
      print('HomeScreen: Fiyat yukleme hatasi: $e');
    }

    // Araçları getir
    final vehiclesList = await db.getVehiclesForUser(userId);
    print('HomeScreen: Loaded ${vehiclesList.length} vehicles from DB');
    
    // Onay bekleyen işlemleri getir
    final unapprovedList = await db.getUnapprovedCardTransactions(userId);
    
    setState(() {
      _userProfile = profile;
      _vehicles = vehiclesList;
      _unapprovedTransactions = unapprovedList;
      _dailyBenzinPrice = benzin;
      _dailyMazotPrice = mazot;
      _dailyLpgPrice = lpg;
      if (vehiclesList.isNotEmpty) {
        if (_selectedVehicleId == null || !vehiclesList.any((v) => v.vehicleId == _selectedVehicleId)) {
          _selectedVehicleId = vehiclesList.first.vehicleId;
        }
      } else {
        _selectedVehicleId = null;
      }
      _updateSelectedVehicle();
    });

    if (_selectedVehicleId != null) {
      // Yakıt kayıtlarını getir (en yeni üstte olacak şekilde)
      final refList = await db.getRefuelingsForVehicle(_selectedVehicleId!);
      // Tüketim hesaplamaları için artan sırada kayıtları da al
      final refListAsc = await db.getRefuelingsForVehicleAsc(_selectedVehicleId!);

      setState(() {
        _refuelings = refList;
        _calculateConsumption(refListAsc);
      });
    } else {
      setState(() {
        _refuelings = [];
        _lastFullToFull = null;
        _rollingAverage = null;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      await PowerSyncService().disconnect();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Hata durumunda yoksay (örn. daha önce Google ile giriş yapılmamışsa)
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _updateSelectedVehicle() {
    if (_selectedVehicleId != null && _vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.firstWhere((v) => v.vehicleId == _selectedVehicleId);
    } else {
      _selectedVehicle = null;
    }
  }

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

  void _calculateConsumption(List<Refueling> refListAsc) {
    // Kilometresi sıfır olan (hatırlanmıyor olarak işaretlenmiş) kayıtları hesaplamalardan hariç tutuyoruz
    final validRefListAsc = refListAsc.where((r) => r.odometer > 0).toList();

    if (validRefListAsc.length < 2) {
      _lastFullToFull = null;
      _rollingAverage = null;
      return;
    }

    // 1. Depodan Depoya (Full-to-Full) Gelişmiş Hesaplama
    // En son tam dolum kaydını buluyoruz (index i)
    _lastFullToFull = null;
    int? latestFullIndex;
    for (int i = validRefListAsc.length - 1; i >= 0; i--) {
      if (validRefListAsc[i].isFullTank) {
        latestFullIndex = i;
        break;
      }
    }

    if (latestFullIndex != null && latestFullIndex >= 1) {
      // Geriye doğru giderek bir önceki tam dolum kaydını arıyoruz (index j)
      int? previousFullIndex;
      for (int j = latestFullIndex - 1; j >= 0; j--) {
        if (validRefListAsc[j].isFullTank) {
          previousFullIndex = j;
          break;
        }
      }

      if (previousFullIndex != null) {
        // İki tam dolum arasındaki toplam mesafeyi hesaplıyoruz
        final distance = validRefListAsc[latestFullIndex].odometer - validRefListAsc[previousFullIndex].odometer;
        
        if (distance > 0) {
          // İki tam dolum arasındaki (aradaki kısmi alımlar dahil) eklenen tüm litreleri topluyoruz
          double totalLiters = 0.0;
          for (int k = previousFullIndex + 1; k <= latestFullIndex; k++) {
            totalLiters += validRefListAsc[k].liters;
          }
          
          _lastFullToFull = (totalLiters * 100.0) / distance;
        }
      }
    }

    // 2. Kayan Ağırlıklı Ortalama (Rolling Average) Hesaplama
    try {
      final calculatorInput = validRefListAsc.map((r) {
        return OdometerAndLiters(
          odometer: r.odometer,
          liters: r.liters,
          date: r.purchaseDate,
        );
      }).toList();

      _rollingAverage = ConsumptionCalculator.calculateRollingAverage(calculatorInput);
    } catch (_) {
      _rollingAverage = null;
    }
  }

  Widget _buildClipboardBanner() {
    if (_detectedSmsTx == null) return const SizedBox.shrink();
    
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isClipboardExpanded = !_isClipboardExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isClipboardExpanded ? AppTheme.primaryCyan : AppTheme.borderLight,
              width: _isClipboardExpanded ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.content_paste_go, color: AppTheme.primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pano Üzerinde Fiş/SMS Harcaması Algılandı!',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                    onPressed: () {
                      setState(() {
                        _detectedSmsTx = null;
                        _isClipboardExpanded = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _detectedSmsTx!.merchantName,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isClipboardExpanded 
                              ? 'Tarih: ${_detectedSmsTx!.date.day}/${_detectedSmsTx!.date.month}/${_detectedSmsTx!.date.year} • Kapatmak için dokunun'
                              : 'Tarih: ${_detectedSmsTx!.date.day}/${_detectedSmsTx!.date.month}/${_detectedSmsTx!.date.year} • Dokun ve Mesajı Gör',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_detectedSmsTx!.amount.toStringAsFixed(2)} TL',
                    style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              if (_isClipboardExpanded && _detectedSmsTx!.rawBody != null) ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.borderLight, height: 1),
                const SizedBox(height: 8),
                const Text(
                  'Kopyalanan Pano Metni:',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    _detectedSmsTx!.rawBody!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _detectedSmsTx = null;
                        _isClipboardExpanded = false;
                      });
                    },
                    child: const Text('YOK ET', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveClipboardTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('HARCAMAYI KAYDET'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutomationSection() {
    return GestureDetector(
      onLongPress: _showOtomasyonPopup,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, color: AppTheme.primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'FİNANSAL VERİ OTOMASYONU',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PdfUploadScreen()),
                        );
                        _refreshData();
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('EKSTRE YÜKLE', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _scanDeviceSmsInbox,
                      icon: const Icon(Icons.sms_outlined, size: 18),
                      label: const Text('MESAJLARI TARA', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryCyan,
                        side: const BorderSide(color: AppTheme.primaryCyan),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: GestureDetector(
          onTap: _refreshData,
          child: const Text(
            'DEPOMETRİK',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet_giftcard_rounded, color: AppTheme.primaryCyan),
            tooltip: 'Kampanyalar',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CampaignsScreen()),
              );
              _refreshData();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _showProfileBottomSheet,
              icon: const Icon(Icons.account_circle, color: AppTheme.primaryCyan, size: 22),
              label: Text(
                _userProfile?.fullName ?? 'Profil',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _vehicles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppTheme.primaryCyan,
                  backgroundColor: AppTheme.lightSurface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFuelPriceTicker(),
                        _buildVehicleSelectorCard(),
                        const SizedBox(height: 20),
                        _buildConsumptionDashboard(),
                        const SizedBox(height: 20),
                        _buildAutomationSection(),
                        _buildPendingTransactionsSection(),
                        const SizedBox(height: 24),
                        _buildRefuelingHistoryHeader(),
                        const SizedBox(height: 12),
                        _buildRefuelingHistoryList(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildClipboardBanner(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_vehicles.isEmpty) {
            final added = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
            );
            if (added == true) _refreshData();
          } else {
            _showAddRefuelingMenu();
          }
        },
        icon: Icon(_vehicles.isEmpty ? Icons.add_road : Icons.local_gas_station),
        label: Text(_vehicles.isEmpty ? 'ARAÇ EKLE' : 'YAKIT ALIMI EKLE'),
      ),
    );
  }

  Future<void> _createTestVehicle() async {
    final db = DbService().database;
    final userId = _currentUserId;
    final userEmail = _currentUserEmail;
    
    try {
      // 1. Önce kullanıcıyı ekle (varsa insert etmez veya güncellemez)
      final profile = await db.getProfileById(userId);
      if (profile == null) {
        await db.insertProfile(
          ProfilesCompanion(
            userId: drift.Value(userId),
            email: drift.Value(userEmail),
            premiumStatus: const drift.Value(true),
            createdAt: drift.Value(DateTime.now()),
            acceptedAllStatementTerms: const drift.Value(false),
            openBankingConnected: const drift.Value(false),
          ),
        );
      }
      
      // 2. Mock aracı ekle
      final mockVehicleId = const Uuid().v4();
      final vehicleCompanion = VehiclesCompanion(
        vehicleId: drift.Value(mockVehicleId),
        userId: drift.Value(userId),
        plate: const drift.Value('06EPH337'),
        brand: const drift.Value('VOGE'),
        model: const drift.Value('SR3'),
        fuelType: const drift.Value('BENZIN'),
        initialOdometer: const drift.Value(5000),
        currentOdometer: const drift.Value(5000),
      );
      
      await db.insertVehicle(vehicleCompanion);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test aracı başarıyla oluşturuldu ve kaydedildi!'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
      }
      
      // Verileri yenile
      _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test aracı oluşturulurken hata: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildFuelPriceTicker() {
    final city = CityPreference.currentCity;
    return GestureDetector(
      onTap: _showFuelPriceSettingsDialog,
      onLongPress: _showFuelPriceInfoDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.primaryCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$city GÜNLÜK YAKIT FİYATLARI',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.local_gas_station_outlined, color: AppTheme.textSecondary, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceItem('Benzin (95)', _dailyBenzinPrice, const Color(0xFF10B981)),
                _buildPriceDivider(),
                _buildPriceItem('Motorin', _dailyMazotPrice, AppTheme.accentOrange),
                _buildPriceDivider(),
                _buildPriceItem('LPG / Otogaz', _dailyLpgPrice, const Color(0xFF0284C7)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, double? price, Color color) {
    final priceStr = price != null && price > 0 ? '${price.toStringAsFixed(2)} TL' : '--.-- TL';
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            priceStr,
            style: TextStyle(
              color: color,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppTheme.borderLight,
    );
  }

  void _showFuelPriceSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Konum / Şehir Seçimi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location, color: AppTheme.primaryCyan),
                title: const Text('Mevcut Konumu Kullan'),
                subtitle: const Text('GPS üzerinden bulunduğunuz ili otomatik algılar.'),
                onTap: () {
                  Navigator.of(context).pop();
                  _detectAndSyncLocation();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.map_outlined, color: Colors.orange),
                title: const Text('Şehir Seç'),
                subtitle: const Text('Listeden manuel olarak bir şehir seçin.'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCitySelectionDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _detectAndSyncLocation() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konumunuz algılanıyor...'),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      final city = await LocationService.detectCurrentCity();
      if (city != null) {
        await CityPreference.setCity(city);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Konum algılandı: $city. Fiyatlar güncelleniyor...'),
              backgroundColor: AppTheme.primaryCyan,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum algılanamadı veya izin verilmedi.'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum tespiti sırasında hata oluştu: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showCitySelectionDialog() {
    final List<String> provinces = [
      'İSTANBUL', 'ANKARA', 'İZMİR', // En başta sırayla
      'ADANA', 'ADIYAMAN', 'AFYONKARAHİSAR', 'AĞRI', 'AKSARAY', 'AMASYA', 'ANTALYA', 
      'ARDAHAN', 'ARTVİN', 'AYDIN', 'BALIKESİR', 'BARTIN', 'BATMAN', 'BAYBURT', 
      'BİLECİK', 'BİNGÖL', 'BİTLİS', 'BOLU', 'BURDUR', 'BURSA', 'ÇANAKKALE', 
      'ÇANKIRI', 'ÇORUM', 'DENİZLİ', 'DİYARBAKIR', 'DÜZCE', 'EDİRNE', 'ELAZIĞ', 
      'ERZİNCAN', 'ERZURUM', 'ESKİŞEHİR', 'GAZİANTEP', 'GİRESUN', 'GÜMÜŞHANE', 
      'HAKKARİ', 'HATAY', 'IĞDIR', 'ISPARTA', 'KAHRAMANMARAŞ', 'KARABÜK', 
      'KARAMAN', 'KARS', 'KASTAMONU', 'KAYSERİ', 'KİLİS', 'KIRIKKALE', 'KIRKLARELİ', 
      'KIRŞEHİR', 'KOCAELİ', 'KONYA', 'KÜTAHYA', 'MALATYA', 'MANİSA', 'MARDİN', 
      'MERSİN', 'MUĞLA', 'MUŞ', 'NEVŞEHİR', 'NİĞDE', 'ORDU', 'OSMANİYE', 'RİZE', 
      'SAKARYA', 'SAMSUN', 'ŞANLIURFA', 'SİİRT', 'SİNOP', 'ŞIRNAK', 'SİVAS', 
      'TEKİRDAĞ', 'TOKAT', 'TRABZON', 'TUNCELİ', 'UŞAK', 'VAN', 'YALOVA', 'YOZGAT', 
      'ZONGULDAK'
    ];

    String normalizeForSearch(String text) {
      return text.toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c')
          .replaceAll('İ', 'i')
          .replaceAll('i', 'i');
    }

    String searchQuery = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final normalizedQuery = normalizeForSearch(searchQuery);
            final filteredProvinces = provinces.where((p) {
              if (searchQuery.isEmpty) return true;
              return normalizeForSearch(p).contains(normalizedQuery);
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Şehir Seçiniz',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Şehir ara...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryCyan, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        setStateBuilder(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProvinces.length,
                        itemBuilder: (context, index) {
                          final city = filteredProvinces[index];
                          final normalizedCityForCheck = LocationService.normalizeCityName(city);
                          final isCurrent = CityPreference.currentCity == normalizedCityForCheck;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            title: Text(
                              city,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                                color: isCurrent ? AppTheme.primaryCyan : AppTheme.textPrimary,
                              ),
                            ),
                            trailing: isCurrent
                                ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryCyan, size: 20)
                                : null,
                            onTap: () async {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$city seçildi. Fiyatlar güncelleniyor...'),
                                  backgroundColor: AppTheme.primaryCyan,
                                ),
                              );
                              await CityPreference.setCity(city);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFuelPriceInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryCyan),
              SizedBox(width: 8),
              Text(
                'Yakıt Fiyatları Hakkında',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: const Text(
            'Bu bölüm, seçtiğiniz şehirdeki günlük en güncel benzin, motorin (dizel) ve otogaz (LPG) fiyatlarını gösterir.\n\n'
            'Uygulamaya akaryakıt harcaması eklediğinizde (örneğin "1000 TL\'lik yakıt aldım" yazdığınızda), girdiğiniz bu tutarın kaç litre yakıta denk geldiğini tam olarak hesaplamak için bu fiyatlar kullanılır.\n\n'
            'Böylece aracınızın yakıt tüketim performansını ve kilometre başına kaç kuruş yaktığını kuruşu kuruşuna doğru takip edebilirsiniz.',
            style: TextStyle(height: 1.5, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryCyan,
              ),
              child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          // Test Aracı Banner/Butonu (En üstte)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.05),
              border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_circle_outlined, color: AppTheme.primaryCyan),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Modu / Hızlı Başlangıç',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Uygulamayı test etmek için hızlıca örnek araç oluşturun.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _createTestVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Test Aracı Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.lightSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderLight, width: 1.5),
                      ),
                      child: const Icon(Icons.airport_shuttle, size: 72, color: AppTheme.primaryCyan),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'DepoMetrik\'e Hoş Geldiniz!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tüketim analizlerinizi, akaryakıt verimliliğinizi ve araç istatistiklerinizi izlemek için hemen ilk aracınızı tanımlayın.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        final added = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
                        );
                        if (added == true) _refreshData();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('İLK ARACIMI EKLE'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.lightBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Araçlarım',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_vehicles.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: const Center(
                        child: Text(
                          'Kayıtlı araç bulunamadı.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _vehicles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final vehicle = _vehicles[index];
                          final isActive = vehicle.vehicleId == _selectedVehicleId;
                          
                          IconData fuelIcon = Icons.local_gas_station;
                          if (vehicle.fuelType == 'ELEKTRIK') {
                            fuelIcon = Icons.electric_car;
                          } else if (vehicle.fuelType == 'LPG') {
                            fuelIcon = Icons.gas_meter_outlined;
                          }
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive ? AppTheme.primaryCyan : AppTheme.borderLight,
                                width: isActive ? 2.0 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.textPrimary.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedVehicleId = vehicle.vehicleId;
                                  _updateSelectedVehicle();
                                });
                                _refreshData();
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (isActive ? AppTheme.primaryCyan : AppTheme.textSecondary)
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.directions_car_filled_outlined,
                                        color: isActive ? AppTheme.primaryCyan : AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${vehicle.brand} ${vehicle.model}',
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (isActive)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Aktif',
                                                    style: TextStyle(
                                                      color: Color(0xFF10B981),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color(0xFFCBD5E1),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6.5),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 24,
                                                    color: const Color(0xFF003399),
                                                    child: const Center(
                                                      child: Text(
                                                        'TR',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 7.5,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 0.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    child: Text(
                                                      vehicle.plate,
                                                      style: const TextStyle(
                                                        color: AppTheme.textPrimary,
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 12,
                                                        letterSpacing: 1.0,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              fuelIcon,
                                              color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_formatOdometer(vehicle.currentOdometer)} KM',
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppTheme.errorRed,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () async {
                                            bool confirm = false;
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: AppTheme.lightSurface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  title: Text(
                                                    '${vehicle.brand} ${vehicle.model} Silinsin mi?',
                                                    style: const TextStyle(
                                                      color: AppTheme.textPrimary,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    'Bu aracı silmek istediğinize emin misiniz? Araca ait plaka bilgisi ve tüm akaryakıt alım geçmişi kalıcı olarak silinecektir.',
                                                    style: TextStyle(color: AppTheme.textSecondary),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text(
                                                        'VAZGEÇ',
                                                        style: TextStyle(color: AppTheme.textSecondary),
                                                      ),
                                                      onPressed: () {
                                                        confirm = false;
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppTheme.errorRed,
                                                        foregroundColor: AppTheme.lightSurface,
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      child: const Text('SİL'),
                                                      onPressed: () {
                                                        confirm = true;
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            
                                            if (confirm) {
                                              final vehicleIdToDelete = vehicle.vehicleId;
                                              final db = DbService().database;
                                              await db.deleteVehicle(vehicleIdToDelete);
                                              await _refreshData();
                                              setModalState(() {});
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
                      );
                      if (added == true) {
                        _refreshData();
                      }
                    },
                    icon: const Icon(Icons.add_road),
                    label: const Text('YENİ ARAÇ EKLE'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleSelectorCard() {
    final vehicleSelectorCard = Container(
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Bölüm: İkon ve Seçici Dropdown
            Row(
              children: [
                // Araç İkonu Yuvası
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryCyan.withValues(alpha: 0.12),
                        AppTheme.primaryCyan.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    color: AppTheme.primaryCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Marka & Model Seçici dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AKTİF ARAÇ',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showVehicleListBottomSheet(context),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.garage_outlined,
                                  size: 14,
                                  color: AppTheme.primaryCyan,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Araçlarım',
                                  style: TextStyle(
                                    color: AppTheme.primaryCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Theme(
                        data: Theme.of(context).copyWith(
                          buttonTheme: const ButtonThemeData(
                            alignedDropdown: false,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVehicleId,
                            isExpanded: true,
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.unfold_more_rounded,
                              color: AppTheme.primaryCyan,
                              size: 20,
                            ),
                            dropdownColor: AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                            items: [
                              ..._vehicles.map((v) {
                                return DropdownMenuItem<String>(
                                  value: v.vehicleId,
                                  child: Text('${v.brand} ${v.model}'),
                                );
                              }),
                              const DropdownMenuItem<String>(
                                value: 'ADD_NEW',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: AppTheme.primaryCyan,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Yeni Araç Ekle',
                                      style: TextStyle(
                                        color: AppTheme.primaryCyan,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == 'ADD_NEW') {
                                final added = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
                                );
                                if (added == true) {
                                  _refreshData();
                                }
                              } else {
                                setState(() {
                                  _selectedVehicleId = value;
                                  _updateSelectedVehicle();
                                });
                                _refreshData();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedVehicle != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderLight, height: 1, thickness: 1),
              const SizedBox(height: 10),
              // Alt Bölüm: Plaka Kapsülü ve Toplam Kilometre Bilgisi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TR Plaka Tasarımlı Premium Plaka Kapsülü
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate 100
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1), // Slate 300
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TR Mavi Bölge Şeridi
                          Container(
                            width: 14,
                            height: 24,
                            color: const Color(0xFF003399), // EU Plaka Mavisi
                            child: const Center(
                              child: Text(
                                'TR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          // Plaka Metni
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            child: Text(
                              _selectedVehicle!.plate,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.0,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Kilometre Bilgisi (Sıradışı Şık Görünüm)
                  Row(
                    children: [
                      const Icon(
                        Icons.speed_outlined,
                        color: AppTheme.primaryCyan,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatOdometer(_selectedVehicle!.currentOdometer)} KM',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (_selectedVehicle == null) {
      return vehicleSelectorCard;
    }

    return Dismissible(
      key: Key(_selectedVehicle!.vehicleId),
      direction: DismissDirection.endToStart, // Sadece sola kaydırınca silme tetiklenir
      confirmDismiss: (direction) async {
        bool confirm = false;
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                '${_selectedVehicle!.brand} ${_selectedVehicle!.model} Silinsin mi?',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Bu aracı silmek istediğinize emin misiniz? Araca ait plaka bilgisi ve tüm akaryakıt alım geçmişi kalıcı olarak silinecektir.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  child: const Text('VAZGEÇ', style: TextStyle(color: AppTheme.textSecondary)),
                  onPressed: () {
                    confirm = false;
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: AppTheme.lightSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('SİL'),
                  onPressed: () {
                    confirm = true;
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        return confirm;
      },
      onDismissed: (direction) async {
        final vehicleIdToDelete = _selectedVehicle!.vehicleId;
        
        setState(() {
          // Listeden aracı hemen çıkarıyoruz ki bir sonraki karede (frame) Dismissible ağaçtan kalksın
          _vehicles.removeWhere((v) => v.vehicleId == vehicleIdToDelete);
          if (_vehicles.isNotEmpty) {
            _selectedVehicleId = _vehicles.first.vehicleId;
            _selectedVehicle = _vehicles.first;
          } else {
            _selectedVehicleId = null;
            _selectedVehicle = null;
          }
        });

        final db = DbService().database;
        await db.deleteVehicle(vehicleIdToDelete);
        _refreshData();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: vehicleSelectorCard,
    );
  }


  Widget _buildConsumptionDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Akaryakıt Performans Göstergeleri',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Depodan Depoya
            Expanded(
              child: GestureDetector(
                onLongPress: _showDepodanDepoyaPopup,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Depodan Depoya', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          Icon(Icons.local_gas_station, color: AppTheme.primaryCyan, size: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _lastFullToFull != null
                            ? '${_lastFullToFull!.toStringAsFixed(1)} L'
                            : '-- L',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.primaryCyan),
                      ),
                      const Text('/100 km', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 8),
                      const Text('Son iki ardışık dolu depo farkı.', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Kayan Ağırlıklı Ortalama
            Expanded(
              child: GestureDetector(
                onLongPress: _showKayanOrtalamaPopup,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Kayan Ortalama', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          Icon(Icons.trending_up, color: AppTheme.accentOrange, size: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _rollingAverage != null
                            ? '${_rollingAverage!.toStringAsFixed(1)} L'
                            : '-- L',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.accentOrange),
                      ),
                      const Text('/100 km', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 8),
                      const Text('Kısmi dolumlar dahil periyodik veri.', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefuelingHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Yakıt Alım Geçmişi',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        if (_selectedVehicle != null)
          Text(
            'Toplam Kilometre: ${_selectedVehicle!.currentOdometer} KM',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildRefuelingHistoryList() {
    if (_refuelings.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight, width: 1.5),
        ),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.history_toggle_off, size: 40, color: AppTheme.textSecondary),
              SizedBox(height: 8),
              Text('Henüz yakıt kaydı bulunmuyor.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _refuelings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final refueling = _refuelings[index];
        return Dismissible(
          key: Key(refueling.refuelingId),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981), // Emerald Green
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white),
                SizedBox(width: 8),
                Text('Sanal Akaryakıt Fişi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Yakıt Alımını Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final bool? confirm = await _showConfirmDeleteDialog(refueling.refuelingId);
              return confirm == true;
            } else if (direction == DismissDirection.startToEnd) {
              _showVirtualReceiptDialog(refueling);
              return false; // Don't dismiss from UI on right swipe
            }
            return false;
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sol taraf dikey yeşil kaydırılabilir çizgi indikatörü (Sanal Fiş için)
                  Container(
                    width: 4,
                    color: const Color(0xFF10B981),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.lightSurface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: refueling.isFullTank ? const Color(0xFF16A34A).withValues(alpha: 0.15) : const Color(0xFF64748B).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              refueling.isFullTank ? Icons.battery_full : Icons.battery_charging_full,
                              color: refueling.isFullTank ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${refueling.liters.toStringAsFixed(1)} LT • ${refueling.totalPrice.toStringAsFixed(2)} TL',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${refueling.purchaseDate.day}/${refueling.purchaseDate.month}/${refueling.purchaseDate.year} • ${refueling.odometer == 0 ? 'KM Belirtilmedi' : '${_formatOdometer(refueling.odometer)} KM'}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (refueling.imagePath != null &&
                              refueling.imagePath!.isNotEmpty &&
                              File(refueling.imagePath!).existsSync()) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.image_rounded,
                                color: AppTheme.primaryCyan,
                                size: 24,
                              ),
                              tooltip: 'Fiş Görselini Göster',
                              onPressed: () {
                                _showImagePreviewDialog(File(refueling.imagePath!));
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Sağ taraf dikey kırmızı kaydırılabilir çizgi indikatörü (Silme için)
                  Container(
                    width: 4,
                    color: AppTheme.errorRed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDeleteDialog(String refuelingId) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightSurface,
          title: const Text('Kaydı Sil', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: const Text('Bu yakıt dolum kaydını silmek istediğinize emin misiniz? Tüketim oranlarınız yeniden hesaplanacaktır.', style: TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              child: const Text('VAZGEÇ', style: TextStyle(color: AppTheme.textSecondary)),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('SİL'),
              onPressed: () async {
                Navigator.pop(context, true); // Dialogu kapat ve true değerini dön
                
                // UI listesinden kaydı hemen çıkararak Dismissible çökmesini engelliyoruz
                setState(() {
                  _refuelings.removeWhere((r) => r.refuelingId == refuelingId);
                });

                final db = DbService().database;
                await db.deleteRefueling(refuelingId);
                
                // Kayıt silindikten sonra aracın güncel kilometresini yeniden hesapla ve güncelle
                if (_selectedVehicleId != null) {
                  final refList = await db.getRefuelingsForVehicle(_selectedVehicleId!);
                  final currentVehicle = await db.getVehicleById(_selectedVehicleId!);
                  if (currentVehicle != null) {
                    int newOdo = currentVehicle.initialOdometer;
                    if (refList.isNotEmpty) {
                      int maxOdo = currentVehicle.initialOdometer;
                      for (final ref in refList) {
                        if (ref.odometer > maxOdo) {
                          maxOdo = ref.odometer;
                        }
                      }
                      newOdo = maxOdo;
                    }
                    await db.updateVehicle(currentVehicle.copyWith(currentOdometer: newOdo));
                  }
                }
                
                _refreshData();
              },
            ),
          ],
        );
      },
    );
  }

  void _showForegroundToast(BuildContext context, String message) {
    late OverlayEntry overlayEntry;
    Timer? autoDismissTimer;
    bool isDismissed = false;

    void dismiss() {
      if (!isDismissed) {
        isDismissed = true;
        overlayEntry.remove();
        autoDismissTimer?.cancel();
      }
    }

    autoDismissTimer = Timer(const Duration(seconds: 2), () {
      dismiss();
    });

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.vertical,
            onDismissed: (_) => dismiss(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
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

  Future<void> _showVirtualReceiptDialog(Refueling refueling) async {
    String stationName = 'Bilinmiyor';
    if (refueling.stationId != null) {
      final db = DbService().database;
      try {
        final allStations = await db.getAllStations();
        final matches = allStations.where((s) => s.stationId == refueling.stationId).toList();
        if (matches.isNotEmpty) {
          stationName = matches.first.brandName;
        }
      } catch (_) {
        // Hataları yoksay
      }
    }

    if (!mounted) return;
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
              Icon(Icons.receipt_long, color: AppTheme.primaryCyan),
              SizedBox(width: 10),
              Text(
                'Sanal Fiş Detayları',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu yakıt alımına ait sanal fiş oluşturulmuştur. Cihazınızda saklanan veriler aşağıdadır:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('İstasyon:', stationName),
                    const Divider(color: AppTheme.borderLight, height: 16),
                    _buildReceiptRow('Litre Miktarı:', '${refueling.liters.toStringAsFixed(2)} LT'),
                    const Divider(color: AppTheme.borderLight, height: 16),
                    _buildReceiptRow('Birim Fiyat:', '${refueling.unitPrice.toStringAsFixed(2)} TL/LT'),
                    const Divider(color: AppTheme.borderLight, height: 16),
                    _buildReceiptRow('Toplam Tutar:', '${refueling.totalPrice.toStringAsFixed(2)} TL'),
                    const Divider(color: AppTheme.borderLight, height: 16),
                    _buildReceiptRow('Yakıt Kilometresi:', refueling.odometer == 0 ? 'Belirtilmedi' : '${_formatOdometer(refueling.odometer)} KM'),
                    const Divider(color: AppTheme.borderLight, height: 16),
                    _buildReceiptRow(
                      'Tarih:',
                      '${refueling.purchaseDate.day}/${refueling.purchaseDate.month}/${refueling.purchaseDate.year}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
          actions: [
            Row(
              children: [
                // Fiş Fotoğrafını Göster Butonu
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      if (refueling.imagePath != null && refueling.imagePath!.isNotEmpty) {
                        final file = File(refueling.imagePath!);
                        if (file.existsSync()) {
                          _showImagePreviewDialog(file);
                          return;
                        }
                      }
                      // Fotoğraf bulunamadı uyarısı göster
                      _showForegroundToast(context, 'Kayıtlı fotoğraf bulunamadı.');
                    },
                    icon: const Icon(Icons.image_outlined, size: 14),
                    label: const Text(
                      'FİŞ GÖRSELİ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                // Düzenle Butonu
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Dialogu kapat
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRefuelingScreen(
                            initialVehicleId: _selectedVehicleId,
                            editRefueling: refueling,
                          ),
                        ),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text(
                      'DÜZENLE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                // Kapat Butonu
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: const Text(
                      'KAPAT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    final isUnknown = value == 'Bilinmiyor';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(
            color: isUnknown ? Colors.orange : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddRefuelingMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'YAKIT ALIMI EKLE',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Yakıt dolumunu kaydetmek için bir yöntem seçin.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                _buildMenuOption(
                  icon: Icons.camera_alt,
                  color: AppTheme.primaryTeal,
                  title: 'Kamera ile Fiş Tara',
                  subtitle: 'Akıllı tarama ile litre, fiyat ve tarihi otomatik okur',
                  onTap: () async {
                    Navigator.pop(context);
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptScannerScreen(
                          vehicleId: _selectedVehicleId!,
                          vehicle: _selectedVehicle!,
                          initialSource: ImageSource.camera,
                        ),
                      ),
                    );
                    if (added == true) _refreshData();
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuOption(
                  icon: Icons.photo_library,
                  color: AppTheme.accentOrange,
                  title: 'Galeriden Fiş Seç',
                  subtitle: 'Fotoğraf albümünüzden fiş görselini seçerek tarar',
                  onTap: () async {
                    Navigator.pop(context);
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptScannerScreen(
                          vehicleId: _selectedVehicleId!,
                          vehicle: _selectedVehicle!,
                          initialSource: ImageSource.gallery,
                        ),
                      ),
                    );
                    if (added == true) _refreshData();
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuOption(
                  icon: Icons.edit_note,
                  color: const Color(0xFF475569),
                  title: 'Manuel Yakıt Girişi',
                  subtitle: 'Tüm akaryakıt verilerini kendiniz elle yazın',
                  onTap: () async {
                    Navigator.pop(context);
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRefuelingScreen(
                          initialVehicleId: _selectedVehicleId,
                        ),
                      ),
                    );
                    if (added == true) _refreshData();
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Future<List<SmsTransaction>> _fetchPotentialSmsTransactions() async {
    List<SmsTransaction> potentialTxs = [];
    try {
      final messages = await SmsQuery().querySms(
        kinds: [SmsQueryKind.inbox],
        count: 100,
      );

      for (final msg in messages) {
        final tx = _smsParser.parseSms(
          msg.body ?? '',
          smsDate: msg.date,
          sender: msg.sender ?? msg.address,
        );
        if (tx != null) {
          potentialTxs.add(tx);
        }
      }
    } catch (_) {
      // Hataları yoksay
    }
    return potentialTxs;
  }

  Future<void> _scanDeviceSmsInbox() async {
    // 1. Yükleme göstergesini başlat
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          color: AppTheme.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan)),
                SizedBox(height: 16),
                Text(
                  'Gelen Kutusu Taranıyor...',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 8),
                Text(
                  'Akaryakıt harcamaları ayıklanıyor...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    List<SmsTransaction> potentialTxs = [];

    try {
      // 2. SMS İznini iste
      final status = await Permission.sms.request();
      
      if (status.isGranted) {
        potentialTxs = await _fetchPotentialSmsTransactions();
      }
    } catch (_) {
      // Hataları yoksay
    }

    // 4. Yükleme göstergesini kapat
    if (mounted) {
      Navigator.pop(context);
      
      // 5. Potansiyel harcamaları gösteren premium alt sayfayı aç
      _showPotentialSmsDialog(potentialTxs);
    }
  }

  void _showPotentialSmsDialog(List<SmsTransaction> txs) {
    int? expandedIndex;
    bool isRescanning = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Sol Üste Yenileme Butonu
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: isRescanning
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal, size: 24),
                                tooltip: 'Yeniden Analiz Et',
                                onPressed: () async {
                                  setModalState(() {
                                    isRescanning = true;
                                  });
                                  final freshTxs = await _fetchPotentialSmsTransactions();
                                  setModalState(() {
                                    txs.clear();
                                    txs.addAll(freshTxs);
                                    expandedIndex = null;
                                    isRescanning = false;
                                  });
                                },
                              ),
                      ),
                      const Expanded(
                        child: Text(
                          'POTANSİYEL HARCAMALAR',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Simetriyi sağlamak için sağda boşluk
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'SMS gelen kutunuzdan ayıklanan olası akaryakıt harcamaları aşağıdadır. Dokunarak mesaj içeriğini görebilir ve onaylayıp ekleyebilirsiniz.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: txs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.mark_email_read, size: 48, color: AppTheme.textSecondary),
                                SizedBox(height: 12),
                                Text(
                                  'Yeni akaryakıt SMS\'i bulunamadı.',
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: txs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final tx = txs[index];
                              final isExpanded = expandedIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (expandedIndex == index) {
                                      expandedIndex = null;
                                    } else {
                                      expandedIndex = index;
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isExpanded ? AppTheme.primaryTeal : AppTheme.borderLight,
                                      width: isExpanded ? 2.0 : 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.local_gas_station, color: AppTheme.primaryTeal, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tx.merchantName,
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${tx.date.day}/${tx.date.month}/${tx.date.year} • Dokun ve Mesajı Gör',
                                                  style: const TextStyle(
                                                    color: AppTheme.textSecondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${tx.amount.toStringAsFixed(2)} TL',
                                                style: const TextStyle(
                                                  color: AppTheme.primaryTeal,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final db = DbService().database;
                                                  final userId = _currentUserId;

                                                  final companion = CardTransactionsCompanion(
                                                    transactionId: drift.Value(const Uuid().v4()),
                                                    userId: drift.Value(userId),
                                                    transactionDate: drift.Value(tx.date),
                                                    amount: drift.Value(tx.amount),
                                                    merchantName: drift.Value(tx.merchantName),
                                                    source: drift.Value('SMS'),
                                                  );

                                                  try {
                                                    await db.insertCardTransaction(companion);
                                                    
                                                    // Modaldaki listeden sil
                                                    setModalState(() {
                                                      txs.removeAt(index);
                                                      if (expandedIndex == index) {
                                                        expandedIndex = null;
                                                      }
                                                    });

                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('${tx.merchantName} harcaması başarıyla finansal kayıtlara eklendi!'),
                                                        backgroundColor: AppTheme.primaryCyan,
                                                        duration: const Duration(seconds: 2),
                                                      ),
                                                    );
                                                    _refreshData();
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Kayıt başarısız: $e'),
                                                        backgroundColor: AppTheme.errorRed,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                  backgroundColor: const Color(0xFF10B981), // Emerald Green
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                child: const Text('KABUL ET'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (isExpanded && tx.rawBody != null) ...[
                                        const SizedBox(height: 12),
                                        const Divider(color: AppTheme.borderLight, height: 1),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Gelen SMS Metni:',
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9), // Slate 100
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppTheme.borderLight),
                                          ),
                                          child: Text(
                                            tx.rawBody!,
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 11,
                                              height: 1.4,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- YENİ EKLENEN YARDIMCI METOTLAR (BEKLEYEN HARCAMALAR & PREMIUM POPUP'LAR) ---

  Widget _buildPendingTransactionsSection() {
    if (_unapprovedTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alınan Satın Almalar',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_unapprovedTransactions.length} Bekleyen',
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _unapprovedTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = _unapprovedTransactions[index];
            return Dismissible(
              key: Key(tx.transactionId),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981), // Emerald Green
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Satın Almayı Onayla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Satın Almayı Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.delete_sweep_rounded, color: Colors.white),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Sağ kaydırma - Tamamla
                  final completed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRefuelingScreen(
                        initialVehicleId: _selectedVehicleId,
                        initialCardTransaction: tx,
                      ),
                    ),
                  );
                  if (completed == true) {
                    _refreshData();
                  }
                  return false;
                } else {
                  // Sol kaydırma - Sil
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.lightSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Harcamayı Sil', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                      content: const Text('Bu kart harcamasını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.', style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          child: const Text('VAZGEÇ', style: TextStyle(color: AppTheme.textSecondary)),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: AppTheme.lightSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('SİL'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final transactionIdToDelete = tx.transactionId;
                    setState(() {
                      _unapprovedTransactions.removeWhere((t) => t.transactionId == transactionIdToDelete);
                    });
                    final db = DbService().database;
                    await db.deleteCardTransaction(transactionIdToDelete);
                    _refreshData();
                    return true;
                  }
                  return false;
                }
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sol taraf dikey yeşil kaydırılabilir çizgi indikatörü (Onaylama için)
                      Container(
                        width: 4,
                        color: const Color(0xFF10B981),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => _showTransactionDetailsPopup(tx),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: AppTheme.lightSurface,
                            ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tx.merchantName,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year} • ${tx.source}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Ortalı Tutar Alanı
                              Center(
                                child: Text(
                                  '${tx.amount.toStringAsFixed(2)} TL',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                      // Sağ taraf dikey kırmızı kaydırılabilir çizgi indikatörü (Silme için)
                      Container(
                        width: 4,
                        color: AppTheme.errorRed,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                                    fontSize: 18,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shadowColor: color.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ANLADIM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDepodanDepoyaPopup() {
    _showPremiumInfoPopup(
      title: 'Depodan Depoya',
      icon: Icons.local_gas_station,
      color: const Color(0xFF3B82F6),
      children: [
        const Text(
          'İki ardışık tam dolum arasındaki net akaryakıt tüketimini hesaplar.',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _buildPopupBulletPoint(
          icon: Icons.calculate_outlined,
          title: 'Nasıl Hesaplanır?',
          description: 'Bir önceki tamamen dolu depo ile son tamamen dolu depo arasında katettiğiniz mesafeyi (KM) ve bu süreçte depoya giren tüm yakıt miktarlarını (varsa aradaki kısmi alımlar dahil) toplar. Toplam litreyi mesafeye bölerek 100 KM tüketimini verir.',
        ),
        const SizedBox(height: 12),
        _buildPopupBulletPoint(
          icon: Icons.check_circle_outline,
          title: 'Neden En Güvenilir Yöntemdir?',
          description: 'Çünkü yakıt pompalarındaki tabanca atım paylarını ve aradaki parça alımları mükemmel bir şekilde hesaba katar. Sektör standardı en net yakıt ölçüm metodudur.',
        ),
      ],
    );
  }

  void _showKayanOrtalamaPopup() {
    _showPremiumInfoPopup(
      title: 'Kayan Ortalama',
      icon: Icons.trending_up,
      color: AppTheme.accentOrange,
      children: [
        const Text(
          'Aracınızın son dönemdeki genel yakıt tüketim trendini dengeler ve gösterir.',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _buildPopupBulletPoint(
          icon: Icons.auto_graph_outlined,
          title: 'Nasıl Hesaplanır?',
          description: 'Tüm yakıt alım geçmişinizi (kısmi dolumlar dahil) kronolojik olarak sıraya koyar ve zaman ile kilometreye göre ağırlıklandırarak kayan bir ortalama çıkartır. Tekil dolumlardaki sapmaları yumuşatır.',
        ),
        const SizedBox(height: 12),
        _buildPopupBulletPoint(
          icon: Icons.speed_outlined,
          title: 'Neden Önemlidir?',
          description: 'Tek bir uzun yol sürüşünün veya yoğun şehir içi trafiğinin genel istatistiklerinizi aniden yanıltmasını önler. Aracınızın gerçek yakıt karakteristiğini yansıtır.',
        ),
      ],
    );
  }

  void _showOtomasyonPopup() {
    _showPremiumInfoPopup(
      title: 'Veri Otomasyonu',
      icon: Icons.smart_toy,
      color: AppTheme.primaryCyan,
      children: [
        const Text(
          'Akaryakıt harcamalarınızı saniyeler içinde otomatik olarak analiz etmenizi sağlar.',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _buildPopupBulletPoint(
          icon: Icons.picture_as_pdf_outlined,
          title: 'PDF Ekstre Yükleme',
          description: 'Bankanızdan aldığınız kredi kartı ekstrenizi PDF olarak yükleyin. Gelişmiş analiz algoritmaları sadece akaryakıt işlemlerini bulup süzer ve listeler.',
        ),
        const SizedBox(height: 12),
        _buildPopupBulletPoint(
          icon: Icons.sms_outlined,
          title: 'SMS Tarama & Pano',
          description: 'Gelen banka bildirim mesajlarını kopyaladığınızda pano üzerinden veya cihazınızın gelen kutusunu taratarak akaryakıt ödemelerini otomatik olarak yakalar.',
        ),
      ],
    );
  }

  Widget _buildPopupBulletPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTransactionDetailsPopup(CardTransaction tx) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final months = [
          'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
          'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
        ];
        final weekdays = [
          'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
        ];
        final dateStr = '${tx.transactionDate.day} ${months[tx.transactionDate.month - 1]} ${tx.transactionDate.year}';
        final weekdayStr = weekdays[tx.transactionDate.weekday - 1];

        final isFuel = PdfStatementParser.isFuelMerchant(tx.merchantName);
        final isApproved = tx.refuelingId != null;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.lightSurface,
                  Color(0xFFF8FAFC),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isApproved
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFuel
                                  ? AppTheme.primaryCyan.withValues(alpha: 0.1)
                                  : const Color(0xFF64748B).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFuel ? Icons.local_gas_station : Icons.storefront_rounded,
                              color: isFuel ? AppTheme.primaryCyan : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'İşlem Detayları',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppTheme.primaryCyan, size: 14),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 16, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                '${tx.amount.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                  color: AppTheme.primaryCyan,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isFuel
                                      ? AppTheme.primaryCyan.withValues(alpha: 0.1)
                                      : const Color(0xFF64748B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isFuel ? 'AKARYAKIT HARCAMASI' : 'GENEL HARCAMA',
                                  style: TextStyle(
                                    color: isFuel ? AppTheme.primaryCyan : const Color(0xFF64748B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('İşyeri:', tx.merchantName, isBold: true),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow('Tarih:', '$dateStr, $weekdayStr'),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow('Kaynak:', '${tx.source} Bildirimi'),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow(
                        'İşlem Durumu:',
                        isApproved
                            ? 'Onaylandı (Yakıt Geçmişinde)'
                            : 'Bekleyen Harcama',
                        valueColor: isApproved
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        isBold: true,
                      ),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow(
                        'Benzersiz ID:',
                        '${tx.transactionId.substring(0, 8)}...',
                        isItalic: true,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx.transactionId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('İşlem ID\'si panoya kopyalandı.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('KAPAT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {
    Color? valueColor,
    bool isBold = false,
    bool isItalic = false,
    VoidCallback? onTap,
  }) {
    Widget valueWidget = Text(
      value,
      textAlign: TextAlign.end,
      style: TextStyle(
        color: valueColor ?? AppTheme.textPrimary,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        fontSize: 13,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (onTap != null) {
      valueWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textPrimary,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.content_copy_rounded,
                size: 14,
                color: valueColor ?? AppTheme.primaryCyan,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: valueWidget),
      ],
    );
  }

  Future<void> _ensureProfileExists() async {
    final db = DbService().database;
    final userId = _currentUserId;
    
    // Test kullanıcısı ise veya giriş yapılmamışsa engelleme
    if (userId == '11111111-1111-1111-1111-111111111111') return;

    var profile = await db.getProfileById(userId);
    
    if (profile == null) {
      // Çevrimdışı senkronizasyon gecikmesini bypass etmek için Supabase'den doğrudan çekelim
      try {
        final supabaseProfile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
            
        if (supabaseProfile != null) {
          final fullName = supabaseProfile['full_name'] as String?;
          final phoneNumber = supabaseProfile['phone_number'] as String?;
          
          if (fullName != null && fullName.isNotEmpty &&
              phoneNumber != null && phoneNumber.isNotEmpty) {
            await db.insertProfile(
              ProfilesCompanion(
                userId: drift.Value(userId),
                email: drift.Value(supabaseProfile['email'] as String? ?? _currentUserEmail),
                fullName: drift.Value(fullName),
                phoneNumber: drift.Value(phoneNumber),
                tckn: drift.Value(supabaseProfile['tckn'] as String?),
                premiumStatus: drift.Value(supabaseProfile['premium_status'] as bool? ?? false),
              ),
            );
            profile = await db.getProfileById(userId);
          }
        }
      } catch (_) {}
    }
    
    // Eğer profil yoksa veya ad soyad / telefon bilgisi eksikse kullanıcıyı profil tamamlamaya zorunlu tut
    if (profile == null || 
        profile.fullName == null || 
        profile.fullName!.isEmpty || 
        profile.phoneNumber == null || 
        profile.phoneNumber!.isEmpty) {
      
      if (mounted) {
        _showProfileBottomSheet(isRequired: true);
      }
    }
  }


  void _showProfileBottomSheet({bool isRequired = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !isRequired,
      enableDrag: !isRequired,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProfileBottomSheetContent(
          userProfile: _userProfile,
          currentUserEmail: _currentUserEmail,
          currentUserId: _currentUserId,
          isRequired: isRequired,
          onProfileUpdated: _refreshData,
          onLogout: _handleLogout,
        );
      },
    );
  }
}

class ProfileBottomSheetContent extends StatefulWidget {
  final Profile? userProfile;
  final String currentUserEmail;
  final String currentUserId;
  final bool isRequired;
  final VoidCallback onProfileUpdated;
  final VoidCallback onLogout;

  const ProfileBottomSheetContent({
    super.key,
    required this.userProfile,
    required this.currentUserEmail,
    required this.currentUserId,
    required this.isRequired,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  @override
  State<ProfileBottomSheetContent> createState() => _ProfileBottomSheetContentState();
}

class _ProfileBottomSheetContentState extends State<ProfileBottomSheetContent> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController tcknController;
  final formKey = GlobalKey<FormState>();
  final tcknFocusNode = FocusNode();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userProfile?.fullName ?? '');
    phoneController = TextEditingController(
      text: widget.userProfile?.phoneNumber != null 
          ? PhoneInputFormatter.format(widget.userProfile!.phoneNumber!) 
          : '',
    );
    
    String decryptedTckn = '';
    if (widget.userProfile?.tckn != null && widget.userProfile!.tckn!.isNotEmpty) {
      try {
        decryptedTckn = AesHelper.decrypt(widget.userProfile!.tckn!);
      } catch (_) {}
    }
    tcknController = TextEditingController(text: decryptedTckn);
    
    tcknFocusNode.addListener(_onTcknFocusChange);
  }

  void _onTcknFocusChange() {
    if (!tcknFocusNode.hasFocus) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    tcknFocusNode.removeListener(_onTcknFocusChange);
    tcknFocusNode.dispose();
    nameController.dispose();
    phoneController.dispose();
    tcknController.dispose();
    super.dispose();
  }

  bool _isValidTckn(String tckn) {
    if (tckn.length != 11) return false;
    if (tckn.startsWith('0')) return false;

    try {
      final List<int> digits = tckn.split('').map((char) => int.parse(char)).toList();
      
      final int sumOdd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
      final int sumEven = digits[1] + digits[3] + digits[5] + digits[7];
      
      final int d10 = (((sumOdd * 7) - sumEven) % 10 + 10) % 10;
      if (d10 != digits[9]) return false;
      
      final int sumFirst10 = digits.sublist(0, 10).reduce((a, b) => a + b);
      final int d11 = sumFirst10 % 10;
      if (d11 != digits[10]) return false;
      
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil Bilgilerim',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!widget.isRequired)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // E-posta (Read Only)
              TextFormField(
                initialValue: widget.userProfile?.email ?? widget.currentUserEmail,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),
              // Ad Soyad
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Telefon No
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [PhoneInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Telefon No *',
                  hintText: '(530) 123 45 67',
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.phone_outlined, color: AppTheme.primaryCyan),
                      const SizedBox(width: 8),
                      const Text(
                        '+90',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 18,
                        color: AppTheme.borderLight,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen telefon numaranızı girin.';
                  }
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 10) {
                    return 'Telefon numarası 10 haneli olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // TCKN
              TextFormField(
                controller: tcknController,
                focusNode: tcknFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 11,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'TC Kimlik No (İsteğe Bağlı)',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryCyan),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (!isSubmitting && tcknFocusNode.hasFocus && value.length < 11) {
                    return null;
                  }
                  if (value.length != 11) {
                    return 'T.C. Kimlik Numarası 11 haneli olmalıdır.';
                  }
                  if (!_isValidTckn(value)) {
                    return 'Geçersiz T.C. Kimlik Numarası.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Kaydet Butonu
              ElevatedButton(
                onPressed: () async {
                  if (mounted) {
                    setState(() {
                      isSubmitting = true;
                    });
                  }
                  if (!formKey.currentState!.validate()) return;
                  
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  final db = DbService().database;
                  final rawTckn = tcknController.text.trim();
                  final encryptedTckn = rawTckn.isNotEmpty ? AesHelper.encrypt(rawTckn) : null;
                  
                  final fullNameVal = nameController.text.trim();
                  final phoneVal = phoneController.text.trim();
                  final emailVal = widget.userProfile?.email ?? widget.currentUserEmail;
                  final premiumVal = widget.userProfile?.premiumStatus ?? false;

                  // 1. Supabase'e doğrudan kaydet
                  try {
                    await Supabase.instance.client.from('profiles').upsert({
                      'user_id': widget.currentUserId,
                      'email': emailVal,
                      'full_name': fullNameVal,
                      'tckn': encryptedTckn,
                      'phone_number': phoneVal,
                      'premium_status': premiumVal,
                    }, onConflict: 'user_id');

                    // Auth metadata'yı da güncelle ki Supabase Auth panelinde de güncellensin!
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(
                        data: {
                          'full_name': fullNameVal,
                          'phone_number': phoneVal,
                          'tckn': encryptedTckn,
                        },
                      ),
                    );
                  } catch (e) {
                    print('HomeScreen: Direct Supabase upsert error during updates: $e');
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Supabase Güncelleme Hatası: $e'),
                          backgroundColor: AppTheme.errorRed,
                          duration: const Duration(seconds: 10),
                        ),
                      );
                    }
                  }

                  // 2. Yerel veritabanına kaydet
                  await db.insertProfile(
                    ProfilesCompanion(
                      userId: drift.Value(widget.currentUserId),
                      email: drift.Value(emailVal),
                      fullName: drift.Value(fullNameVal),
                      tckn: drift.Value(encryptedTckn),
                      phoneNumber: drift.Value(phoneVal),
                      premiumStatus: drift.Value(premiumVal),
                    ),
                  );
                  
                  widget.onProfileUpdated();
                  if (mounted) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Profil bilgileriniz başarıyla güncellendi!'),
                        backgroundColor: AppTheme.primaryCyan,
                      ),
                    );
                  }
                },
                child: const Text('BİLGİLERİ GÜNCELLE'),
              ),
              const SizedBox(height: 12),
              // Çıkış Yap Butonu
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('OTURUMU KAPAT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Telefon Numarası Formatlayıcı
class PhoneInputFormatter extends TextInputFormatter {
  static String format(String text) {
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
    final digits = cleanText.length > 10 ? cleanText.substring(0, 10) : cleanText;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(digits[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 5) {
        buffer.write(' ');
      } else if (i == 7) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
    final digits = cleanText.length > 10 ? cleanText.substring(0, 10) : cleanText;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(digits[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 5) {
        buffer.write(' ');
      } else if (i == 7) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    int selectionIndex = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
