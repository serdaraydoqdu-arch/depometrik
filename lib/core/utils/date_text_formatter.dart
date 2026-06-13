import 'package:flutter/services.dart';

/// GG/AA/YYYY formatında klavye girişini düzenleyen formatlayıcı
class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Rakam dışındaki karakterleri temizle
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Maksimum 8 rakam (GG/AA/YYYY -> 8 rakam)
    if (cleanText.length > 8) {
      return oldValue;
    }

    String result = '';
    if (cleanText.isNotEmpty) {
      result += cleanText.substring(0, cleanText.length > 2 ? 2 : cleanText.length);
    }
    if (cleanText.length > 2) {
      result += '/' + cleanText.substring(2, cleanText.length > 4 ? 4 : cleanText.length);
    }
    if (cleanText.length > 4) {
      result += '/' + cleanText.substring(4, cleanText.length > 8 ? 8 : cleanText.length);
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// GG/AA/YYYY formatındaki tarihi doğrular ve DateTime nesnesi olarak döner.
DateTime? parseDate(String val) {
  final parts = val.split('/');
  if (parts.length != 3) return null;
  
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  
  if (day == null || month == null || year == null) return null;
  if (year < 1900 || year > 2100) return null;
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > 31) return null;
  
  try {
    final date = DateTime(year, month, day);
    // Ay sonu gün taşması kontrolü (Örn: 30 Şubat veya 31 Nisan'ın bir sonraki aya taşmasını engeller)
    if (date.day == day && date.month == month && date.year == year) {
      return date;
    }
  } catch (_) {}
  return null;
}
