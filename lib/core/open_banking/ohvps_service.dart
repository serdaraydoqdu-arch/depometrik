import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';

/// ÖHVPS 2.0 Banka Kart Hareketi Yapısı
class BankTransaction {
  final String transactionId;
  final String cardNumberMask;
  final String bankTransactionCode;
  final String merchantName;
  final double amount;
  final DateTime date;
  final String posTerminalDetails;
  final bool isScheduled;

  BankTransaction({
    required this.transactionId,
    required this.cardNumberMask,
    required this.bankTransactionCode,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.posTerminalDetails,
    this.isScheduled = false,
  });
}

/// TCMB / BKM GEÇİT Açık Bankacılık ve ÖHVPS 2.0 Entegrasyon Servisi
class OhvpsService {
  static final OhvpsService _instance = OhvpsService._internal();
  factory OhvpsService() => _instance;
  OhvpsService._internal();

  /// MTLS ve JWS (JSON Web Signature) imzalama katmanı simülasyonu
  /// Faz 3 standartlarına göre isteklerin saniyeler bazında imzalanıp gönderilmesi zorunludur.
  String _generateJwsSignature(Map<String, dynamic> payload) {
    // Gerçek entegrasyonda burada RS256 / ES256 özel anahtarı ile JWS üretilir.
    final header = base64Url.encode(utf8.encode(jsonEncode({"alg": "RS256", "typ": "JWT"})));
    final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
    const signature = "mock_jws_signature_value"; // MTLS/JWS sertifikasyon imzası
    return '$header.$body.$signature';
  }

  /// 6493 Sayılı Kanun (12-f) Kapsamında Hesaptan Hesaba Doğrudan Ödeme Başlatma Hizmeti (PIS)
  /// Bu servis aracı komisyonlarını baypas ederek doğrudan transfer başlatır.
  Future<bool> initiateDirectTransfer({
    required String senderIban,
    required String receiverIban,
    required double amount,
    required String description,
  }) async {
    final payload = {
      "senderIban": senderIban,
      "receiverIban": receiverIban,
      "amount": amount,
      "description": description,
      "timestamp": DateTime.now().toIso8601String(),
      "transactionId": const Uuid().v4(),
    };

    final jwsSignature = _generateJwsSignature(payload);
    
    // BKM GEÇİT API Ödeme Başlatma İsteği Gönderimi (Mock)
    print('ÖHVPS 2.0 12-f Ödeme Başlatıldı. JWS: $jwsSignature');
    
    // Transfer durumunun başarılı olduğunu dönelim (BKM GEÇİT simülasyonu)
    return true;
  }

  /// İleri Tarihli veya Düzenli Ödeme Emri (SaaS Abonelikleri veya Periyodik Fatura Tahsilatları)
  Future<bool> setupRecurringPayment({
    required String accountId,
    required double amount,
    required int dayOfMonth,
    required String receiverIban,
  }) async {
    final payload = {
      "accountId": accountId,
      "amount": amount,
      "dayOfMonth": dayOfMonth,
      "receiverIban": receiverIban,
      "type": "RECURRING_PAYMENT",
    };

    final jwsSignature = _generateJwsSignature(payload);
    print('ÖHVPS 2.0 İleri Tarihli / Düzenli Ödeme Emri Kaydedildi. JWS: $jwsSignature');
    return true;
  }

  /// BKM GEÇİT API üzerinden son kart/hesap hareketlerini sorgular (Mock Verilerle Simüle Edilmiştir)
  Future<List<BankTransaction>> fetchTransactionsFromApi(String userId) async {
    // Gerçek API'de MTLS sertifikasıyla banka sunucularına HTTP GET yapılır.
    await Future.delayed(const Duration(milliseconds: 600)); // Network simülasyonu
    
    return [
      BankTransaction(
        transactionId: const Uuid().v4(),
        cardNumberMask: '4355-****-****-1192',
        bankTransactionCode: 'TX-BKM-99812',
        merchantName: 'SHELL TR ISTANBUL',
        amount: 1850.50,
        date: DateTime.now().subtract(const Duration(hours: 4)),
        posTerminalDetails: 'POS-TERM-991A (KARTLI ODEME DAHIL)',
      ),
      BankTransaction(
        transactionId: const Uuid().v4(),
        cardNumberMask: '4355-****-****-1192',
        bankTransactionCode: 'TX-BKM-88123',
        merchantName: 'OPET ANKARA CANKAYA',
        amount: 2100.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        posTerminalDetails: 'POS-TERM-882B',
      ),
    ];
  }

  /// Gelen banka kartı harcama kayıtlarını yerel yakıt alımlarıyla otomatik eşleştirir
  Future<void> reconcileTransactions(String userId) async {
    // 1. Bankadan harcamaları çek
    final apiTransactions = await fetchTransactionsFromApi(userId);
    
    for (final apiTx in apiTransactions) {
      // 2. Local DB'de bu harcamaya uyan (tutar +/- 5 TL, tarih +/- 1 gün toleranslı) yakıt alımı var mı kontrol et
      final db = DbService().database;
      final refuelings = await db.getRefuelingsForVehicle(userId); // Not: local database araması
      
      Refueling? matchedRefueling;
      for (final ref in refuelings) {
        final double diffAmount = (ref.totalPrice - apiTx.amount).abs();
        final int diffDays = ref.purchaseDate.difference(apiTx.date).inDays.abs();

        if (diffAmount <= 5.0 && diffDays <= 1) {
          matchedRefueling = ref;
          break;
        }
      }

      // 3. Eşleşme varsa veya yoksa kart işlemini veritabanına kaydet
      final companion = CardTransactionsCompanion.insert(
        transactionId: apiTx.transactionId,
        userId: userId,
        refuelingId: Value(matchedRefueling?.refuelingId),
        transactionDate: apiTx.date,
        amount: apiTx.amount,
        merchantName: apiTx.merchantName,
        source: 'API',
        cardNumberMask: Value(apiTx.cardNumberMask),
        bankTransactionCode: Value(apiTx.bankTransactionCode),
        posTerminalDetails: Value(apiTx.posTerminalDetails),
        scheduledPayment: Value(apiTx.isScheduled),
      );

      await db.insertCardTransaction(companion);
    }
  }
}
