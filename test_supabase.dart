import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://napqcopzozmipkuzmdee.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o',
  );

  print('--- Supabase Profiles Kontrol Paneli ---');
  try {
    final List<dynamic> res = await supabase
        .from('profiles')
        .select('user_id, email, full_name, phone_number, premium_status');
    
    if (res.isEmpty) {
      print('Tablo bos. Henuz kayitli profil bulunmuyor.');
    } else {
      print('Kayitli Profiller (${res.length} adet):');
      print('--------------------------------------');
      for (var i = 0; i < res.length; i++) {
        final profile = res[i];
        print('${i + 1}. E-posta: ${profile['email']}');
        print('   User ID: ${profile['user_id']}');
        print('   Ad Soyad: ${profile['full_name'] ?? 'Girilmemis'}');
        print('   Telefon: ${profile['phone_number'] ?? 'Girilmemis'}');
        print('   Premium: ${profile['premium_status'] == true ? "Evet" : "Hayir"}');
        print('--------------------------------------');
      }
    }
  } catch (e) {
    print('HATA: $e');
  }
}
