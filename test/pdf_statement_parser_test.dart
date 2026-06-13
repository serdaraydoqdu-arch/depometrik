import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/parser/pdf_statement_parser.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  // Flutter binding initializes for unit tests
  WidgetsFlutterBinding.ensureInitialized();

  group('PdfStatementParser - Yerel ve KVKK Uyumlu Ekstre Ayrıştırma Testleri', () {
    late PdfStatementParser parser;
    late File testPdfFile;

    setUpAll(() async {
      parser = PdfStatementParser();
      
      // Test için gerçekçi verilerle geçici bir PDF dosyası oluşturuyoruz
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      
      final graphics = page.graphics;
      final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      
      // Akaryakıt ve akaryakıt dışı harcamaları karışık satırlar halinde yazalım
      graphics.drawString('12.05.2026 SHELL ANKARA SUBESI HARCAMA: 1.250,50 TL', font, bounds: const Rect.fromLTWH(0, 10, 400, 20));
      graphics.drawString('14.05.2026 LC WAIKIKI MAGACILIK GIYIM: 600,00 TL', font, bounds: const Rect.fromLTWH(0, 30, 400, 20));
      graphics.drawString('15.05.2026 OPET ISTANBUL OTOYOLU AKARYAKIT: 850,00 TL', font, bounds: const Rect.fromLTWH(0, 50, 400, 20));
      graphics.drawString('16.05.2026 HEPSIBURADA ONLINE SATIS: 450,00 TL', font, bounds: const Rect.fromLTWH(0, 70, 400, 20));
      graphics.drawString('18.05.2026 BP PETROLLERI GENEL HARCAMA: 1.100,00 TL', font, bounds: const Rect.fromLTWH(0, 90, 400, 20));

      final List<int> bytes = await document.save();
      document.dispose();
      
      testPdfFile = File('${Directory.systemTemp.path}/test_ekstre.pdf');
      await testPdfFile.writeAsBytes(bytes);
    });

    tearDownAll(() async {
      if (await testPdfFile.exists()) {
        await testPdfFile.delete();
      }
    });

    test('Akaryakit harcamalari basariyla suzulmeli, diger harcamalar elenmeli (KVKK Uyum)', () async {
      final transactions = await parser.parseStatement(testPdfFile);

      // Toplamda 3 akaryakıt (Shell, Opet, Bp) ve 2 diğer alışveriş var.
      // Sadece 3 adet akaryakıt işlemi kalmalı, LC Waikiki ve Hepsiburada silinmeli.
      expect(transactions, isNotNull);
      expect(transactions.length, equals(3));

      // 1. Shell harcaması kontrolü
      expect(transactions[0].merchantName, contains('SHELL'));
      expect(transactions[0].amount, equals(1250.50));

      // 2. Opet harcaması kontrolü
      expect(transactions[1].merchantName, contains('OPET'));
      expect(transactions[1].amount, equals(850.00));

      // 3. Bp harcaması kontrolü
      expect(transactions[2].merchantName, contains('BP'));
      expect(transactions[2].amount, equals(1100.00));
    });
  });
}
