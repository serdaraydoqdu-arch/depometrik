import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        if (methodCall.method.startsWith('set')) {
          return true;
        }
        return null;
      },
    );
  });

  test('Test profile update', () async {
    print('Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://napqcopzozmipkuzmdee.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o',
    );
    final supabase = Supabase.instance.client;
    
    final email = 'test_update_flow_${DateTime.now().millisecondsSinceEpoch}@gmail.com';
    final password = 'password123';

    try {
      print('Signing up user: $email');
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': 'Initial Name',
          'phone_number': '5301111111',
          'tckn': null,
        },
      );

      final session = response.session;
      final user = response.user;

      if (user != null) {
        print('SignUp completed. User ID: ${user.id}');
        print('Session is null: ${session == null}');
        
        // Wait a few seconds to let any async triggers complete
        await Future.delayed(const Duration(seconds: 2));

        try {
          print('Attempting direct upsert on profiles (simulating HomeScreen bottom sheet update)...');
          await supabase.from('profiles').upsert({
            'user_id': user.id,
            'email': email,
            'full_name': 'Updated Name',
            'tckn': null,
            'phone_number': '5302222222',
            'premium_status': false,
          }, onConflict: 'user_id');
          print('UPSERT SUCCESSFUL!');
        } catch (e, st) {
          print('UPSERT FAILED with exception: $e');
          print(st);
        }
      } else {
        print('User is null after signup');
      }
    } on AuthUnknownException catch (e) {
      print('AuthUnknownException: ${e.message}, status=${e.statusCode}');
      if (e.originalError is http.Response) {
        final resp = e.originalError as http.Response;
        print('Response body: ${resp.body}');
      } else {
        print('Original error: ${e.originalError}');
      }
    } catch (e, st) {
      print('General Error: $e');
      print(st);
    }
  });
}
