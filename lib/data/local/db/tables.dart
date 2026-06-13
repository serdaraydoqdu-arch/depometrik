import 'package:drift/drift.dart';

// 1. PROFILES TABLOSU
class Profiles extends Table {
  TextColumn get userId => text().named('id')();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable().withDefault(currentDateAndTime)();
  BoolColumn get premiumStatus => boolean().nullable().withDefault(const Constant(false))();
  BoolColumn get acceptedAllStatementTerms => boolean().nullable().withDefault(const Constant(false))();
  BoolColumn get openBankingConnected => boolean().nullable().withDefault(const Constant(false))();
  TextColumn get subscriptionStatus => text().nullable()();
  TextColumn get fullName => text().nullable()();
  TextColumn get tckn => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

// 2. VEHICLES TABLOSU
class Vehicles extends Table {
  TextColumn get vehicleId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get plate => text().withLength(min: 2, max: 15)();
  TextColumn get brand => text().withLength(min: 1, max: 50)();
  TextColumn get model => text().withLength(min: 1, max: 50)();
  TextColumn get fuelType => text()(); // BENZIN, DIZEL, LPG, ELEKTRIK
  IntColumn get initialOdometer => integer().customConstraint('NOT NULL CHECK (initial_odometer >= 0)')();
  IntColumn get currentOdometer => integer().customConstraint('NOT NULL CHECK (current_odometer >= 0)')();

  @override
  Set<Column> get primaryKey => {vehicleId};
}

// 3. STATIONS TABLOSU
class Stations extends Table {
  TextColumn get stationId => text().named('id')();
  TextColumn get brandName => text().withLength(min: 1, max: 100)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get city => text().withLength(min: 1, max: 50)();
  TextColumn get district => text().withLength(min: 1, max: 50)();

  @override
  Set<Column> get primaryKey => {stationId};
}

// 4. REFUELINGS TABLOSU
class Refuelings extends Table {
  TextColumn get refuelingId => text().named('id')();
  TextColumn get vehicleId => text()();
  TextColumn get stationId => text().nullable()();
  RealColumn get liters => real().customConstraint('NOT NULL CHECK (liters > 0)')();
  RealColumn get unitPrice => real().customConstraint('NOT NULL CHECK (unit_price > 0)')();
  RealColumn get totalPrice => real().customConstraint('NOT NULL CHECK (total_price > 0)')();
  IntColumn get odometer => integer().customConstraint('NOT NULL CHECK (odometer >= 0)')();
  DateTimeColumn get purchaseDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFullTank => boolean().withDefault(const Constant(true))();
  TextColumn get imagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {refuelingId};
}

// 5. CARD_TRANSACTIONS TABLOSU
class CardTransactions extends Table {
  TextColumn get transactionId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get refuelingId => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  RealColumn get amount => real().customConstraint('NOT NULL CHECK (amount > 0)')();
  TextColumn get merchantName => text().withLength(min: 1, max: 150)();
  TextColumn get source => text()(); // PDF, SMS, API
  TextColumn get cardNumberMask => text().nullable()();
  TextColumn get bankTransactionCode => text().nullable()();
  TextColumn get posTerminalDetails => text().nullable()();
  BoolColumn get scheduledPayment => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {transactionId};
}

// 6. CAMPAIGNS TABLOSU
class Campaigns extends Table {
  TextColumn get campaignId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get bankName => text().withLength(min: 1, max: 100)();
  TextColumn get stationBrand => text().withLength(min: 1, max: 100)();
  IntColumn get targetTxCount => integer().customConstraint('NOT NULL CHECK (target_tx_count > 0)')();
  IntColumn get currentTxCount => integer().withDefault(const Constant(0))();
  RealColumn get rewardAmount => real().customConstraint('NOT NULL CHECK (reward_amount > 0)')();
  DateTimeColumn get expiryDate => dateTime()();

  @override
  Set<Column> get primaryKey => {campaignId};
}

// 7. OBD_READINGS TABLOSU
class ObdReadings extends Table {
  TextColumn get readingId => text().named('id')();
  TextColumn get vehicleId => text()();
  IntColumn get odometerValue => integer().customConstraint('NOT NULL CHECK (odometer_value >= 0)')();
  RealColumn get fuelLevelRatio => real().customConstraint('NOT NULL CHECK (fuel_level_ratio >= 0.0 AND fuel_level_ratio <= 1.0)')();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {readingId};
}

// 8. FUEL_PRICES TABLOSU (Çevrimdışı Tarihsel Fiyat Arşivi)
class FuelPrices extends Table {
  TextColumn get provinceCode => text().withLength(min: 2, max: 50)(); // İl kodu/adı (örn: ISTANBUL, ANKARA, IZMIR)
  TextColumn get fuelType => text().withLength(min: 2, max: 20)();     // BENZIN, MAZOT, LPG
  DateTimeColumn get priceDate => dateTime()();                         // Gün bazlı tarih
  RealColumn get price => real().customConstraint('NOT NULL CHECK (price > 0)')(); // Litre birim fiyatı

  @override
  Set<Column> get primaryKey => {provinceCode, fuelType, priceDate};

  @override
  bool get withoutRowId => true; // WITHOUT ROWID optimizasyonu
}

// 9. STATEMENT_UPLOADS TABLOSU
class StatementUploads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().withLength(min: 1, max: 255)();
  DateTimeColumn get uploadDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get acceptedAllTerms => boolean().withDefault(const Constant(false))();
}

// 10. DESTRUCTIVE_OFFLINE_QUEUE TABLOSU (Çevrimdışı yıkıcı işlemleri loglamak için)
class DestructiveOfflineQueue extends Table {
  TextColumn get queueId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get entityType => text()(); // e.g. refuelings, vehicles
  TextColumn get entityId => text()();
  TextColumn get actionType => text()(); // DELETE, UPDATE_CRITICAL
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {queueId};
}

// 11. ATTACHMENT_QUEUE TABLOSU (Çevrimdışı PDF/fotoğrafların send-and-forget yapısıyla sunucuya yüklenmesi)
class AttachmentQueue extends Table {
  TextColumn get attachmentId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get filePath => text()();
  TextColumn get remoteStoragePath => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, UPLOADING, SUCCESS, FAILED
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {attachmentId};
}

// 12. GLOBAL_CAMPAIGNS TABLOSU (Tüm Aktif Banka Kampanyaları)
class GlobalCampaigns extends Table {
  TextColumn get campaignId => text().named('id')();
  TextColumn get bankName => text().withLength(min: 1, max: 100)();
  TextColumn get stationBrand => text().withLength(min: 1, max: 100)();
  IntColumn get targetTxCount => integer().customConstraint('NOT NULL CHECK (target_tx_count > 0)')();
  RealColumn get minTxAmount => real().customConstraint('NOT NULL CHECK (min_tx_amount >= 0)')();
  RealColumn get rewardAmount => real().customConstraint('NOT NULL CHECK (reward_amount > 0)')();
  BoolColumn get isDifferentDaysRequired => boolean().withDefault(const Constant(true))();
  DateTimeColumn get expiryDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {campaignId};
}

// 13. USER_CARDS TABLOSU (Kullanıcının Cüzdanındaki Kredi Kartı Programları)
class UserCards extends Table {
  TextColumn get cardId => text().named('id')();
  TextColumn get userId => text()();
  TextColumn get bankName => text().withLength(min: 1, max: 100)(); // örn: Garanti BBVA, Yapı Kredi
  TextColumn get cardProgram => text().withLength(min: 1, max: 100)(); // örn: Bonus, World, Maximum, Axess

  @override
  Set<Column> get primaryKey => {cardId};
}

