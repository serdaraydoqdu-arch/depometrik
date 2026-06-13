import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import '../../../core/sync/powersync_service.dart';
import 'app_database.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  late AppDatabase database;

  factory DbService() {
    return _instance;
  }

  DbService._internal();

  /// PowerSync başlatıldıktan sonra çağrılacak veri tabanı başlatma metodu
  void init() {
    database = AppDatabase(SqliteAsyncDriftConnection(PowerSyncService().db));
  }

  void setDatabase(AppDatabase db) {
    database = db;
  }
}
