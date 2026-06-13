import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';

/// Faz 3 Çevrimdışı ve Dağıtık Sistemlerde Çakışma Çözümleme (Conflict Resolution) Servisi
class ConflictResolver {
  static final ConflictResolver _instance = ConflictResolver._internal();
  factory ConflictResolver() => _instance;
  ConflictResolver._internal();

  final _db = DbService().database;

  /// Çevrimdışı durumlarda "Yıkıcı İşlemlerin" (Silme, Kalıcı Sıfırlama) yapılabilirliğini kontrol eder.
  /// Faz 3 standartlarına göre internet bağlantısı yokken yıkıcı eylemler arayüzde engellenmelidir.
  Future<bool> canPerformAction({required String actionType}) async {
    // İnternet bağlantısını sorgula
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    // Eğer işlem yıkıcı bir işlemse (örn. DELETE) ve cihaz çevrimdışıysa engelle
    if ((actionType == 'DELETE' || actionType == 'RESET') && !isOnline) {
      return false;
    }
    return true;
  }

  /// Çevrimdışı yapılan ve geçici olarak engellenmeyen yıkıcı/kritik işlemleri kuyruğa kaydeder.
  Future<void> logDestructiveOfflineAction({
    required String userId,
    required String entityType,
    required String entityId,
    required String actionType,
  }) async {
    final companion = DestructiveOfflineQueueCompanion.insert(
      queueId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      actionType: actionType,
      createdAt: Value(DateTime.now()),
    );
    await _db.insertDestructiveOfflineQueue(companion);
  }

  /// Last-Write-Wins (Son Yazan Kazanır) mantığına göre veritabanı eşleştirmesi yapar.
  /// Çakışma durumunda en son zaman damgasına (timestamp) sahip olan kayıt geçerli sayılır.
  Future<void> resolveConflictLWW<T>({
    required T localRecord,
    required T remoteRecord,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required Future<void> Function(T winningRecord) onResolved,
  }) async {
    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      // Yerel kayıt kazandı, yerel veriyi sunucuya gönder
      await onResolved(localRecord);
    } else {
      // Sunucu kaydı kazandı, yerel veritabanını sunucudan gelenle güncelle
      await onResolved(remoteRecord);
    }
  }
}
