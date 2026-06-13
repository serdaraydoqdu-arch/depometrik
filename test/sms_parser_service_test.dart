import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/sms/sms_parser_service.dart';

void main() {
  group('SmsParserService - Turkish Bank Refueling Transaction Tests', () {
    late SmsParserService parser;

    setUp(() {
      parser = SmsParserService();
    });

    test('Garanti BBVA refueling spending SMS template parsing', () {
      const sms = 'Sayin serda..., sonu 1234 ile biten kartinizla SHELL istasyonundan 1.250,50 TL tutarinda harcama yapilmistir. B002';
      final result = parser.parseSms(sms);
      
      expect(result, isNotNull);
      expect(result!.merchantName, contains('SHELL'));
      expect(result.amount, equals(1250.50));
    });

    test('Akbank refueling spending SMS template parsing', () {
      const sms = '5678 nolu kartinizla OPET akaryakit istasyonundan 850,00 TL harcama yapildi. B001';
      final result = parser.parseSms(sms);

      expect(result, isNotNull);
      expect(result!.merchantName, contains('OPET'));
      expect(result.amount, equals(850.00));
    });

    test('Yapi Kredi / World spending SMS template parsing', () {
      const sms = 'Kartinizla BP PETROLLERİ firmasindan 1.100,00 TL tutarinda islem yapilmistir. B003';
      final result = parser.parseSms(sms);

      expect(result, isNotNull);
      expect(result!.merchantName, contains('BP'));
      expect(result.amount, equals(1100.00));
    });

    test('Is Bankasi refueling spending SMS template parsing', () {
      const sms = 'Kartinizla TOTAL ISTASYONLARI firmasindan 750,00 TL harcanmistir.';
      final result = parser.parseSms(sms);

      expect(result, isNotNull);
      expect(result!.merchantName, contains('TOTAL'));
      expect(result.amount, equals(750.00));
    });

    test('Non-refueling credit card transaction SMS should be ignored', () {
      const sms = 'Sayin serda..., sonu 1234 ile biten kartinizla Hepsiburada.com firmasindan 450,00 TL tutarinda harcama yapilmistir. B002';
      final result = parser.parseSms(sms);

      expect(result, isNull);
    });

    test('Generic non-transaction text SMS should be ignored', () {
      const sms = 'Sevgili musterimiz, yeni kampanyamiz ile her 500 TL harcamaniza 50 TL chip-para hediye! Detaylar mobil subede.';
      final result = parser.parseSms(sms);

      expect(result, isNull);
    });

    test('Transaction parsing with valid bank sender and operator code B002', () {
      const sms = 'Sayin serda..., sonu 1234 ile biten kartinizla SHELL istasyonundan 1.250,50 TL tutarinda harcama yapilmistir.';
      final result = parser.parseSms(sms, sender: 'B002');

      expect(result, isNotNull);
      expect(result!.amount, equals(1250.50));
    });

    test('Transaction parsing with direct fuel brand sender', () {
      const sms = 'SHELL istasyonundan 750 TL harcama yapilmistir.';
      final result = parser.parseSms(sms, sender: 'SHELL');

      expect(result, isNotNull);
      expect(result!.amount, equals(750.00));
    });

    test('Transaction parsing with phone number sender and financial keywords', () {
      const sms = 'Opet istasyonundan 850 TL harcama yapildi.';
      final result = parser.parseSms(sms, sender: '+905551234567');

      expect(result, isNotNull);
      expect(result!.amount, equals(850.00));
    });

    test('Spam SMS with phone number sender and non-financial content should be ignored', () {
      const sms = 'Merhaba nasilsin? Bugun bulusalim mi?';
      final result = parser.parseSms(sms, sender: '+905551234567');

      expect(result, isNull);
    });
  });
}
