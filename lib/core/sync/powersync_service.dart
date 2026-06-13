import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// PowerSync ile Supabase arasındaki çevrimdışı senkronizasyon motorunu yöneten servis
class PowerSyncService {
  static final PowerSyncService _instance = PowerSyncService._internal();
  factory PowerSyncService() => _instance;
  PowerSyncService._internal();

  late final PowerSyncDatabase db;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// PowerSync veritabanını yerel dosya yolunda başlatır ve şemayı hazırlar
  Future<void> initializeSchema() async {
    if (_isInitialized) return;

    // Yerel SQLite veri depolama dizini
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'depometrik_powersync.db');

    // PowerSync şemasını tanımla (tables.dart'taki Drift şemasıyla paralel)
    final schema = const Schema([
      Table('profiles', [
        Column.text('email'),
        Column.text('created_at'),
        Column.integer('premium_status'),
        Column.integer('accepted_all_statement_terms'),
        Column.integer('open_banking_connected'),
        Column.text('subscription_status'),
        Column.text('full_name'),
        Column.text('tckn'),
        Column.text('phone_number'),
      ]),
      Table('vehicles', [
        Column.text('user_id'),
        Column.text('plate'),
        Column.text('brand'),
        Column.text('model'),
        Column.text('fuel_type'),
        Column.integer('initial_odometer'),
        Column.integer('current_odometer'),
      ]),
      Table('refuelings', [
        Column.text('vehicle_id'),
        Column.text('station_id'),
        Column.real('liters'),
        Column.real('unit_price'),
        Column.real('total_price'),
        Column.integer('odometer'),
        Column.text('purchase_date'),
        Column.integer('is_full_tank'),
        Column.text('image_path'),
      ]),
      Table('card_transactions', [
        Column.text('user_id'),
        Column.text('refueling_id'),
        Column.text('transaction_date'),
        Column.real('amount'),
        Column.text('merchant_name'),
        Column.text('source'),
        Column.text('card_number_mask'),
        Column.text('bank_transaction_code'),
        Column.text('pos_terminal_details'),
        Column.integer('scheduled_payment'),
      ]),
      Table('campaigns', [
        Column.text('user_id'),
        Column.text('bank_name'),
        Column.text('station_brand'),
        Column.integer('target_tx_count'),
        Column.integer('current_tx_count'),
        Column.real('reward_amount'),
        Column.text('expiry_date'),
      ]),
      Table('global_campaigns', [
        Column.text('bank_name'),
        Column.text('station_brand'),
        Column.integer('target_tx_count'),
        Column.real('min_tx_amount'),
        Column.real('reward_amount'),
        Column.integer('is_different_days_required'),
        Column.text('expiry_date'),
        Column.integer('is_active'),
      ]),
      Table('user_cards', [
        Column.text('user_id'),
        Column.text('bank_name'),
        Column.text('card_program'),
      ]),
    ]);

    db = PowerSyncDatabase(
      schema: schema,
      path: dbPath,
    );

    await db.initialize();
    _isInitialized = true;
  }

  /// Supabase ile çift yönlü veri senkronizasyonunu başlatır
  Future<void> connectToSupabase() async {
    final supabase = Supabase.instance.client;
    if (supabase.auth.currentSession == null) {
      print('PowerSync: No active Supabase session. Sync disabled.');
      return;
    }
    
    // PowerSync ile Supabase API entegrasyonu için bağlayıcı sınıfı
    final connector = SupabaseConnector(supabase);
    await db.connect(connector: connector);
  }

  /// Kullanıcı oturumu kapattığında verileri temizle ve bağlantıyı kes
  Future<void> disconnect() async {
    await db.disconnect();
  }
}

