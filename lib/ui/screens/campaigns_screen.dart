import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';
import '../../core/campaign/campaign_decision_engine.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppDatabase _db = DbService().database;
  
  List<UserCard> _userCards = [];
  List<GlobalCampaign> _globalCampaigns = [];
  List<Campaign> _activeUserCampaigns = [];
  bool _isLoading = true;
  
  // Tavsiye motoru için seçili marka
  String _selectedAdvisorBrand = 'Shell';
  // Keşfet sekmesi için seçili marka filtresi
  String _selectedDiscoverBrand = 'HEPSİ';

  // Scroll controllers for parallax scrolling
  late final ScrollController _discoverScrollController;
  late final ScrollController _rankerScrollController;

  // Cüzdanda seçilebilecek kart programı şablonları
  final List<Map<String, dynamic>> _cardPresets = [
    {
      'bankName': 'Garanti BBVA',
      'cardProgram': 'Bonus',
      'color': const Color(0xFF00A859), // Bonus Yeşili
      'textColor': Colors.white,
      'slogan': 'Bol Bol Bonus Kazandırır',
      'network': 'Mastercard',
    },
    {
      'bankName': 'Yapı Kredi',
      'cardProgram': 'World',
      'color': const Color(0xFF5A1C7D), // World Moru
      'textColor': Colors.white,
      'slogan': 'Dünya Kadar Ayrıcalık',
      'network': 'Visa',
    },
    {
      'bankName': 'İş Bankası',
      'cardProgram': 'Maximum',
      'color': const Color(0xFFE50050), // Maximum Pembemsi Kırmızı
      'textColor': Colors.white,
      'slogan': 'Maksimum Hayat, Maksimum Kart',
      'network': 'Visa',
    },
    {
      'bankName': 'Akbank',
      'cardProgram': 'Axess',
      'color': const Color(0xFFFFCC00), // Axess Sarısı
      'textColor': const Color(0xFF1E293B),
      'slogan': 'Kazandıran Kart Axess',
      'network': 'Mastercard',
    },
    {
      'bankName': 'QNB Finansbank',
      'cardProgram': 'CardFinans',
      'color': const Color(0xFF0A2F64), // Finans Lacivert
      'textColor': Colors.white,
      'slogan': 'Finansal Yol Arkadaşınız',
      'network': 'Visa',
    },
    {
      'bankName': 'Halkbank',
      'cardProgram': 'Paraf',
      'color': const Color(0xFF00A2E8), // Paraf Açık Mavi
      'textColor': Colors.white,
      'slogan': 'Ayrıcalıklar Paraf\'ta',
      'network': 'TROY',
    },
    {
      'bankName': 'Ziraat Bankası',
      'cardProgram': 'Bankkart',
      'color': const Color(0xFFED1C24), // Ziraat Kırmızısı
      'textColor': Colors.white,
      'slogan': 'Ziraat\'ten Bir Başka Kart',
      'network': 'TROY',
    },
    {
      'bankName': 'VakıfBank',
      'cardProgram': 'Vakıfkart',
      'color': const Color(0xFFF1A80A), // VakıfBank Sarısı
      'textColor': const Color(0xFF1E293B),
      'slogan': 'Daima Seninle',
      'network': 'TROY',
    },
    {
      'bankName': 'DenizBank',
      'cardProgram': 'Deniz Bonus',
      'color': const Color(0xFF0F3A60), // DenizBank Laciverti
      'textColor': Colors.white,
      'slogan': 'Hayat Denizde Güzel',
      'network': 'Visa',
    },
    {
      'bankName': 'TEB',
      'cardProgram': 'TEB Bonus',
      'color': const Color(0xFF167B46), // TEB Yeşili
      'textColor': Colors.white,
      'slogan': 'Pratik Kart TEB',
      'network': 'Mastercard',
    },
    {
      'bankName': 'Kuveyt Türk',
      'cardProgram': 'Sağlam Kart',
      'color': const Color(0xFF0F5A47), // Kuveyt Türk Yeşili
      'textColor': Colors.white,
      'slogan': 'Sağlam Kart, Sağlam Kazanç',
      'network': 'TROY',
    },
    {
      'bankName': 'Türkiye Finans',
      'cardProgram': 'Happy Card',
      'color': const Color(0xFF0B8E36), // Türkiye Finans Yeşili
      'textColor': Colors.white,
      'slogan': 'Hayata Katılan Kart',
      'network': 'Visa',
    },
    {
      'bankName': 'Albaraka Türk',
      'cardProgram': 'Albaraka World',
      'color': const Color(0xFF907851), // Albaraka Altın Rengi
      'textColor': Colors.white,
      'slogan': 'Dünyanı Kolaylaştıran Kart',
      'network': 'Mastercard',
    },
    {
      'bankName': 'ING',
      'cardProgram': 'ING Bonus',
      'color': const Color(0xFFFF6600), // ING Turuncusu
      'textColor': Colors.white,
      'slogan': 'Sen Hayatını Yaşa',
      'network': 'Visa',
    },
  ];

  static const Map<String, String> _campaignImages = {
    'c1': 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=600&auto=format&fit=crop&q=80', // Shell / Garanti
    'c2': 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600&auto=format&fit=crop&q=80', // Opet / Yapı Kredi
    'c3': 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=600&auto=format&fit=crop&q=80', // Petrol Ofisi / İş Bankası
    'c4': 'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?w=600&auto=format&fit=crop&q=80', // BP / Akbank
    'c5': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=80', // Shell / Ziraat
    'c6': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80', // Opet / Halkbank
  };

  String? _getCampaignImage(String campaignId, String brand) {
    if (_campaignImages.containsKey(campaignId)) {
      return _campaignImages[campaignId];
    }
    final cleanBrand = brand.toLowerCase();
    if (cleanBrand.contains('shell')) {
      return 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=600&auto=format&fit=crop&q=80';
    } else if (cleanBrand.contains('opet')) {
      return 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600&auto=format&fit=crop&q=80';
    } else if (cleanBrand.contains('petrol ofisi')) {
      return 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=600&auto=format&fit=crop&q=80';
    }
    return null;
  }

  String get _currentUserId {
    return Supabase.instance.client.auth.currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _discoverScrollController = ScrollController();
    _rankerScrollController = ScrollController();
    _loadData(showSpinner: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _discoverScrollController.dispose();
    _rankerScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showSpinner = false}) async {
    if (showSpinner) {
      setState(() => _isLoading = true);
    }
    try {
      final userCards = await _db.getUserCards(_currentUserId);
      final activeCampaigns = await _db.getCampaignsForUser(_currentUserId);
      
      // Kampanyaları çekelim. Veritabanı boşsa örnek veri tohumlayalım.
      var campaigns = await _db.getActiveGlobalCampaigns();
      if (campaigns.isEmpty) {
        await _seedMockCampaigns();
        campaigns = await _db.getActiveGlobalCampaigns();
      }

      setState(() {
        _userCards = userCards;
        _globalCampaigns = campaigns;
        _activeUserCampaigns = activeCampaigns;
      });
    } catch (e) {
      print('Kampanyalar yüklenirken hata oluştu: $e');
    } finally {
      if (showSpinner) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kampanya havuzunu test amaçlı örnek verilerle doldurur
  Future<void> _seedMockCampaigns() async {
    final now = DateTime.now();
    final mockCampaigns = [
      GlobalCampaignsCompanion.insert(
        campaignId: 'c1',
        bankName: 'Garanti BBVA',
        stationBrand: 'Shell',
        targetTxCount: 4,
        minTxAmount: 600.0,
        rewardAmount: 150.0,
        isDifferentDaysRequired: const drift.Value(true),
        expiryDate: now.add(const Duration(days: 20)),
        isActive: const drift.Value(true),
      ),
      GlobalCampaignsCompanion.insert(
        campaignId: 'c2',
        bankName: 'Yapı Kredi',
        stationBrand: 'Opet',
        targetTxCount: 3,
        minTxAmount: 500.0,
        rewardAmount: 120.0,
        isDifferentDaysRequired: const drift.Value(true),
        expiryDate: now.add(const Duration(days: 15)),
        isActive: const drift.Value(true),
      ),
      GlobalCampaignsCompanion.insert(
        campaignId: 'c3',
        bankName: 'İş Bankası',
        stationBrand: 'Petrol Ofisi',
        targetTxCount: 4,
        minTxAmount: 600.0,
        rewardAmount: 140.0,
        isDifferentDaysRequired: const drift.Value(true),
        expiryDate: now.add(const Duration(days: 25)),
        isActive: const drift.Value(true),
      ),
      GlobalCampaignsCompanion.insert(
        campaignId: 'c4',
        bankName: 'Akbank',
        stationBrand: 'BP',
        targetTxCount: 4,
        minTxAmount: 500.0,
        rewardAmount: 100.0,
        isDifferentDaysRequired: const drift.Value(true),
        expiryDate: now.add(const Duration(days: 10)),
        isActive: const drift.Value(true),
      ),
      GlobalCampaignsCompanion.insert(
        campaignId: 'c5',
        bankName: 'Ziraat Bankası',
        stationBrand: 'Shell',
        targetTxCount: 3,
        minTxAmount: 400.0,
        rewardAmount: 80.0,
        isDifferentDaysRequired: const drift.Value(false),
        expiryDate: now.add(const Duration(days: 2)), // Yaklaşan kampanya
        isActive: const drift.Value(true),
      ),
      GlobalCampaignsCompanion.insert(
        campaignId: 'c6',
        bankName: 'Halkbank',
        stationBrand: 'Opet',
        targetTxCount: 4,
        minTxAmount: 600.0,
        rewardAmount: 110.0,
        isDifferentDaysRequired: const drift.Value(true),
        expiryDate: now.add(const Duration(days: 18)),
        isActive: const drift.Value(true),
      ),
    ];

    for (final companion in mockCampaigns) {
      await _db.insertGlobalCampaign(companion);
    }
  }

  /// Cüzdana kart ekleme / kart silme işlemi
  Future<void> _toggleCard(Map<String, dynamic> preset) async {
    final bank = preset['bankName'] as String;
    final program = preset['cardProgram'] as String;
    
    // Kartın cüzdanda olup olmadığını kontrol et
    final existingIndex = _userCards.indexWhere((card) =>
        card.bankName.toLowerCase() == bank.toLowerCase() &&
        card.cardProgram.toLowerCase() == program.toLowerCase());

    // 1. Optimistik Arayüz Güncellemesi (Kullanıcıya anında geri bildirim verir)
    setState(() {
      if (existingIndex != -1) {
        _userCards.removeAt(existingIndex);
      } else {
        _userCards.add(UserCard(
          cardId: 'temp_id_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentUserId,
          bankName: bank,
          cardProgram: program,
        ));
      }
    });

    // 2. Arka planda veritabanı işlemlerini gerçekleştir ve veriyi senkronize et
    try {
      if (existingIndex != -1) {
        // Cüzdandan çıkar
        final dbCards = await _db.getUserCards(_currentUserId);
        final cardToDelete = dbCards.firstWhere((card) =>
            card.bankName.toLowerCase() == bank.toLowerCase() &&
            card.cardProgram.toLowerCase() == program.toLowerCase());
        await _db.deleteUserCard(cardToDelete.cardId);
      } else {
        // Cüzdana ekle
        final newCard = UserCardsCompanion.insert(
          cardId: const Uuid().v4(),
          userId: _currentUserId,
          bankName: bank,
          cardProgram: program,
        );
        await _db.insertUserCard(newCard);
      }
    } catch (e) {
      print('Kart güncellenirken veritabanı hatası: $e');
    } finally {
      // 3. Arka planda veritabanı durumunu yerel durum ile senkronize et (Beyaz ekran göstermeden)
      await _loadData(showSpinner: false);
    }
  }

  Future<void> _joinCampaign(GlobalCampaign campaign) async {
    final companion = CampaignsCompanion.insert(
      campaignId: campaign.campaignId,
      userId: _currentUserId,
      bankName: campaign.bankName,
      stationBrand: campaign.stationBrand,
      targetTxCount: campaign.targetTxCount,
      currentTxCount: const drift.Value(0),
      rewardAmount: campaign.rewardAmount,
      expiryDate: campaign.expiryDate,
      campaignUrl: drift.Value(campaign.campaignUrl),
    );

    try {
      // Optimistik Arayüz Güncellemesi
      setState(() {
        _activeUserCampaigns.add(Campaign(
          campaignId: campaign.campaignId,
          userId: _currentUserId,
          bankName: campaign.bankName,
          stationBrand: campaign.stationBrand,
          targetTxCount: campaign.targetTxCount,
          currentTxCount: 0,
          rewardAmount: campaign.rewardAmount,
          expiryDate: campaign.expiryDate,
          campaignUrl: campaign.campaignUrl,
        ));
      });

      await _db.insertCampaign(companion);
      await _loadData(showSpinner: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${campaign.bankName} Kampanyasına Katıldınız! Harcamalarınız otomatik takip edilmeye başlandı. 🚀'),
            backgroundColor: AppTheme.primaryTeal,
          ),
        );
      }
    } catch (e) {
      print('Kampanyaya katılırken veritabanı hatası: $e');
    }
  }

  Future<void> _leaveCampaign(String campaignId, String bankName) async {
    try {
      // Optimistik Arayüz Güncellemesi
      setState(() {
        _activeUserCampaigns.removeWhere((c) => c.campaignId == campaignId);
      });

      await (_db.delete(_db.campaigns)..where((t) => t.campaignId.equals(campaignId))).go();
      await _loadData(showSpinner: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$bankName Kampanya takibi iptal edildi.'),
            backgroundColor: AppTheme.textSecondary,
          ),
        );
      }
    } catch (e) {
      print('Kampanya takibi bırakılırken veritabanı hatası: $e');
    }
  }

  bool _isCardSelected(String bank, String program) {
    return _userCards.any((card) =>
        card.bankName.toLowerCase() == bank.toLowerCase() &&
        card.cardProgram.toLowerCase() == program.toLowerCase());
  }

  static const Map<String, String> _brandLogos = {
    'shell': 'assets/images/shell.png',
    'opet': 'assets/images/opet.png',
    'petrol ofisi': 'assets/images/petrol_ofisi.png',
    'aytemiz': 'assets/images/aytemiz.png',
    'total': 'assets/images/total.png',
    'aygaz': 'assets/images/opet.png',
  };

  Widget _buildBrandLogo(String brandName, Color fallbackColor, {double height = 22}) {
    final cleanBrand = brandName.trim().toLowerCase();
    
    // Find matching logo asset path
    String logoPath = '';
    for (final entry in _brandLogos.entries) {
      if (cleanBrand == entry.key || cleanBrand.contains(entry.key) || entry.key.contains(cleanBrand)) {
        logoPath = entry.value;
        break;
      }
    }

    if (logoPath.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: fallbackColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          brandName.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: fallbackColor,
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Image.asset(
        logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              brandName.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: fallbackColor,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('BANKA KAMPANYALARI'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryTeal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
          tabs: const [
            Tab(icon: Icon(Icons.wallet_rounded), text: 'CÜZDANIM'),
            Tab(icon: Icon(Icons.campaign_rounded), text: 'KEŞFET'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : AntigravityBackground(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWalletTab(),
                  _buildDiscoverTab(),
                ],
              ),
            ),
    );
  }

  /// Cüzdanım sekmesi (Kullanıcının kartlarını seçtiği alan)
  Widget _buildWalletTab() {
    return SingleChildScrollView(
      key: const PageStorageKey<String>('wallet_tab_scroll'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sahip Olduğunuz Kartları Seçin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Seçtiğiniz kartlara ait akaryakıt kampanyaları otomatik olarak önceliklendirilecektir.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ..._cardPresets.map((preset) {
            final isSelected = _isCardSelected(preset['bankName'], preset['cardProgram']);
            final baseColor = preset['color'] as Color;
            final darkColor = Color.fromARGB(
              baseColor.alpha,
              (baseColor.red * 0.85).round(),
              (baseColor.green * 0.85).round(),
              (baseColor.blue * 0.85).round(),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _toggleCard(preset),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? null : Colors.white,
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [baseColor, darkColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.borderLight,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: baseColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: AppTheme.textPrimary.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Stack(
                    children: [
                      // Background watermark logo
                      Positioned(
                        right: -10,
                        bottom: -15,
                        child: Opacity(
                          opacity: isSelected ? 0.08 : 0.03,
                          child: Icon(
                            Icons.payment_rounded,
                            size: 80,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      // Card Chip
                      Positioned(
                        top: 32,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade300.withOpacity(isSelected ? 0.9 : 0.5),
                                Colors.amber.shade500.withOpacity(isSelected ? 0.9 : 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.amber.shade600.withOpacity(isSelected ? 0.8 : 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.amber.shade700.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: Colors.amber.shade700.withOpacity(0.2), height: 1, thickness: 0.5),
                              VerticalDivider(color: Colors.amber.shade700.withOpacity(0.2), width: 1, thickness: 0.5),
                            ],
                          ),
                        ),
                      ),
                      // Card content
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  preset['bankName'].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? preset['textColor'] : AppTheme.textSecondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: preset['textColor'], size: 20)
                                else
                                  const Icon(Icons.circle_outlined, color: AppTheme.borderLight, size: 20),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset['cardProgram'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? preset['textColor'] : AppTheme.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  preset['slogan'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? (preset['textColor'] as Color).withOpacity(0.85)
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Card network logo
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          (preset['network'] ?? 'Visa').toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? preset['textColor'] : AppTheme.textSecondary.withOpacity(0.6),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Kampanya Keşfet sekmesi
  Widget _buildDiscoverTab() {
    if (_userCards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_off_rounded,
                  color: AppTheme.accentOrange,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cüzdanınız Henüz Boş',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Size özel kampanyaları süzebilmemiz için öncelikle "CÜZDANIM" sekmesinden sahip olduğunuz banka kartlarını seçmelisiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(0); // Cüzdanım sekmesine yönlendirir (index 0)
                },
                icon: const Icon(Icons.wallet_rounded, size: 18),
                label: const Text('Kartlarımı Seç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      );
    }

    // Kullanıcının cüzdanına uyan kampanyaları filtrele
    var filteredCampaigns = _globalCampaigns.where((campaign) {
      return _userCards.any((card) =>
          card.bankName.toLowerCase() == campaign.bankName.toLowerCase() ||
          campaign.bankName.toLowerCase().contains(card.bankName.toLowerCase()));
    }).toList();

    // Seçilen marka filtresine göre filtrele
    if (_selectedDiscoverBrand != 'HEPSİ') {
      final filterUpper = _selectedDiscoverBrand.toUpperCase();
      filteredCampaigns = filteredCampaigns.where((campaign) {
        final brandUpper = campaign.stationBrand.toUpperCase();
        if (filterUpper == 'DİĞER' || filterUpper == 'DIĞER') {
          return !['SHELL', 'OPET', 'PETROL OFISI', 'AYTEMIZ', 'TOTAL'].contains(brandUpper);
        }
        return brandUpper.contains(filterUpper) || filterUpper.contains(brandUpper);
      }).toList();
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        CompactBrandFilterBar(
          selectedBrand: _selectedDiscoverBrand,
          onBrandSelected: (brand) {
            setState(() {
              _selectedDiscoverBrand = brand;
            });
          },
          showAllOption: true,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filteredCampaigns.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 48,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedDiscoverBrand == 'HEPSİ'
                              ? 'Cüzdanınızdaki kartlara ait bu ay aktif kampanya bulunamadı.'
                              : '$_selectedDiscoverBrand için uygun aktif kampanya bulunamadı.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _discoverScrollController,
                  key: const PageStorageKey<String>('discover_tab_scroll_v2'),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = filteredCampaigns[index];
                    final daysLeft = campaign.expiryDate.difference(DateTime.now()).inDays;
                    final isUrgent = daysLeft >= 0 && daysLeft <= 3;
                    final depthLayer = (index % 3) + 1;

                    Color brandColor = AppTheme.textSecondary;
                    if (campaign.stationBrand.toLowerCase() == 'shell') {
                      brandColor = const Color(0xFFE30613); // Shell Kırmızı
                    } else if (campaign.stationBrand.toLowerCase() == 'opet') {
                      brandColor = const Color(0xFF005CA9); // Opet Mavi
                    } else if (campaign.stationBrand.toLowerCase() == 'bp') {
                      brandColor = const Color(0xFF00A550); // BP Yeşil
                    } else if (campaign.stationBrand.toLowerCase() == 'petrol ofisi') {
                      brandColor = const Color(0xFFC00000); // Petrol Ofisi Kırmızı
                    }

                    // Check if campaign is active for user
                    final activeUserCampaign = _activeUserCampaigns.any((c) => c.campaignId == campaign.campaignId)
                        ? _activeUserCampaigns.firstWhere((c) => c.campaignId == campaign.campaignId)
                        : null;

                    return ParallaxScrollWrapper(
                      depthLayer: depthLayer,
                      scrollController: _discoverScrollController,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: FloatingOscillator(
                          depthLayer: depthLayer,
                          baseFrequency: 1.0,
                          child: TouchScaleGlowWrapper(
                            onTap: () => _showCampaignDetailBottomSheet(campaign, brandColor),
                            child: GlassmorphicCampaignCard(
                              bankName: campaign.bankName,
                              rewardAmount: campaign.rewardAmount,
                              minTxAmount: campaign.minTxAmount,
                              targetTxCount: campaign.targetTxCount,
                              daysLeft: daysLeft,
                              isUrgent: isUrgent,
                              depthLayer: depthLayer,
                              stationBrand: campaign.stationBrand,
                              brandLogoWidget: _buildBrandLogo(campaign.stationBrand, brandColor, height: 26),
                              activeProgressWidget: null,
                              imageUrl: _getCampaignImage(campaign.campaignId, campaign.stationBrand),
                              actionWidget: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (activeUserCampaign == null) ...[
                                    TextButton(
                                      onPressed: () => _showCampaignDetailBottomSheet(campaign, brandColor),
                                      child: const Text('DETAYLAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _joinCampaign(campaign),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        backgroundColor: AppTheme.primaryTeal,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('KAMPANYAYA KATIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ] else ...[
                                    InkWell(
                                      onTap: () => _leaveCampaign(campaign.campaignId, campaign.bankName),
                                      borderRadius: BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                                            SizedBox(width: 6),
                                            Text(
                                              'TAKİP EDİLİYOR',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: () => _showCampaignDetailBottomSheet(campaign, brandColor),
                                      icon: const Icon(Icons.open_in_browser_rounded, size: 14, color: Colors.white),
                                      label: const Text('YÖNLENDİR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        backgroundColor: AppTheme.accentOrange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Kampanya Detayları Bottom Sheet
  void _showCampaignDetailBottomSheet(GlobalCampaign campaign, Color brandColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Başlık
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        campaign.bankName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      _buildBrandLogo(campaign.stationBrand, brandColor, height: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${campaign.rewardAmount.toStringAsFixed(0)} TL ${campaign.stationBrand} Kampanyası',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 16),
                  // Detaylar listesi
                  _buildDetailItem(Icons.info_outline_rounded, 'Koşul', '${campaign.targetTxCount} adet tek seferde min. ${campaign.minTxAmount.toStringAsFixed(0)} TL harcama.'),
                  if (campaign.isDifferentDaysRequired)
                    _buildDetailItem(Icons.calendar_today_rounded, 'Gün Kısıtı', 'Harcamaların farklı günlerde yapılması gerekmektedir.'),
                  _buildDetailItem(Icons.lock_clock_rounded, 'Son Geçerlilik', '${campaign.expiryDate.day}/${campaign.expiryDate.month}/${campaign.expiryDate.year}'),
                  if (campaign.description != null && campaign.description!.trim().isNotEmpty) ...[
                    _buildDescriptionDetailItem(Icons.description_outlined, 'Kampanya Detayları', campaign.description!),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      
                      final urlStr = campaign.campaignUrl;
                      Uri? uri;
                      if (urlStr != null && urlStr.trim().isNotEmpty) {
                        uri = Uri.tryParse(urlStr.trim());
                      }

                      if (uri == null || !uri.hasScheme) {
                        final bank = campaign.bankName.toLowerCase();
                        String fallbackUrl = 'https://www.google.com';
                        if (bank.contains('garanti') || bank.contains('bonus')) {
                          fallbackUrl = 'https://www.bonus.com.tr';
                        } else if (bank.contains('yapı') || bank.contains('yapi') || bank.contains('world')) {
                          fallbackUrl = 'https://www.worldcard.com.tr';
                        } else if (bank.contains('iş') || bank.contains('is bank') || bank.contains('maximum')) {
                          fallbackUrl = 'https://www.maximum.com.tr';
                        } else if (bank.contains('akbank') || bank.contains('axess')) {
                          fallbackUrl = 'https://www.axess.com.tr';
                        } else if (bank.contains('qnb') || bank.contains('finans')) {
                          fallbackUrl = 'https://www.cardfinans.com';
                        } else if (bank.contains('halk') || bank.contains('paraf')) {
                          fallbackUrl = 'https://www.parafcard.com.tr';
                        } else if (bank.contains('ziraat') || bank.contains('bankkart')) {
                          fallbackUrl = 'https://www.bankkart.com.tr';
                        }
                        uri = Uri.tryParse(fallbackUrl);
                      }

                      if (uri != null) {
                        try {
                          final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
                          if (!launched) {
                            throw Exception('Could not launch');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sayfa açılamadı: $uri'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('KAMPANYAYA YÖNLENDİR'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Text('KAPAT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionDetailItem(IconData icon, String title, String description) {
    final rawSentences = description.split(RegExp(r'\.(?=\s|$)'));
    final sentences = rawSentences
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                ...sentences.map((sentence) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$sentence.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              height: 1.45,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRankerTab() {
    final recommendations = CampaignDecisionEngine.getRecommendations(
      brand: _selectedAdvisorBrand,
      userCards: _userCards,
      activeCampaigns: _globalCampaigns,
    );

    return SingleChildScrollView(
      controller: _rankerScrollController,
      key: const PageStorageKey<String>('card_ranker_tab_scroll'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Akaryakıt İstasyonuna Göre En Karlı Kartınız',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Yakıt alacağınız istasyon markasını seçin. Cüzdanınızdaki kartlar o istasyon için kazandıracağı toplam ödüle göre sıralanacaktır.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Marka Seçici Butonlar (Yatay Kaydırılabilir ve Premium)
          CompactBrandFilterBar(
            selectedBrand: _selectedAdvisorBrand,
            onBrandSelected: (brand) {
              setState(() {
                _selectedAdvisorBrand = brand;
              });
            },
            showAllOption: false,
          ),
          const SizedBox(height: 20),
          // Sonuçlar listesi
          if (_userCards.isEmpty)
            _buildNoCardsAdvice()
          else if (recommendations.isEmpty)
            _buildNoCampaignsAdvice()
          else
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              final depthLayer = (index % 3) + 1;

              Color brandColor = AppTheme.textSecondary;
              final brandStr = rec.campaign?.stationBrand ?? _selectedAdvisorBrand;
              if (brandStr.toLowerCase() == 'shell') {
                brandColor = const Color(0xFFE30613);
              } else if (brandStr.toLowerCase() == 'opet') {
                brandColor = const Color(0xFF005CA9);
              } else if (brandStr.toLowerCase() == 'bp') {
                brandColor = const Color(0xFF00A550);
              } else if (brandStr.toLowerCase() == 'petrol ofisi') {
                brandColor = const Color(0xFFC00000);
              }

              // Check if the recommendation corresponds to a global campaign that the user has already joined
              final activeUserCampaign = rec.campaign != null
                  ? (_activeUserCampaigns.any((c) => c.campaignId == rec.campaign!.campaignId)
                      ? _activeUserCampaigns.firstWhere((c) => c.campaignId == rec.campaign!.campaignId)
                      : null)
                  : null;

              return ParallaxScrollWrapper(
                depthLayer: depthLayer,
                scrollController: _rankerScrollController,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FloatingOscillator(
                    depthLayer: depthLayer,
                    baseFrequency: 1.0,
                    child: GlassmorphicCampaignCard(
                      bankName: '${rec.bankName} ${rec.cardProgram}',
                      rewardAmount: rec.rewardAmount,
                      minTxAmount: rec.minTxAmount,
                      targetTxCount: rec.targetTxCount,
                      daysLeft: rec.campaign != null
                          ? rec.campaign!.expiryDate.difference(DateTime.now()).inDays
                          : 30,
                      isUrgent: false,
                      depthLayer: depthLayer,
                      stationBrand: brandStr,
                      brandLogoWidget: _buildBrandLogo(brandStr, brandColor, height: 24),
                      activeProgressWidget: null,
                      imageUrl: rec.campaign != null ? _getCampaignImage(rec.campaign!.campaignId, brandStr) : null,
                      actionWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (rec.campaign != null) ...[
                            if (activeUserCampaign == null) ...[
                              ElevatedButton(
                                onPressed: () => _joinCampaign(rec.campaign!),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  backgroundColor: AppTheme.primaryTeal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('KAMPANYAYA KATIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ] else ...[
                              InkWell(
                                onTap: () => _leaveCampaign(rec.campaign!.campaignId, rec.bankName),
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'TAKİP EDİLİYOR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            TextButton.icon(
                              onPressed: () => _showCampaignDetailBottomSheet(rec.campaign!, brandColor),
                              icon: const Icon(Icons.info_outline_rounded, size: 14),
                              label: const Text('DETAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ] else ...[
                            const Text(
                              'Cüzdan Kart Avantajı',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
   }

   Widget _buildNoCardsAdvice() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 40),
         child: Column(
           children: [
             const Icon(Icons.credit_card_off_rounded, color: AppTheme.textSecondary, size: 48),
             const SizedBox(height: 12),
             const Text(
               'Cüzdanınız Boş',
               style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
             ),
             const SizedBox(height: 6),
             const Text(
               'Tavsiye alabilmek için "CÜZDANIM" sekmesinden kartlarınızı seçin.',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
             ),
             const SizedBox(height: 16),
             ElevatedButton(
               onPressed: () => _tabController.animateTo(0),
               child: const Text('Cüzdanımı Düzenle'),
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildNoCampaignsAdvice() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 40),
         child: Column(
           children: [
             const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 48),
             const SizedBox(height: 12),
             Text(
               '$_selectedAdvisorBrand için Kampanya Yok',
               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
             ),
             const SizedBox(height: 6),
             const Text(
               'Cüzdanınızdaki kartlara ait aktif bir kampanya bulunmamaktadır.',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
             ),
           ],
         ),
       ),
     );
   }
}

// ==========================================
// PREMIUM ANTIGRAVITY UI SUPPORTING WIDGETS
// ==========================================

class AntigravityBackground extends StatelessWidget {
  final Widget child;
  const AntigravityBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid light background
        Container(color: AppTheme.lightBg),
        // Ambient static colored glow blobs
        Stack(
          children: [
            // Blob 1: Cyan/Teal glow on top-left
            Positioned(
              top: 80,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryTeal.withOpacity(0.12),
                      AppTheme.primaryTeal.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Blob 2: Orange glow on bottom-right
            Positioned(
              bottom: 120,
              right: -90,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentOrange.withOpacity(0.11),
                      AppTheme.accentOrange.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Blob 3: Pastel Teal in middle
            Positioned(
              top: 380,
              right: 40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryTeal.withOpacity(0.09),
                      AppTheme.primaryTeal.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Soften the blobs to look like standard canvas mesh gradients
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        // Content Canvas
        Positioned.fill(child: child),
      ],
    );
  }
}

class GlassmorphicBorderPainter extends CustomPainter {
  final double radius;
  final List<Color> colors;

  GlassmorphicBorderPainter({required this.radius, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        colors,
      );
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlassmorphicBorderPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.colors != colors;
  }
}

class FloatingOscillator extends StatelessWidget {
  final Widget child;
  const FloatingOscillator({
    super.key,
    required this.child,
    required int depthLayer,
    required double baseFrequency,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ParallaxScrollWrapper extends StatelessWidget {
  final Widget child;
  const ParallaxScrollWrapper({
    super.key,
    required this.child,
    required int depthLayer,
    required ScrollController scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class PulseNeonWrapper extends StatelessWidget {
  final Widget child;
  final Color neonColor;
  final bool isPulsing;

  const PulseNeonWrapper({
    super.key,
    required this.child,
    required this.neonColor,
    this.isPulsing = true,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class TouchScaleGlowWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TouchScaleGlowWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<TouchScaleGlowWrapper> createState() => _TouchScaleGlowWrapperState();
}

class _TouchScaleGlowWrapperState extends State<TouchScaleGlowWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

class NeonProgressBar extends StatelessWidget {
  final int current;
  final int target;
  final Color neonColor;

  const NeonProgressBar({
    super.key,
    required this.current,
    required this.target,
    required this.neonColor,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'İlerleme Takibi',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '$current / $target İşlem',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: neonColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.borderLight.withOpacity(0.5), width: 1),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        neonColor.withOpacity(0.8),
                        neonColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonColor.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompactBrandFilterBar extends StatelessWidget {
  final String selectedBrand;
  final Function(String) onBrandSelected;
  final bool showAllOption;

  const CompactBrandFilterBar({
    super.key,
    required this.selectedBrand,
    required this.onBrandSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> rawBrands = ['HEPSİ', 'Shell', 'Opet', 'Petrol Ofisi', 'Aytemiz', 'Total', 'Diğer'];
    final List<String> brands = showAllOption ? rawBrands : rawBrands.sublist(1);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: brands.map((brand) {
          final isSelected = selectedBrand.toLowerCase() == brand.toLowerCase() || 
                             (selectedBrand == 'GENEL' && brand == 'HEPSİ') ||
                             (selectedBrand == 'HEPSİ' && brand == 'HEPSİ');
          
          final cleanBrand = brand.toLowerCase();
          String? logoPath;
          if (cleanBrand == 'shell') logoPath = 'assets/images/shell.png';
          else if (cleanBrand == 'opet') logoPath = 'assets/images/opet.png';
          else if (cleanBrand == 'petrol ofisi') logoPath = 'assets/images/petrol_ofisi.png';
          else if (cleanBrand == 'aytemiz') logoPath = 'assets/images/aytemiz.png';
          else if (cleanBrand == 'total') logoPath = 'assets/images/total.png';

          Color activeColor = AppTheme.primaryTeal;
          if (cleanBrand == 'shell') activeColor = const Color(0xFFE30613);
          else if (cleanBrand == 'opet') activeColor = const Color(0xFF005CA9);
          else if (cleanBrand == 'petrol ofisi') activeColor = const Color(0xFFC00000);

          return GestureDetector(
            onTap: () => onBrandSelected(brand == 'HEPSİ' ? 'HEPSİ' : brand),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? activeColor.withOpacity(0.12)
                    : Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? activeColor.withOpacity(0.8)
                      : AppTheme.borderLight.withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: -1,
                  )
                ] : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (logoPath != null) ...[
                    Image.asset(
                      logoPath,
                      height: 18,
                      width: 18,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_gas_station_rounded, size: 14),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (brand == 'HEPSİ') ...[
                    Icon(
                      Icons.apps_rounded, 
                      size: 14, 
                      color: isSelected ? activeColor : AppTheme.textPrimary
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (brand == 'Diğer') ...[
                    Icon(
                      Icons.more_horiz_rounded, 
                      size: 14, 
                      color: isSelected ? activeColor : AppTheme.textPrimary
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      color: isSelected ? activeColor : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class GlassmorphicCampaignCard extends StatelessWidget {
  final String bankName;
  final double rewardAmount;
  final double minTxAmount;
  final int targetTxCount;
  final int daysLeft;
  final bool isUrgent;
  final int depthLayer;
  final String stationBrand;
  final Widget brandLogoWidget;
  final Widget? activeProgressWidget;
  final Widget actionWidget;
  final String? imageUrl;

  const GlassmorphicCampaignCard({
    super.key,
    required this.bankName,
    required this.rewardAmount,
    required this.minTxAmount,
    required this.targetTxCount,
    required this.daysLeft,
    required this.isUrgent,
    required this.depthLayer,
    required this.stationBrand,
    required this.brandLogoWidget,
    this.activeProgressWidget,
    required this.actionWidget,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color neonColor = AppTheme.primaryTeal;
    final cleanBrand = stationBrand.toLowerCase();
    if (cleanBrand.contains('shell')) {
      neonColor = const Color(0xFFEA580C);
    } else if (cleanBrand.contains('opet')) {
      neonColor = const Color(0xFF005CA9);
    } else if (cleanBrand.contains('petrol ofisi')) {
      neonColor = const Color(0xFFDC2626);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: Colors.white.withOpacity(0.65),
            child: CustomPaint(
              painter: GlassmorphicBorderPainter(
                radius: 16,
                colors: [
                  AppTheme.primaryTeal.withOpacity(0.8),
                  AppTheme.accentOrange.withOpacity(0.8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover Image Section
                  if (imageUrl != null)
                    Stack(
                      children: [
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.withOpacity(0.1),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      neonColor.withOpacity(0.8),
                                      neonColor.withOpacity(0.4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Overlay Gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.35),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Brand Logo overlay at top-right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: brandLogoWidget,
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            neonColor.withOpacity(0.6),
                            neonColor.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 12,
                            child: brandLogoWidget,
                          ),
                        ],
                      ),
                    ),

                  // Text & Actions padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          bankName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PulseNeonWrapper(
                                  neonColor: neonColor,
                                  isPulsing: true,
                                  child: Text(
                                    '${rewardAmount.toStringAsFixed(0)} TL Ödül',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$targetTxCount x ${minTxAmount.toStringAsFixed(0)} TL Harcama Şartı',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isUrgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '⏳ ACİL',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Text(
                                  daysLeft < 0 ? 'Süresi Doldu' : 'Son $daysLeft Gün',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isUrgent ? AppTheme.errorRed : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (activeProgressWidget != null) ...[
                          const SizedBox(height: 10),
                          activeProgressWidget!,
                        ],
                        const SizedBox(height: 10),
                        const Divider(color: AppTheme.borderLight, height: 1),
                        const SizedBox(height: 8),
                        actionWidget,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
