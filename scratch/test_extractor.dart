// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/parser/pdf_statement_parser.dart';

void main() {
  test('Statement text extraction and robust parsing check', () async {
    final file = File('E:/Depometrik/scratch/DOC-20260602-WA0021..pdf');
    if (!await file.exists()) {
      print('File not found!');
      return;
    }
    
    final parser = PdfStatementParser();
    final transactions = await parser.parseStatement(file);
    
    print('--- PARSED TRANSACTIONS COUNT: ${transactions.length} ---');
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      print('$i: Date: ${tx.date.day}/${tx.date.month}/${tx.date.year} | Merchant: ${tx.merchantName} | Amount: ${tx.amount} TL');
    }

    // Let's assert we found the main refueling transactions
    expect(transactions, isNotEmpty);
    
    // Verify we found the Shell transaction for 2,200.22 TL
    final shellTx = transactions.firstWhere((tx) => tx.merchantName.contains('SHELL') && tx.amount == 2200.22);
    expect(shellTx, isNotNull);
    expect(shellTx.date, equals(DateTime(2026, 5, 24)));

    // Verify we found the PO transaction for 55.00 TL
    final poTx = transactions.firstWhere((tx) => tx.merchantName.contains('PETROL OFISI') || tx.merchantName.contains('PETROL OFİSİ'));
    expect(poTx, isNotNull);
    expect(poTx.amount, equals(55.00));
    expect(poTx.date, equals(DateTime(2026, 5, 24)));
  });
}
