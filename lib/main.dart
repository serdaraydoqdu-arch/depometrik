import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/theme/app_theme.dart';
import 'core/sync/powersync_service.dart';
import 'data/local/db/db_service.dart';
import 'core/utils/location_service.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/sync/attachment_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://napqcopzozmipkuzmdee.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hcHFjb3B6b3ptaXBrdXptZGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNDc4OTcsImV4cCI6MjA5NTkyMzg5N30.kDF_QNdBCQCMtnOANQdhGy5thF1T6RoBbewLX2IFA0o',
  );

  // PowerSync ve veritabanı senkronizasyonunu başlat
  final powersyncService = PowerSyncService();
  await powersyncService.initializeSchema();

  // Aktif oturum varsa PowerSync senkronizasyonunu başlat
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentSession != null) {
    try {
      await powersyncService.connectToSupabase();
      print('PowerSync: Aktif oturum baglantisi kuruldu.');
    } catch (e) {
      print('PowerSync: Baglanti hatasi: $e');
    }
  } else {
    print('PowerSync: Aktif oturum bulunamadi. Baglanti ertelendi.');
  }

  // Veritabanı servisini köprü üzerinden ilklendir
  DbService().init();

  // Kayıtlı şehir bilgisini yükle
  await CityPreference.loadCity();

  // İnternet geri geldiğinde çevrimdışı belgeleri kuyruktan yüklemek için dinleyici
  Connectivity().onConnectivityChanged.listen((results) {
    if (!results.contains(ConnectivityResult.none)) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        AttachmentManager().processPendingQueue(session.user.id);
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'DepoMetrik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      locale: const Locale('tr', 'TR'),
      home: hasSession ? const HomeScreen() : const AuthScreen(),
    );
  }
}
