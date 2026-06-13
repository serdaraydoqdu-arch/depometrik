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
  bool _isLoading = true;
  
  // Tavsiye motoru için seçili marka
  String _selectedAdvisorBrand = 'Shell';

  // Cüzdanda seçilebilecek kart programı şablonları
  final List<Map<String, dynamic>> _cardPresets = [
    {
      'bankName': 'Garanti BBVA',
      'cardProgram': 'Bonus',
      'color': const Color(0xFF00A859), // Bonus Yeşili
      'textColor': Colors.white,
      'slogan': 'Bol Bol Bonus Kazandırır',
    },
    {
      'bankName': 'Yapı Kredi',
      'cardProgram': 'World',
      'color': const Color(0xFF5A1C7D), // World Moru
      'textColor': Colors.white,
      'slogan': 'Dünya Kadar Ayrıcalık',
    },
    {
      'bankName': 'İş Bankası',
      'cardProgram': 'Maximum',
      'color': const Color(0xFFE50050), // Maximum Pembemsi Kırmızı
      'textColor': Colors.white,
      'slogan': 'Maksimum Hayat, Maksimum Kart',
    },
    {
      'bankName': 'Akbank',
      'cardProgram': 'Axess',
      'color': const Color(0xFFFFCC00), // Axess Sarısı
      'textColor': const Color(0xFF1E293B),
      'slogan': 'Kazandıran Kart Axess',
    },
    {
      'bankName': 'QNB Finansbank',
      'cardProgram': 'CardFinans',
      'color': const Color(0xFF0A2F64), // Finans Lacivert
      'textColor': Colors.white,
      'slogan': 'Finansal Yol Arkadaşınız',
    },
    {
      'bankName': 'Halkbank',
      'cardProgram': 'Paraf',
      'color': const Color(0xFF00A2E8), // Paraf Açık Mavi
      'textColor': Colors.white,
      'slogan': 'Ayrıcalıklar Paraf\'ta',
    },
    {
      'bankName': 'Ziraat Bankası',
      'cardProgram': 'Bankkart',
      'color': const Color(0xFFED1C24), // Ziraat Kırmızısı
      'textColor': Colors.white,
      'slogan': 'Ziraat\'ten Bir Başka Kart',
    },
  ];

  String get _currentUserId {
    return Supabase.instance.client.auth.currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData(showSpinner: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showSpinner = false}) async {
    if (showSpinner) {
      setState(() => _isLoading = true);
    }
    try {
      final userCards = await _db.getUserCards(_currentUserId);
      
      // Kampanyaları çekelim. Veritabanı boşsa örnek veri tohumlayalım.
      var campaigns = await _db.getActiveGlobalCampaigns();
      if (campaigns.isEmpty) {
        await _seedMockCampaigns();
        campaigns = await _db.getActiveGlobalCampaigns();
      }

      setState(() {
        _userCards = userCards;
        _globalCampaigns = campaigns;
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
            Tab(icon: Icon(Icons.local_gas_station_rounded), text: 'KART SEÇİCİ'),
            Tab(icon: Icon(Icons.wallet_rounded), text: 'CÜZDANIM'),
            Tab(icon: Icon(Icons.campaign_rounded), text: 'KEŞFET'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCardRankerTab(),
                _buildWalletTab(),
                _buildDiscoverTab(),
              ],
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
                    color: isSelected ? preset['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.borderLight,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (preset['color'] as Color).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: AppTheme.textPrimary.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Row(
                    children: [
                      // Chip & Card Design
                      Expanded(
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? preset['textColor'] : AppTheme.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
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
                                    color: isSelected ? preset['textColor'].withValues(alpha: 0.8) : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
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
                  _tabController.animateTo(1); // Cüzdanım sekmesine yönlendirir (index 1)
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
    final filteredCampaigns = _globalCampaigns.where((campaign) {
      return _userCards.any((card) =>
          card.bankName.toLowerCase() == campaign.bankName.toLowerCase() ||
          campaign.bankName.toLowerCase().contains(card.bankName.toLowerCase()));
    }).toList();

    if (filteredCampaigns.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Cüzdanınızdaki kartlara ait bu ay akaryakıt kampanyası bulunamadı.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('discover_tab_scroll'),
      padding: const EdgeInsets.all(20),
      itemCount: filteredCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = filteredCampaigns[index];
        final daysLeft = campaign.expiryDate.difference(DateTime.now()).inDays;
        final isUrgent = daysLeft >= 0 && daysLeft <= 3;

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

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showCampaignDetailBottomSheet(campaign, brandColor),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Banka & Kart Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          campaign.bankName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                      // İstasyon Rozeti
                      _buildBrandLogo(campaign.stationBrand, brandColor, height: 36),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${campaign.rewardAmount.toStringAsFixed(0)} TL Ödül',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${campaign.targetTxCount} x ${campaign.minTxAmount.toStringAsFixed(0)} TL Harcama Şartı',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Kalan Gün / Aciliyet Etiketi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SÜRE BİTİYOR! ⏳',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Text(
                            daysLeft < 0 ? 'Süresi Doldu' : 'Son $daysLeft Gün',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUrgent ? AppTheme.errorRed : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          padding: const EdgeInsets.all(24),
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
                      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
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

  Widget _buildCardRankerTab() {
    final recommendations = CampaignDecisionEngine.getRecommendations(
      brand: _selectedAdvisorBrand,
      userCards: _userCards,
      activeCampaigns: _globalCampaigns,
    );

    return SingleChildScrollView(
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
          const SizedBox(height: 20),
          // Marka Seçici Butonlar (Yatay Kaydırılabilir ve Premium)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['Shell', 'Opet', 'Petrol Ofisi', 'Aytemiz', 'Total', 'Diğer'].map((brand) {
                final isSelected = _selectedAdvisorBrand == brand;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      brand,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryTeal,
                    backgroundColor: AppTheme.lightBg,
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedAdvisorBrand = brand;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Sonuçlar listesi
          if (_userCards.isEmpty)
            _buildNoCardsAdvice()
          else if (recommendations.isEmpty)
            _buildNoCampaignsAdvice()
          else
            ...recommendations.map((rec) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rec.bankName} ${rec.cardProgram}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                         ),
                         const SizedBox(height: 6),
                         Text(
                           '${rec.targetTxCount} x ${rec.minTxAmount.toStringAsFixed(0)} TL harcama şartı',
                           style: const TextStyle(
                             fontSize: 12,
                             color: AppTheme.textSecondary,
                           ),
                         ),
                       ],
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(
                         color: AppTheme.accentOrange.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(10),
                       ),
                       child: Text(
                         '+${rec.rewardAmount.toStringAsFixed(0)} TL',
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w900,
                           color: AppTheme.accentOrange,
                         ),
                       ),
                     ),
                   ],
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
               onPressed: () => _tabController.animateTo(1),
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
