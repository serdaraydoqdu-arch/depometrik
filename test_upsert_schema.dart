import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://napqcopzozmipkuzmdee.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o', // This is anon key
  );
  
  try {
    await supabase.from('profiles').upsert({
      'user_id': '00000000-0000-0000-0000-000000000000',
      'email': 'test@example.com',
      'created_at': '2026-06-10T12:33:43.000Z',
      'premium_status': false,
      // 'full_name': 'Test User',
      // 'tckn': null,
      // 'phone_number': '5301234567',
    }, onConflict: 'user_id');
    print('UPSERT SUCCESS');
  } catch (e) {
    print('ERROR: $e');
  }
}
