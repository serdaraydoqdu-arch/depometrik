import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/parser/pdf_statement_parser.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import '../theme/app_theme.dart';

/// Yüklenmiş ekstre dosyası meta verisini temsil eden sınıf
class UploadedStatement {
  final int id;
  final String fileName;
  final String filePath;
  final DateTime uploadDate;

  UploadedStatement({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.uploadDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'filePath': filePath,
    'uploadDate': uploadDate.toIso8601String(),
  };

  factory UploadedStatement.fromJson(Map<String, dynamic> json) => UploadedStatement(
    id: json['id'] as int,
    fileName: json['fileName'] as String,
    filePath: json['filePath'] as String,
    uploadDate: DateTime.parse(json['uploadDate'] as String),
  );
}

/// Kredi Kartı Ekstresi (PDF) yükleyip akaryakıt harcamalarını ayıklayan premium ekran
class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  String get _currentUserId {
    return Supabase.instance.client.auth.currentSession?.user.id ?? '11111111-1111-1111-1111-111111111111';
  }

  final PdfStatementParser _parser = PdfStatementParser();
  
  bool _isLoading = false;
  String _loadingMessage = '';
  String? _selectedFileName;
  String? _selectedFilePath;
  
  List<StatementUpload> _uploadedStatements = [];
  List<CardTransaction> _existingTransactions = [];
  List<PdfTransaction> _allTransactions = [];
  String _sortBy = 'status_asc'; // 'status_asc', 'status_desc', 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'
  bool _isAllTransactionsMode = false;
  int? _currentStatementId;

  @override
  void initState() {
    super.initState();
    _ensureProfileExists();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = DbService().database;
    final list = await db.getAllStatementUploads();
    final mockUserId = _currentUserId;
    final existing = await db.getCardTransactionsForUser(mockUserId);
    setState(() {
      _uploadedStatements = list;
      _existingTransactions = existing;
      _sortTransactions();
    });
  }

  Future<void> _refreshExistingTransactions() async {
    final db = DbService().database;
    final mockUserId = _currentUserId;
    final existing = await db.getCardTransactionsForUser(mockUserId);
    setState(() {
      _existingTransactions = existing;
      _sortTransactions();
    });
  }

  int _getTransactionStatus(PdfTransaction tx) {
    final matchingDbTx = _findMatchingDbTransaction(tx, _existingTransactions);
    if (matchingDbTx == null) {
      return 3; // Yeni (geri kalanlar)
    }
    final isApproved = matchingDbTx.refuelingId != null;
    if (isApproved) {
      return 2; // Onaylananlar
    } else {
      return 1; // Bekleyenler
    }
  }

  void _sortTransactions() {
    setState(() {
      if (_sortBy == 'date_desc') {
        _allTransactions.sort((a, b) => b.date.compareTo(a.date));
      } else if (_sortBy == 'date_asc') {
        _allTransactions.sort((a, b) => a.date.compareTo(b.date));
      } else if (_sortBy == 'amount_desc') {
        _allTransactions.sort((a, b) => b.amount.compareTo(a.amount));
      } else if (_sortBy == 'amount_asc') {
        _allTransactions.sort((a, b) => a.amount.compareTo(b.amount));
      } else if (_sortBy == 'status_asc') {
        _allTransactions.sort((a, b) {
          final statusA = _getTransactionStatus(a);
          final statusB = _getTransactionStatus(b);
          if (statusA != statusB) {
            return statusA.compareTo(statusB);
          }
          return b.date.compareTo(a.date);
        });
      } else if (_sortBy == 'status_desc') {
        _allTransactions.sort((a, b) {
          final statusA = _getTransactionStatus(a);
          final statusB = _getTransactionStatus(b);
          if (statusA != statusB) {
            return statusB.compareTo(statusA);
          }
          return b.date.compareTo(a.date);
        });
      }
    });
  }



