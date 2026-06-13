import '../../data/local/db/app_database.dart';

class CampaignRecommendation {
  final String bankName;
  final String cardProgram;
  final double rewardAmount;
  final double minTxAmount;
  final int targetTxCount;
  final bool isDifferentDaysRequired;
  final DateTime expiryDate;
  final GlobalCampaign? campaign;

  CampaignRecommendation({
    required this.bankName,
    required this.cardProgram,
    required this.rewardAmount,
    required this.minTxAmount,
    required this.targetTxCount,
    required this.isDifferentDaysRequired,
    required this.expiryDate,
    this.campaign,
  });
}

class CampaignDecisionEngine {
  /// Kullanıcının sahip olduğu kartlar ve aktif kampanyalara göre en karlı sıralamayı döndürür.
  static List<CampaignRecommendation> getRecommendations({
    required String brand,
    required List<UserCard> userCards,
    required List<GlobalCampaign> activeCampaigns,
  }) {
    final List<CampaignRecommendation> list = [];

    // 1. Markaya veya 'GENEL' ibaresine uygun olan ve kullanıcının cüzdanında kartı bulunan kampanyaları bul
    final brandUpper = brand.toUpperCase();
    final targetBrands = {brandUpper};
    if (brandUpper == 'DIĞER' || brandUpper == 'DIĞER' || brandUpper == 'GENEL') {
      targetBrands.addAll({'GENEL', 'DİĞER', 'DIĞER'});
    }
    final brandCampaigns = activeCampaigns.where((campaign) {
      final campaignBrand = campaign.stationBrand.toUpperCase();
      bool isBrandMatch = targetBrands.contains(campaignBrand);
      
      // LPG/Otogaz alt markalarını ana akaryakıt markaları altında birleştir
      if (!isBrandMatch) {
        if (brand.toUpperCase() == 'OPET' && (campaignBrand.contains('AYGAZ') || campaignBrand.contains('AYGAZOTOGAZ'))) {
          isBrandMatch = true;
        } else if (brand.toUpperCase() == 'PETROL OFISI' && (campaignBrand.contains('POGAZ') || campaignBrand.contains('PO GAZ') || campaignBrand.contains('PO-GAZ'))) {
          isBrandMatch = true;
        }
      }

      if (!isBrandMatch) return false;

      // Kullanıcının cüzdanında bu bankaya ait en az bir kart var mı?
      final hasCard = userCards.any((card) =>
          card.bankName.toUpperCase() == campaign.bankName.toUpperCase() ||
          // Kısmi veya gevşek marka eşleşmesi için (örn: Garanti vs Garanti BBVA)
          campaign.bankName.toUpperCase().contains(card.bankName.toUpperCase()) ||
          card.bankName.toUpperCase().contains(campaign.bankName.toUpperCase()));
      
      return hasCard;
    }).toList();

    for (final campaign in brandCampaigns) {
      // Kampanyaya uyan kullanıcının sahip olduğu ilk kartı belirle
      final matchingCard = userCards.firstWhere(
        (card) => card.bankName.toUpperCase() == campaign.bankName.toUpperCase() ||
            campaign.bankName.toUpperCase().contains(card.bankName.toUpperCase()) ||
            card.bankName.toUpperCase().contains(campaign.bankName.toUpperCase()),
        orElse: () => UserCard(cardId: '', userId: '', bankName: campaign.bankName, cardProgram: 'Kart'),
      );

      list.add(
        CampaignRecommendation(
          bankName: campaign.bankName,
          cardProgram: matchingCard.cardProgram,
          rewardAmount: campaign.rewardAmount,
          minTxAmount: campaign.minTxAmount,
          targetTxCount: campaign.targetTxCount,
          isDifferentDaysRequired: campaign.isDifferentDaysRequired,
          expiryDate: campaign.expiryDate,
          campaign: campaign,
        ),
      );
    }

    // 2. Sıralama Mantığı:
    //    - Öncelikli olarak en yüksek ödül tutarı (rewardAmount) veren öne geçer (Azalan).
    //    - Ödüller eşit ise, kazanması daha kolay olan (yani minimum harcama tutarı minTxAmount daha düşük olan) öne geçer (Artan).
    list.sort((a, b) {
      final rewardCompare = b.rewardAmount.compareTo(a.rewardAmount);
      if (rewardCompare != 0) return rewardCompare;
      return a.minTxAmount.compareTo(b.minTxAmount);
    });

    return list;
  }
}
