import 'package:drift/drift.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Profiles,
  Vehicles,
  Stations,
  Refuelings,
  CardTransactions,
  Campaigns,
  ObdReadings,
  FuelPrices,
  StatementUploads,
  DestructiveOfflineQueue,
  AttachmentQueue,
  GlobalCampaigns,
  UserCards,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor connection) : super(connection);
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(fuelPrices);
          }
          if (from < 3) {
            await m.addColumn(refuelings, refuelings.imagePath);
          }
          if (from < 4) {
            await m.addColumn(profiles, profiles.acceptedAllStatementTerms);
          }
          if (from < 5) {
            await m.createTable(statementUploads);
          }
          if (from < 6) {
            await m.addColumn(profiles, profiles.openBankingConnected);
            await m.addColumn(profiles, profiles.subscriptionStatus);
            await m.addColumn(cardTransactions, cardTransactions.cardNumberMask);
            await m.addColumn(cardTransactions, cardTransactions.bankTransactionCode);
            await m.addColumn(cardTransactions, cardTransactions.posTerminalDetails);
            await m.addColumn(cardTransactions, cardTransactions.scheduledPayment);
            await m.createTable(destructiveOfflineQueue);
            await m.createTable(attachmentQueue);
          }
          if (from < 7) {
            await m.createTable(globalCampaigns);
            await m.createTable(userCards);
          }
          if (from < 8) {
            await m.addColumn(campaigns, campaigns.campaignUrl);
          }
          if (from < 9) {
            // PowerSync-replicated tables (like global_campaigns) are views in SQLite.
            // PowerSync's schema engine handles updating them automatically based on the powersync_service schema.
            // We do NOT run Drift ALTER TABLE migrations on them.
          }
        },
        beforeOpen: (details) async {
          // Yabancı anahtarların SQLite düzeyinde aktif edilmesi
          await customStatement('PRAGMA foreign_keys = ON');

          // Eski/yanlış formülle tohumlanmış düşük fiyatları tespit edip temizleme
          final samplePrice = await getFuelPrice('ISTANBUL', 'MAZOT', DateTime(2026, 5, 24));
          if (samplePrice != null && samplePrice < 50.0) {
            await delete(fuelPrices).go();
          }

          await _seedFuelPricesIfNeeded();
        },
      );

  Future<void> _seedFuelPricesIfNeeded() async {
    final countQuery = select(fuelPrices);
    final existingCount = (await countQuery.get()).length;
    if (existingCount > 10000) return;

    final List<String> cities = ['ISTANBUL', 'ANKARA', 'IZMIR'];
    final List<String> fuelTypes = ['BENZIN', 'MAZOT', 'LPG'];
    
    // 2023 başı gerçekçi pompa fiyatı taban değerleri
    final Map<String, List<double>> basePrices = {
      'ISTANBUL': [20.10, 22.20, 10.50],
      'ANKARA': [20.70, 22.80, 10.90],
      'IZMIR': [20.90, 23.00, 10.80],
    };

    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2026, 6, 30);
    
    await batch((batch) {
      for (final city in cities) {
        final bases = basePrices[city]!;
        for (int typeIndex = 0; typeIndex < fuelTypes.length; typeIndex++) {
          final fuelType = fuelTypes[typeIndex];
          final basePrice = bases[typeIndex];

          DateTime currentDate = startDate;
          while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
            final daysDiff = currentDate.difference(startDate).inDays;
            
            // LPG daha yavaş artar, Benzin/Mazot daha hızlı artarak May 2026'da 60 TL bandına ulaşır
            final double trendRate = fuelType == 'LPG' ? 0.016 : 0.033;
            final double trend = daysDiff * trendRate;
            final double wave = 0.5 * (daysDiff / 10).round() % 3 == 0 
                ? 0.35 
                : (daysDiff / 15).round() % 2 == 0 ? -0.25 : 0.1;
            
            final price = double.parse((basePrice + trend + wave).toStringAsFixed(2));

            batch.insert(
              fuelPrices,
              FuelPricesCompanion.insert(
                provinceCode: city,
                fuelType: fuelType,
                priceDate: currentDate,
                price: price,
              ),
              mode: InsertMode.insertOrReplace,
            );

            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
    });
  }

  // --- REPOSITORIES / DATA OPERATIONS IN DRIFT ---

  // PROFILES OPERATIONS
  Future<int> insertProfile(ProfilesCompanion profile) => into(profiles).insert(profile, mode: InsertMode.insertOrReplace);
  Future<List<Profile>> getAllProfiles() => select(profiles).get();
  Future<Profile?> getProfileById(String userId) => (select(profiles)..where((t) => t.userId.equals(userId))).getSingleOrNull();
  Future<bool> updateProfile(Profile profile) => update(profiles).replace(profile);

  // VEHICLES OPERATIONS
  // VEHICLES OPERATIONS
  Future<int> insertVehicle(VehiclesCompanion vehicle) async {
    print('Drift DB: Inserting vehicle with plate: ${vehicle.plate.value}');
    final res = await into(vehicles).insert(vehicle);
    print('Drift DB: Insert vehicle result: $res');
    return res;
  }
  Future<List<Vehicle>> getVehiclesForUser(String userId) async {
    print('Drift DB: Querying vehicles for user: $userId');
    final list = await (select(vehicles)..where((t) => t.userId.equals(userId))).get();
    print('Drift DB: Found ${list.length} vehicles in local DB');
    for (var v in list) {
      print('Drift DB:   - Vehicle: ID=${v.vehicleId}, Plate=${v.plate}, UserID=${v.userId}');
    }
    return list;
  }
  Future<bool> updateVehicle(Vehicle vehicle) => update(vehicles).replace(vehicle);
  Future<int> deleteVehicle(String vehicleId) async {
    // Önce araca bağlı yakıt alımlarını ve OBD verilerini siliyoruz
    await (delete(refuelings)..where((t) => t.vehicleId.equals(vehicleId))).go();
    await (delete(obdReadings)..where((t) => t.vehicleId.equals(vehicleId))).go();
    // Son olarak aracın kendisini siliyoruz
    return (delete(vehicles)..where((t) => t.vehicleId.equals(vehicleId))).go();
  }
  Future<Vehicle?> getVehicleById(String vehicleId) => (select(vehicles)..where((t) => t.vehicleId.equals(vehicleId))).getSingleOrNull();

  // STATIONS OPERATIONS
  Future<int> insertStation(StationsCompanion station) => into(stations).insert(station);
  Future<List<Station>> getAllStations() => select(stations).get();

  // REFUELINGS OPERATIONS
  Future<int> insertRefueling(RefuelingsCompanion refueling) => into(refuelings).insert(refueling);
  Future<List<Refueling>> getRefuelingsForVehicle(String vehicleId) => 
      (select(refuelings)
        ..where((t) => t.vehicleId.equals(vehicleId))
        ..orderBy([(t) => OrderingTerm(expression: t.purchaseDate, mode: OrderingMode.desc)]))
      .get();
  Future<List<Refueling>> getRefuelingsForVehicleAsc(String vehicleId) => 
      (select(refuelings)
        ..where((t) => t.vehicleId.equals(vehicleId))
        ..orderBy([(t) => OrderingTerm(expression: t.odometer, mode: OrderingMode.asc)]))
      .get();
  Future<bool> updateRefueling(Refueling refueling) => update(refuelings).replace(refueling);
  Future<int> deleteRefueling(String refuelingId) => (delete(refuelings)..where((t) => t.refuelingId.equals(refuelingId))).go();

  // CARD TRANSACTIONS OPERATIONS
  Future<int> insertCardTransaction(CardTransactionsCompanion transaction) => into(cardTransactions).insert(transaction);
  Future<List<CardTransaction>> getCardTransactionsForUser(String userId) => (select(cardTransactions)..where((t) => t.userId.equals(userId))).get();
  Future<List<CardTransaction>> getUnapprovedCardTransactions(String userId) => 
      (select(cardTransactions)
        ..where((t) => t.userId.equals(userId) & t.refuelingId.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
      .get();
  Future<bool> updateCardTransaction(CardTransaction transaction) => update(cardTransactions).replace(transaction);
  Future<int> deleteCardTransaction(String transactionId) => (delete(cardTransactions)..where((t) => t.transactionId.equals(transactionId))).go();

  // CAMPAIGNS OPERATIONS
  Future<int> insertCampaign(CampaignsCompanion campaign) => into(campaigns).insert(campaign);
  Future<List<Campaign>> getCampaignsForUser(String userId) => (select(campaigns)..where((t) => t.userId.equals(userId))).get();

  // OBD READINGS OPERATIONS
  Future<int> insertObdReading(ObdReadingsCompanion reading) => into(obdReadings).insert(reading);
  Future<List<ObdReading>> getObdReadingsForVehicle(String vehicleId) => (select(obdReadings)..where((t) => t.vehicleId.equals(vehicleId))).get();

  // FUEL PRICES OPERATIONS
  Future<double?> getFuelPrice(String province, String fuelType, DateTime date) async {
    final cleanDate = DateTime(date.year, date.month, date.day);
    
    final query = select(fuelPrices)
      ..where((t) => t.provinceCode.equals(province) & t.fuelType.equals(fuelType) & t.priceDate.isSmallerOrEqualValue(cleanDate))
      ..orderBy([(t) => OrderingTerm(expression: t.priceDate, mode: OrderingMode.desc)])
      ..limit(1);
      
    final result = await query.getSingleOrNull();
    return result?.price;
  }

  // STATEMENT UPLOADS OPERATIONS
  Future<int> insertStatementUpload(StatementUploadsCompanion statement) => into(statementUploads).insert(statement);
  Future<List<StatementUpload>> getAllStatementUploads() => select(statementUploads).get();
  Future<bool> updateStatementUpload(StatementUpload statement) => update(statementUploads).replace(statement);
  Future<int> deleteStatementUpload(int id) => (delete(statementUploads)..where((t) => t.id.equals(id))).go();
  Future<StatementUpload?> getStatementUploadById(int id) => (select(statementUploads)..where((t) => t.id.equals(id))).getSingleOrNull();

  // DESTRUCTIVE OFFLINE QUEUE OPERATIONS
  Future<int> insertDestructiveOfflineQueue(DestructiveOfflineQueueCompanion item) => into(destructiveOfflineQueue).insert(item);
  Future<List<DestructiveOfflineQueueData>> getDestructiveQueueForUser(String userId) => (select(destructiveOfflineQueue)..where((t) => t.userId.equals(userId))).get();
  Future<int> deleteDestructiveQueueItem(String queueId) => (delete(destructiveOfflineQueue)..where((t) => t.queueId.equals(queueId))).go();

  // ATTACHMENT QUEUE OPERATIONS
  Future<int> insertAttachmentQueue(AttachmentQueueCompanion item) => into(attachmentQueue).insert(item);
  Future<List<AttachmentQueueData>> getPendingAttachments(String userId) => 
      (select(attachmentQueue)..where((t) => t.userId.equals(userId) & (t.status.equals('PENDING') | t.status.equals('FAILED')))).get();
  Future<bool> updateAttachmentQueue(AttachmentQueueData item) => update(attachmentQueue).replace(item);
  Future<int> deleteAttachmentQueueItem(String attachmentId) => (delete(attachmentQueue)..where((t) => t.attachmentId.equals(attachmentId))).go();

  // GLOBAL CAMPAIGNS OPERATIONS
  Future<int> insertGlobalCampaign(GlobalCampaignsCompanion item) => into(globalCampaigns).insert(item, mode: InsertMode.insertOrReplace);
  Future<List<GlobalCampaign>> getActiveGlobalCampaigns() => (select(globalCampaigns)..where((t) => t.isActive.equals(true) & t.expiryDate.isBiggerOrEqualValue(DateTime.now()))).get();
  Future<int> clearGlobalCampaigns() => delete(globalCampaigns).go();

  // USER CARDS OPERATIONS
  Future<int> insertUserCard(UserCardsCompanion card) => into(userCards).insert(card, mode: InsertMode.insertOrReplace);
  Future<List<UserCard>> getUserCards(String userId) => (select(userCards)..where((t) => t.userId.equals(userId))).get();
  Future<int> deleteUserCard(String cardId) => (delete(userCards)..where((t) => t.cardId.equals(cardId))).go();
}