  CardTransaction? _findMatchingDbTransaction(PdfTransaction tx, List<CardTransaction> existingList) {
    for (final dbTx in existingList) {
      final sameDate = tx.date.year == dbTx.transactionDate.year &&
                       tx.date.month == dbTx.transactionDate.month &&
                       tx.date.day == dbTx.transactionDate.day;
      final sameAmount = (tx.amount - dbTx.amount).abs() < 0.01;
      
      final cleanTxMerchant = tx.merchantName.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final cleanDbMerchant = dbTx.merchantName.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final merchantMatches = cleanTxMerchant.contains(cleanDbMerchant) || cleanDbMerchant.contains(cleanTxMerchant);
      
      if (sameDate && sameAmount && merchantMatches) {
        return dbTx;
      }
    }
    return null;
  }

  bool _isAlreadyImported(PdfTransaction tx, List<CardTransaction> existingList) {
    return _findMatchingDbTransaction(tx, existingList) != null;
  }

  Future<void> _openSavedStatement(StatementUpload statement) async {
    final file = File(statement.filePath);
    final fileExists = await file.exists();
    if (!mounted) return;
    if (!fileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ekstre dosyası cihazda bulunamadı.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedFileName = statement.fileName;
      _selectedFilePath = statement.filePath;
      _currentStatementId = statement.id;
      _loadingMessage = 'Akaryakıt verileri derleniyor...';
      _isAllTransactionsMode = statement.acceptedAllTerms;
      _allTransactions.clear();
    });

    try {
      final transactions = await _parser.parseStatement(file, parseAll: _isAllTransactionsMode);
      
      final db = DbService().database;
      final mockUserId = _currentUserId;
      final existingTransactions = await db.getCardTransactionsForUser(mockUserId);
      
      final newCount = transactions.where((tx) => !_isAlreadyImported(tx, existingTransactions)).length;

      if (!mounted) return;

      setState(() {
        _allTransactions = transactions;
        _existingTransactions = existingTransactions;
        _sortTransactions();
        _isLoading = false;
      });

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ekstre dosyasında akaryakıt harcaması bulunamadı.'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      } else if (newCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu ekstredeki tüm akaryakıt işlemleri zaten daha önce aktarılmış.'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$newCount adet yeni akaryakıt işlemi başarıyla süzüldü!'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _ensureProfileExists() async {
    final db = DbService().database;
    final mockUserId = _currentUserId;
    final profile = await db.getProfileById(mockUserId);
    if (profile == null) {
      await db.insertProfile(
        ProfilesCompanion(
          userId: drift.Value(mockUserId),
          email: const drift.Value('serdar@depometrik.com'),
          premiumStatus: const drift.Value(true),
        ),
      );
    }
  }

  /// Cihazdan PDF dosyası seçer ve taramayı başlatır
  Future<void> _pickAndProcessPdf() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      final file = File(path);
      final fileName = result.files.single.name;

