import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://napqcopzozmipkuzmdee.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o',
  );

  try {
    final response = await supabase.auth.signUp(
      email: 'test_upsert_${DateTime.now().millisecondsSinceEpoch}@example.com',
      password: 'password123',
    );
    
    // We must wait for the session to be fully established or use the token
    final session = response.session;
    if (session != null) {
      final userId = session.user.id;
      print('User created and session active: $userId');
      
      try {
        await supabase.from('profiles').upsert({
          'user_id': userId,
          'email': session.user.email,
          'full_name': 'Test User',
          'phone_number': '5301234567',
          'tckn': null, // Like the user's empty field
          'premium_status': false,
        }, onConflict: 'user_id');
        print('UPSERT SUCCESS!');
      } catch (e) {
        print('UPSERT FAILED: $e');
      }
    } else {
      print('No active session after signup.');
    }
  } catch (e, st) {
    print('Auth Error: $e');
    print(st);
  }
}
