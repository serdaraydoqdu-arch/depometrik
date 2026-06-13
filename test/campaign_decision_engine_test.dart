import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/campaign/campaign_decision_engine.dart';
import 'package:depometrik/data/local/db/app_database.dart';

void main() {
  group('CampaignDecisionEngine Unit Tests', () {
    test('Should filter and rank campaigns correctly by reward amount (descending)', () {
      final userCards = [
        UserCard(cardId: '1', userId: 'user1', bankName: 'Garanti BBVA', cardProgram: 'Bonus'),
        UserCard(cardId: '2', userId: 'user1', bankName: 'Yapı Kredi', cardProgram: 'World'),
      ];

      final activeCampaigns = [
        GlobalCampaign(
          campaignId: 'c1',
          bankName: 'Garanti BBVA',
          stationBrand: 'Shell',
          targetTxCount: 4,
          minTxAmount: 600.0,
          rewardAmount: 150.0, // Higher reward
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
        GlobalCampaign(
          campaignId: 'c2',
          bankName: 'Yapı Kredi',
          stationBrand: 'Shell',
          targetTxCount: 3,
          minTxAmount: 500.0,
          rewardAmount: 100.0, // Lower reward
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
        GlobalCampaign(
          campaignId: 'c3',
          bankName: 'İş Bankası', // Card not in user's wallet
          stationBrand: 'Shell',
          targetTxCount: 4,
          minTxAmount: 500.0,
          rewardAmount: 200.0,
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
      ];

      final recs = CampaignDecisionEngine.getRecommendations(
        brand: 'Shell',
        userCards: userCards,
        activeCampaigns: activeCampaigns,
      );

      // Verify filtering: c3 should be excluded because user doesn't have İş Bankası card
      expect(recs.length, 2);

      // Verify sorting: c1 should be first because reward (150) > c2 reward (100)
      expect(recs[0].bankName, 'Garanti BBVA');
      expect(recs[0].rewardAmount, 150.0);
      
      expect(recs[1].bankName, 'Yapı Kredi');
      expect(recs[1].rewardAmount, 100.0);
    });

    test('Should break ties using minTxAmount (lower required spend goes first)', () {
      final userCards = [
        UserCard(cardId: '1', userId: 'user1', bankName: 'Garanti BBVA', cardProgram: 'Bonus'),
        UserCard(cardId: '2', userId: 'user1', bankName: 'Yapı Kredi', cardProgram: 'World'),
      ];

      final activeCampaigns = [
        GlobalCampaign(
          campaignId: 'c1',
          bankName: 'Garanti BBVA',
          stationBrand: 'Shell',
          targetTxCount: 4,
          minTxAmount: 600.0, // Higher spend limit
          rewardAmount: 150.0,
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
        GlobalCampaign(
          campaignId: 'c2',
          bankName: 'Yapı Kredi',
          stationBrand: 'Shell',
          targetTxCount: 3,
          minTxAmount: 400.0, // Lower spend limit (easier)
          rewardAmount: 150.0, // Same reward
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
      ];

      final recs = CampaignDecisionEngine.getRecommendations(
        brand: 'Shell',
        userCards: userCards,
        activeCampaigns: activeCampaigns,
      );

      expect(recs.length, 2);
      // c2 should rank higher because it has a lower minTxAmount (400 vs 600) for the same reward amount (150)
      expect(recs[0].bankName, 'Yapı Kredi');
      expect(recs[0].minTxAmount, 400.0);

      expect(recs[1].bankName, 'Garanti BBVA');
      expect(recs[1].minTxAmount, 600.0);
    });

    test('Should merge LPG sub-brands correctly (Aygaz -> Opet, Pogaz -> Petrol Ofisi)', () {
      final userCards = [
        UserCard(cardId: '1', userId: 'user1', bankName: 'Garanti BBVA', cardProgram: 'Bonus'),
        UserCard(cardId: '2', userId: 'user1', bankName: 'Yapı Kredi', cardProgram: 'World'),
      ];

      final activeCampaigns = [
        GlobalCampaign(
          campaignId: 'c1',
          bankName: 'Garanti BBVA',
          stationBrand: 'Aygaz', // Sub-brand of Opet
          targetTxCount: 4,
          minTxAmount: 500.0,
          rewardAmount: 120.0,
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
        GlobalCampaign(
          campaignId: 'c2',
          bankName: 'Yapı Kredi',
          stationBrand: 'PO Gaz', // Sub-brand of Petrol Ofisi
          targetTxCount: 3,
          minTxAmount: 400.0,
          rewardAmount: 100.0,
          isDifferentDaysRequired: true,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          isActive: true,
        ),
      ];

      final opetRecs = CampaignDecisionEngine.getRecommendations(
        brand: 'Opet',
        userCards: userCards,
        activeCampaigns: activeCampaigns,
      );

      final poRecs = CampaignDecisionEngine.getRecommendations(
        brand: 'Petrol Ofisi',
        userCards: userCards,
        activeCampaigns: activeCampaigns,
      );

      // Verify Opet matches Aygaz
      expect(opetRecs.length, 1);
      expect(opetRecs[0].campaign?.stationBrand, 'Aygaz');
      expect(opetRecs[0].rewardAmount, 120.0);

      // Verify Petrol Ofisi matches PO Gaz
      expect(poRecs.length, 1);
      expect(poRecs[0].campaign?.stationBrand, 'PO Gaz');
      expect(poRecs[0].rewardAmount, 100.0);
    });
  });
}