      setState(() {
        _isLoading = true;
        _selectedFileName = fileName;
        _selectedFilePath = path;
        _loadingMessage = 'Akaryakıt verileri derleniyor...';
        _isAllTransactionsMode = false;
        _allTransactions.clear();
      });

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _loadingMessage = 'Akaryakıt verileri derleniyor...';
      });

      final transactions = await _parser.parseStatement(file);

      final db = DbService().database;
      final mockUserId = _currentUserId;
      final existingTransactions = await db.getCardTransactionsForUser(mockUserId);
      
      final newCount = transactions.where((tx) => !_isAlreadyImported(tx, existingTransactions)).length;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _allTransactions = transactions;
        _existingTransactions = existingTransactions;
        _sortTransactions();
        _isLoading = false;
      });

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ekstre dosyasında akaryakıt harcaması bulunamadı.'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      } else {
        if (newCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu ekstre dosyasındaki tüm işlemler zaten daha önce aktarılmış.'),
              backgroundColor: AppTheme.accentOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$newCount adet yeni akaryakıt işlemi başarıyla süzüldü!'),
              backgroundColor: AppTheme.primaryCyan,
            ),
          );
        }

        // Ekstre dosyasını yerel klasöre kopyala ve listeyi güncelle
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final localPath = p.join(appDir.path, 'statements');
          final localDir = Directory(localPath);
          if (!await localDir.exists()) {
            await localDir.create(recursive: true);
          }
          final newFileName = 'statement_${const Uuid().v4()}.pdf';
          final savedFile = File(p.join(localPath, newFileName));
          await file.copy(savedFile.path);

          // Listeye yeni kayıt ekle
          final db = DbService().database;
          final companion = StatementUploadsCompanion.insert(
            fileName: fileName,
            filePath: savedFile.path,
            uploadDate: drift.Value(DateTime.now()),
            acceptedAllTerms: const drift.Value(false),
          );
          final newId = await db.insertStatementUpload(companion);
          final freshList = await db.getAllStatementUploads();

          setState(() {
            _uploadedStatements = freshList;
            _selectedFilePath = savedFile.path; // Artık yeni kopyalanan yola referans etsin (Yeniden tara dediğinde de çalışabilsin)
            _currentStatementId = newId;
          });
        } catch (_) {
          // Hataları yoksay
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF yükleme hatası: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  /// Mevcut PDF dosyasını yeniden süzüp analiz eder (Yenileme Akışı)
  Future<void> _reprocessPdf() async {
    if (_selectedFilePath == null) return;
    final file = File(_selectedFilePath!);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taranacak ekstre dosyası artık mevcut değil.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'PDF dosyası okunuyor...';
      _allTransactions.clear();
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _loadingMessage = 'Akaryakıt verileri derleniyor...';
    });

    try {
      final transactions = await _parser.parseStatement(file, parseAll: _isAllTransactionsMode);

      final db = DbService().database;
      final mockUserId = _currentUserId;
      final existingTransactions = await db.getCardTransactionsForUser(mockUserId);
      
      final newCount = transactions.where((tx) => !_isAlreadyImported(tx, existingTransactions)).length;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _allTransactions = transactions;
        _existingTransactions = existingTransactions;
        _sortTransactions();
        _isLoading = false;
      });

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ekstre dosyasında akaryakıt harcaması bulunamadı.'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      } else if (newCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu ekstre dosyasındaki tüm işlemler zaten onaylanmış/beklemede.'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$newCount adet yeni akaryakıt işlemi başarıyla süzüldü!'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ekstre yeniden analiz edilirken hata oluştu: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _showBringAllTransactionsDialogOrProcess() async {
    final db = DbService().database;
    bool hasAccepted = false;
    if (_currentStatementId != null) {
      final currentStatement = await db.getStatementUploadById(_currentStatementId!);
      hasAccepted = currentStatement?.acceptedAllTerms ?? false;
    }

    if (hasAccepted) {
      _processAllTransactions();
      return;
    }

    bool isChecked = false;

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tüm Harcamaları Getir',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bu seçeneği tercih ettiğinizde, PDF ekstre dosyanız içerisindeki tüm harcamalar (sadece akaryakıt olanlar değil, market, alışveriş vb. tüm işlemler) taranarak listelenecektir.',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bu işlem veri tabanınıza akaryakıt dışı harcamaların da aktarılmasına yol açabilir.',
                    style: TextStyle(color: AppTheme.errorRed, fontSize: 12.5, fontWeight: FontWeight.bold, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setDialogState(() {
                        isChecked = !isChecked;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: AppTheme.primaryCyan,
                            onChanged: (val) {
                              setDialogState(() {
                                isChecked = val ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Okudum, anladım ve kabul ediyorum.',
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('REDDET'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isChecked
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryCyan.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isChecked ? AppTheme.primaryCyan : const Color(0xFFE2E8F0),
                            foregroundColor: isChecked ? Colors.white : const Color(0xFF94A3B8),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                          ),
                          onPressed: isChecked
                              ? () async {
                                  Navigator.pop(context);
                                  if (_currentStatementId != null) {
                                    final currentStatement = await db.getStatementUploadById(_currentStatementId!);
                                    if (currentStatement != null) {
                                      await db.updateStatementUpload(
                                        currentStatement.copyWith(acceptedAllTerms: true),
                                      );
                                      final freshList = await db.getAllStatementUploads();
                                      setState(() {
                                        _uploadedStatements = freshList;
                                      });
                                    }
                                  }
                                  _processAllTransactions();
                                }
                              : null,
                          child: const Text('KABUL ET'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processAllTransactions() async {
    if (_selectedFilePath == null) return;
    final file = File(_selectedFilePath!);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taranacak ekstre dosyası artık mevcut değil.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Ekstrenin tamamı taranıyor...';
      _isAllTransactionsMode = true;
      _allTransactions.clear();
    });

    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final transactions = await _parser.parseStatement(file, parseAll: true);

      final db = DbService().database;
      final mockUserId = _currentUserId;
      final existingTransactions = await db.getCardTransactionsForUser(mockUserId);
      
      final newCount = transactions.where((tx) => !_isAlreadyImported(tx, existingTransactions)).length;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _allTransactions = transactions;
        _existingTransactions = existingTransactions;
        _sortTransactions();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tüm ekstre tarandı! $newCount adet yeni işlem süzüldü.'),
          backgroundColor: AppTheme.primaryCyan,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _showFuelOnlyTransactions() async {
    if (_selectedFilePath == null) return;
    final file = File(_selectedFilePath!);
    if (!await file.exists()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Sadece akaryakıt harcamaları süzüyor...';
      _isAllTransactionsMode = false;
      _allTransactions.clear();
    });

    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final transactions = await _parser.parseStatement(file, parseAll: false);

      final db = DbService().database;
      final mockUserId = _currentUserId;
      final existingTransactions = await db.getCardTransactionsForUser(mockUserId);
      
      final newCount = transactions.where((tx) => !_isAlreadyImported(tx, existingTransactions)).length;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _allTransactions = transactions;
        _existingTransactions = existingTransactions;
        _sortTransactions();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akaryakıt harcamaları süzüldü! $newCount adet yeni işlem bulundu.'),
          backgroundColor: AppTheme.primaryCyan,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Toplam tutarı hesaplar
  double _calculateTotal() {
    double total = 0;
    for (final tx in _allTransactions) {
      total += tx.amount;
    }
    return total;
  }

  /// Harcamayı düzenleyen premium diyalog
  Future<void> _showEditDialog(int index) async {
    final tx = _allTransactions[index];
    final merchantController = TextEditingController(text: tx.merchantName);
    final amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));
    
    DateTime selectedDate = tx.date;
    final dateController = TextEditingController(
      text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit_calendar_rounded, color: AppTheme.primaryCyan),
                  SizedBox(width: 8),
                  Text(
                    'Harcamayı Düzenle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İşyeri Adı
                    TextFormField(
                      controller: merchantController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'İşyeri Adı',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen işyeri adı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tutar
                    TextFormField(
                      controller: amountController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Tutar (TL)',
                        prefixIcon: Icon(Icons.currency_lira),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen tutar girin';
                        }
                        final val = double.tryParse(value.replaceAll(',', '.'));
                        if (val == null || val <= 0) {
                          return 'Lütfen geçerli bir tutar girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tarih
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          setDialogState(() {
                            dateController.text = '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('İPTAL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final parsedAmount = double.parse(amountController.text.replaceAll(',', '.'));
                      final updatedTx = PdfTransaction(
                        date: selectedDate,
                        merchantName: merchantController.text.trim(),
                        amount: parsedAmount,
                      );
                      
                      final db = DbService().database;
                      final mockUserId = _currentUserId;
                      
                      final companion = CardTransactionsCompanion(
                        transactionId: drift.Value(const Uuid().v4()),
                        userId: drift.Value(mockUserId),
                        transactionDate: drift.Value(updatedTx.date),
                        amount: drift.Value(updatedTx.amount),
                        merchantName: drift.Value(updatedTx.merchantName),
                        source: drift.Value('PDF'),
                      );

                      try {
                        await db.insertCardTransaction(companion);
                        await _refreshExistingTransactions();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${updatedTx.merchantName} başarıyla onaylandı ve kaydedildi!'),
                              backgroundColor: AppTheme.primaryCyan,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Onaylanırken hata oluştu: $e'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: const Size(80, 40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('ONAYLA'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTransactionDetailsPopup(PdfTransaction tx, {required bool isImported, required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final months = [
          'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
          'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
        ];
        final weekdays = [
          'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
        ];
        final dateStr = '${tx.date.day} ${months[tx.date.month - 1]} ${tx.date.year}';
        final weekdayStr = weekdays[tx.date.weekday - 1];

        final isFuel = PdfStatementParser.isFuelMerchant(tx.merchantName);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.lightSurface,
                  Color(0xFFF8FAFC),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isApproved
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : (isImported
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                        : AppTheme.primaryCyan.withValues(alpha: 0.3)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isApproved
                      ? const Color(0xFF10B981)
                      : (isImported ? const Color(0xFFF59E0B) : AppTheme.primaryCyan))
                      .withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFuel
                                  ? AppTheme.primaryCyan.withValues(alpha: 0.1)
                                  : const Color(0xFF64748B).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFuel ? Icons.local_gas_station : Icons.storefront_rounded,
                              color: isFuel ? AppTheme.primaryCyan : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'İşlem Detayları',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppTheme.primaryCyan, size: 14),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 16, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                '${tx.amount.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                  color: AppTheme.primaryCyan,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isFuel
                                      ? AppTheme.primaryCyan.withValues(alpha: 0.1)
                                      : const Color(0xFF64748B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isFuel ? 'AKARYAKIT HARCAMASI' : 'GENEL HARCAMA',
                                  style: TextStyle(
                                    color: isFuel ? AppTheme.primaryCyan : const Color(0xFF64748B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('İşyeri:', tx.merchantName, isBold: true),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow('Tarih:', '$dateStr, $weekdayStr'),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow('Kaynak:', 'Kredi Kartı Ekstresi (PDF)'),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow(
                        'İşlem Durumu:',
                        isApproved
                            ? 'Onaylandı (Yakıt Geçmişinde)'
                            : (isImported ? 'Onaylandı (Bekleyen Harcama)' : 'Yeni / Aktarılmadı'),
                        valueColor: isApproved
                            ? const Color(0xFF10B981)
                            : (isImported ? const Color(0xFFF59E0B) : AppTheme.primaryCyan),
                        isBold: true,
                      ),
                      const Divider(color: AppTheme.borderLight, height: 20),
                      _buildDetailRow(
                        'Benzersiz ID:',
                        '${tx.id.substring(0, 8)}...',
                        isItalic: true,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('İşlem ID\'si panoya kopyalandı.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('KAPAT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {
    Color? valueColor,
    bool isBold = false,
    bool isItalic = false,
    VoidCallback? onTap,
  }) {
    Widget valueWidget = Text(
      value,
      textAlign: TextAlign.end,
      style: TextStyle(
        color: valueColor ?? AppTheme.textPrimary,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        fontSize: 13,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (onTap != null) {
      valueWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textPrimary,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.content_copy_rounded,
                size: 14,
                color: valueColor ?? AppTheme.primaryCyan,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: valueWidget),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allTransactions.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _allTransactions.clear();
          _selectedFileName = null;
          _selectedFilePath = null;
          _currentStatementId = null;
          _isAllTransactionsMode = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_allTransactions.isNotEmpty) {
                    setState(() {
                      _allTransactions.clear();
                      _selectedFileName = null;
                      _selectedFilePath = null;
                      _currentStatementId = null;
                      _isAllTransactionsMode = false;
                    });
                  } else {
                    Navigator.maybePop(context);
                  }
                },
              ),
              if (_selectedFilePath != null)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Yeniden Analiz Et',
                  onPressed: _isLoading ? null : _reprocessPdf,
                ),
            ],
          ),
          title: const Text('Ekstre Yükle (PDF)'),
        ),
        body: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _allTransactions.isEmpty
                  ? _buildUploadState()
                  : _buildListState(),
        ),
      ),
    );
  }

  /// 1. DOSYA YÜKLEME EKRANI (Varsayılan State)
  Widget _buildUploadState() {
    final uploadCard = InkWell(
      onTap: _pickAndProcessPdf,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryCyan.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1FAE5), width: 3),
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  size: 40,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ekstre PDF Dosyasını Seçin',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kredi kartı ekstre dosyanızı buraya yükleyin.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KVKK Güvencesi Rozeti
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Depometrik Ekstre Yükleme Sistemi',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sürükle / Yükle Alanı
          uploadCard,
          const SizedBox(height: 20),

          // Yüklenen Ekstreler Listesi (Varsa)
          if (_uploadedStatements.isNotEmpty) ...[
            const Text(
              'Yüklenmiş Ekstre Dosyaları',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _uploadedStatements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final statement = _uploadedStatements[index];
                return Dismissible(
                  key: Key('uploaded_${statement.id}'),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.folder_open_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('AÇ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text('SİL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.delete_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _openSavedStatement(statement);
                      return false;
                    } else {
                      final file = File(statement.filePath);
                      try {
                        if (await file.exists()) {
                          await file.delete();
                        }
                      } catch (_) {}
                      
                      final db = DbService().database;
                      await db.deleteStatementUpload(statement.id);
                      final freshList = await db.getAllStatementUploads();
                      
                      setState(() {
                        _uploadedStatements = freshList;
                      });
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${statement.fileName} silindi.'),
                            backgroundColor: AppTheme.accentOrange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      return true;
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 72,
                          color: const Color(0xFF10B981),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFECFDF5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.picture_as_pdf, color: Color(0xFF10B981), size: 20),
                            ),
                            title: Text(
                              '${index + 1}. ${statement.fileName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Yüklenme: ${statement.uploadDate.day}/${statement.uploadDate.month}/${statement.uploadDate.year}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryCyan, size: 14),
                            onTap: () => _openSavedStatement(statement),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 72,
                          color: AppTheme.errorRed,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // KVKK Detay Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lock, color: AppTheme.primaryCyan, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Güvenlik ve Gizlilik Deklarasyonu',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yüklediğiniz ekstre dosyası Depometrik sunucularına gönderilmez, işlem cihazınızda gerçekleşir. Yüklediğiniz ekstre cihazınızda kaydedilir. Akaryakıt ve market harcamalarınız dışındaki hiçbir harcama bu ekranda kaydedilmez.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _pickAndProcessPdf,
            child: const Text('PDF DOSYASI SEÇ'),
          ),
        ],
      ),
    );
  }

  /// 2. YÜKLENİYOR / TARANIYOR EKRANI
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
            ),
            const SizedBox(height: 32),
            Text(
              _loadingMessage,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFileName ?? '',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 3. LİSTELEME EKRANI (İşlemler Tespit Edildikten Sonra)
  Widget _buildListState() {
    final double totalAmount = _calculateTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dosya ve Özet Bilgisi
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_rounded, color: AppTheme.primaryCyan, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? 'Ekstre Dosyası',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _isAllTransactionsMode
                        ? _showFuelOnlyTransactions
                        : _showBringAllTransactionsDialogOrProcess,
                    child: Text(
                      _isAllTransactionsMode ? 'SADECE AKARYAKIT' : 'TÜM EKSTREYİ GETİR',
                      style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam İşlem: ${_allTransactions.length}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Toplam: ${totalAmount.toStringAsFixed(2)} TL',
                    style: const TextStyle(
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildSortBar(),
            ],
          ),
        ),

        // İşlem Listesi
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              height: _allTransactions.length * 84.0,
              child: Stack(
                children: List.generate(_allTransactions.length, (index) {
                  final tx = _allTransactions[index];
                  final matchingDbTx = _findMatchingDbTransaction(tx, _existingTransactions);
                  final isImported = matchingDbTx != null;
                  final isApproved = isImported && matchingDbTx.refuelingId != null;

                  return AnimatedPositioned(
                    key: ValueKey(tx.id),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    top: index * 84.0,
                    left: 0,
                    right: 0,
                    height: 72.0,
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: isImported ? DismissDirection.none : DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Emerald Green
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.edit_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('DÜZENLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text('LİSTEDEN KALDIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.delete_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (isImported) return false;
                        if (direction == DismissDirection.startToEnd) {
                          // Sağa kaydırma - Düzenle diyalogunu aç
                          await _showEditDialog(index);
                          return false; // listenin elemanını kaydırıp geri kapat
                        } else {
                          // Sola kaydırma - Listeden sil
                          final removedTx = _allTransactions[index];
                          setState(() {
                            _allTransactions.removeAt(index);
                          });

                          if (!context.mounted) return true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${removedTx.merchantName} işlem listeden kaldırıldı.'),
                              action: SnackBarAction(
                                label: 'GERİ AL',
                                textColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _allTransactions.insert(index, removedTx);
                                    _sortTransactions();
                                  });
                                },
                              ),
                              backgroundColor: AppTheme.accentOrange,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          return true; // listeden çıkar
                        }
                      },
                      child: Opacity(
                        opacity: isImported ? 0.75 : 1.0,
                        child: Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              // Sol taraf dikey yeşil veya gri kaydırılabilir çizgi indikatörü
                              Container(
                                width: 4,
                                height: 72,
                                color: isImported ? const Color(0xFFCBD5E1) : const Color(0xFF10B981),
                              ),
                              // Kart içeriği
                              Expanded(
                                child: ListTile(
                                  onLongPress: () => _showTransactionDetailsPopup(tx, isImported: isImported, isApproved: isApproved),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_gas_station,
                                      color: isImported ? const Color(0xFF94A3B8) : AppTheme.primaryCyan,
                                      size: 20,
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tx.merchantName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isImported ? AppTheme.textSecondary : AppTheme.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${tx.amount.toStringAsFixed(2)} TL',
                                        style: TextStyle(
                                          color: isImported ? const Color(0xFF64748B) : AppTheme.primaryCyan,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      isImported
                                          ? '${tx.date.day}/${tx.date.month}/${tx.date.year} • Sistemde Kayıtlı'
                                          : '${tx.date.day}/${tx.date.month}/${tx.date.year} • Düzenlemek için sağa, silmek için sola kaydır',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ),
                                  trailing: isImported
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Status Badge
                                            isApproved
                                                ? Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECFDF5),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: const Color(0xFF10B981), width: 1),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: const [
                                                        Icon(Icons.check_circle, color: Color(0xFF059669), size: 12),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Onaylandı',
                                                          style: TextStyle(
                                                            color: Color(0xFF065F46),
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFEF3C7),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: const [
                                                        Icon(Icons.hourglass_empty_rounded, color: Color(0xFFD97706), size: 12),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Bekleyen',
                                                          style: TextStyle(
                                                            color: Color(0xFF92400E),
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            const SizedBox(width: 8),
                                            // Delete/Cancel Action
                                            IconButton(
                                              icon: const Icon(Icons.cancel_rounded, color: AppTheme.errorRed, size: 22),
                                              tooltip: isApproved ? 'Eşleşmeyi Kaldır ve İptal Et' : 'İptal Et / Sil',
                                              onPressed: () async {
                                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                                final db = DbService().database;
                                                try {
                                                  final transactionToRestore = matchingDbTx;
                                                  await db.deleteCardTransaction(matchingDbTx.transactionId);
                                                  await _refreshExistingTransactions();
                                                  
                                                  scaffoldMessenger.clearSnackBars();
                                                  scaffoldMessenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text('${tx.merchantName} işlemi iptal edildi.'),
                                                      duration: const Duration(seconds: 3),
                                                      action: SnackBarAction(
                                                        label: 'GERİ AL',
                                                        textColor: Colors.white,
                                                        onPressed: () async {
                                                          final restoreCompanion = CardTransactionsCompanion(
                                                            transactionId: drift.Value(transactionToRestore.transactionId),
                                                            userId: drift.Value(transactionToRestore.userId),
                                                            refuelingId: drift.Value(transactionToRestore.refuelingId),
                                                            transactionDate: drift.Value(transactionToRestore.transactionDate),
                                                            amount: drift.Value(transactionToRestore.amount),
                                                            merchantName: drift.Value(transactionToRestore.merchantName),
                                                            source: drift.Value(transactionToRestore.source),
                                                          );
                                                          await db.insertCardTransaction(restoreCompanion);
                                                          await _refreshExistingTransactions();
                                                        },
                                                      ),
                                                      backgroundColor: AppTheme.accentOrange,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  scaffoldMessenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text('Hata: $e'),
                                                      backgroundColor: AppTheme.errorRed,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                                          tooltip: 'Bu Harcamayı Onayla ve Kaydet',
                                          onPressed: () async {
                                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                                            final db = DbService().database;
                                            final mockUserId = _currentUserId;
                                            
                                            final companion = CardTransactionsCompanion(
                                              transactionId: drift.Value(const Uuid().v4()),
                                              userId: drift.Value(mockUserId),
                                              transactionDate: drift.Value(tx.date),
                                              amount: drift.Value(tx.amount),
                                              merchantName: drift.Value(tx.merchantName),
                                              source: drift.Value('PDF'),
                                            );

                                            try {
                                              await db.insertCardTransaction(companion);
                                              await _refreshExistingTransactions();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text('${tx.merchantName} başarıyla onaylandı ve kaydedildi!'),
                                                  backgroundColor: AppTheme.primaryCyan,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            } catch (e) {
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text('Hata: $e'),
                                                  backgroundColor: AppTheme.errorRed,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                ),
                              ),
                              // Sağ taraf dikey kırmızı veya gri kaydırılabilir çizgi indikatörü
                              Container(
                                width: 4,
                                height: 72,
                                color: isImported ? const Color(0xFFCBD5E1) : AppTheme.errorRed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const Text(
            'Sıralama:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          // İşlem Gören Sıralama Butonu
          _buildSortButton(
            label: 'İşlem Gören',
            icon: Icons.playlist_add_check_rounded,
            isActive: _sortBy.startsWith('status'),
            isAscending: _sortBy == 'status_asc',
            onTap: () {
              setState(() {
                if (_sortBy == 'status_asc') {
                  _sortBy = 'status_desc';
                } else {
                  _sortBy = 'status_asc';
                }
                _sortTransactions();
              });
            },
          ),
          const SizedBox(width: 8),
          // Tarih Sıralama Butonu
          _buildSortButton(
            label: 'Tarih',
            icon: Icons.calendar_month_rounded,
            isActive: _sortBy.startsWith('date'),
            isAscending: _sortBy == 'date_asc',
            onTap: () {
              setState(() {
                if (_sortBy == 'date_desc') {
                  _sortBy = 'date_asc';
                } else {
                  _sortBy = 'date_desc';
                }
                _sortTransactions();
              });
            },
          ),
          const SizedBox(width: 8),
          // Tutar Sıralama Butonu
          _buildSortButton(
            label: 'Tutar',
            icon: Icons.currency_lira_rounded,
            isActive: _sortBy.startsWith('amount'),
            isAscending: _sortBy == 'amount_asc',
            onTap: () {
              setState(() {
                if (_sortBy == 'amount_desc') {
                  _sortBy = 'amount_asc';
                } else {
                  _sortBy = 'amount_desc';
                }
                _sortTransactions();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isAscending,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryCyan.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.primaryCyan : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppTheme.primaryCyan : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryCyan : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: AppTheme.primaryCyan,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