/// PowerSync'in Supabase veritabanına veri yüklemesini (CRUD) sağlayan connector
class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient client;

  SupabaseConnector(this.client);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = client.auth.currentSession;
    if (session == null) return null;
    
    return PowerSyncCredentials(
      endpoint: 'https://6a21dfe3deeddd0df6022ac3.powersync.journeyapps.com', // PowerSync endpoint url
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    print('PowerSync Connector: uploadData called.');
    // Çevrimdışı yapılan değişiklikleri (kuyruğu) Supabase'e yükler
    final batch = await database.getCrudBatch();
    if (batch == null) {
      print('PowerSync Connector: crud batch is null, returning.');
      return;
    }

    print('PowerSync Connector: Crud batch size: ${batch.crud.length}');
    for (final row in batch.crud) {
      final table = client.from(row.table);
      final op = row.op;
      final id = row.id;
      final data = Map<String, dynamic>.from(row.opData ?? {});
      
      final pkColumn = _getPrimaryKeyColumn(row.table);
      
      // Supabase tablosundaki gerçek primary key kolonunu atıyoruz
      data[pkColumn] = id;
      if (pkColumn != 'id') {
        data.remove('id'); // SQLite local 'id' kolonunu istekten çıkarıyoruz (Supabase'de hata vermemesi için)
      }

      // Supabase'de karşılığı olmayan local kolonları temizliyoruz
      if (row.table == 'profiles') {
        data.remove('open_banking_connected');
        data.remove('subscription_status');
        data.remove('accepted_all_statement_terms');
      } else if (row.table == 'card_transactions') {
        data.remove('card_number_mask');
        data.remove('bank_transaction_code');
        data.remove('pos_terminal_details');
        data.remove('scheduled_payment');
      }

      _formatDateTimeFields(data);
      _formatBooleanFields(row.table, data);
      print('PowerSync Connector: Processing row: table=${row.table}, op=$op, pkColumn=$pkColumn, id=$id, data=$data');

      try {
        if (op == UpdateType.put || op == UpdateType.patch) {
          print('PowerSync Connector: Executing upsert...');
          await table.upsert(data, onConflict: pkColumn);
          print('PowerSync Connector: Upsert completed successfully.');
        } else if (op == UpdateType.delete) {
          print('PowerSync Connector: Executing delete...');
          await table.delete().eq(pkColumn, id);
          print('PowerSync Connector: Delete completed successfully.');
        }
      } catch (e) {
        // Hata durumunda kuyruğu bloke etmemek için loglayıp devam edebiliriz
        print('PowerSync Upload Error on table ${row.table} ($op): $e');
      }
    }

    print('PowerSync Connector: Completing batch...');
    await batch.complete();
    print('PowerSync Connector: Batch completed.');
  }

  void _formatDateTimeFields(Map<String, dynamic> data) {
    const dateTimeFields = {
      'created_at',
      'purchase_date',
      'transaction_date',
      'expiry_date',
      'recorded_at'
    };
    for (final key in dateTimeFields) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key];
        if (val is int) {
          data[key] = DateTime.fromMillisecondsSinceEpoch(val * 1000).toUtc().toIso8601String();
        } else if (val is String) {
          final parsed = int.tryParse(val);
          if (parsed != null) {
            data[key] = DateTime.fromMillisecondsSinceEpoch(parsed * 1000).toUtc().toIso8601String();
          }
        }
      }
    }
  }

  void _formatBooleanFields(String tableName, Map<String, dynamic> data) {
    const tableBooleans = {
      'profiles': {
        'premium_status',
        'accepted_all_statement_terms',
        'open_banking_connected',
      },
      'refuelings': {
        'is_full_tank',
      },
      'card_transactions': {
        'scheduled_payment',
      },
    };

    final booleanFields = tableBooleans[tableName];
    if (booleanFields != null) {
      for (final field in booleanFields) {
        if (data.containsKey(field) && data[field] != null) {
          final val = data[field];
          if (val is int) {
            data[field] = val == 1;
          } else if (val is String) {
            data[field] = val == '1' || val.toLowerCase() == 'true';
          }
        }
      }
    }
  }

  String _getPrimaryKeyColumn(String tableName) {
    switch (tableName) {
      case 'profiles':
        return 'user_id';
      case 'vehicles':
        return 'vehicle_id';
      case 'refuelings':
        return 'refueling_id';
      case 'card_transactions':
        return 'transaction_id';
      case 'campaigns':
        return 'campaign_id';
      case 'obd_readings':
        return 'reading_id';
      case 'destructive_offline_queue':
        return 'queue_id';
      case 'attachment_queue':
        return 'attachment_id';
      default:
        return 'id';
    }
  }
}
