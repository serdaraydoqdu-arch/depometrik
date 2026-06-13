import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';

/// Faz 3 Çevrimdışı Belge/Fotoğraf Yükleme ve Yönetim Servisi (Attachments Helper)
class AttachmentManager {
  static final AttachmentManager _instance = AttachmentManager._internal();
  factory AttachmentManager() => _instance;
  AttachmentManager._internal();

  final _db = DbService().database;
  final _supabase = Supabase.instance.client;

  /// Dosyayı çevrimdışı kuyruğa ekler ve yerel yolla başlatır
  Future<void> queueAttachment({
    required String userId,
    required String localFilePath,
    required String storageBucket,
  }) async {
    final fileName = p.basename(localFilePath);
    final remotePath = '$userId/$storageBucket/${const Uuid().v4()}_$fileName';

    final companion = AttachmentQueueCompanion.insert(
      attachmentId: const Uuid().v4(),
      userId: userId,
      filePath: localFilePath,
      remoteStoragePath: remotePath,
      status: const Value('PENDING'),
      retryCount: const Value(0),
      createdAt: Value(DateTime.now()),
    );

    await _db.insertAttachmentQueue(companion);
    
    // İnternet varsa hemen yüklemeyi dene
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      _processQueue(userId);
    }
  }

  /// Kuyruktaki yüklenmemiş belgeleri arka planda Supabase Storage'a yükler
  Future<void> processPendingQueue(String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return; // İnternet yoksa çık
    
    await _processQueue(userId);
  }

  Future<void> _processQueue(String userId) async {
    final pendingItems = await _db.getPendingAttachments(userId);
    if (pendingItems.isEmpty) return;

    for (final item in pendingItems) {
      final file = File(item.filePath);
      if (!await file.exists()) {
        // Dosya yerelde yoksa hata durumuna çek
        await _db.updateAttachmentQueue(
          item.copyWith(status: 'FAILED', retryCount: item.retryCount + 1),
        );
        continue;
      }

      // Durumu UPLOADING olarak güncelle
      await _db.updateAttachmentQueue(item.copyWith(status: 'UPLOADING'));

      try {
        // Supabase Storage'a yükle
        await _supabase.storage.from('receipts').upload(
              item.remoteStoragePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        // Başarılı olursa veritabanı durumunu SUCCESS yap
        await _db.updateAttachmentQueue(item.copyWith(status: 'SUCCESS'));
        
        // Yerel dosyayı temizle (Opsiyonel - Cihaz hafıza optimizasyonu)
        // try { await file.delete(); } catch (_) {}
      } catch (e) {
        final newRetryCount = item.retryCount + 1;
        final newStatus = newRetryCount >= 5 ? 'FAILED' : 'PENDING';
        
        await _db.updateAttachmentQueue(
          item.copyWith(
            status: newStatus,
            retryCount: newRetryCount,
          ),
        );
      }
    }
  }
}
