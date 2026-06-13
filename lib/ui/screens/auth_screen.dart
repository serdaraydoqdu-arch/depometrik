import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:drift/drift.dart' as drift;
import '../theme/app_theme.dart';
import '../../core/sync/powersync_service.dart';
import '../../core/utils/aes_helper.dart';
import '../../core/utils/location_service.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/db_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _tcknController = TextEditingController();
  final _phoneController = TextEditingController();
  late final FocusNode _tcknFocusNode;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmailForm = false;
  bool _isDetailsStep = false;
  bool _isGoogleSignUp = false;
  bool _isSubmitting = false;
  String? _googleUserId;

  @override
  void initState() {
    super.initState();
    _tcknFocusNode = FocusNode();
    _tcknFocusNode.addListener(() {
      if (!_tcknFocusNode.hasFocus) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _tcknController.dispose();
    _phoneController.dispose();
    _tcknFocusNode.dispose();
    super.dispose();
  }

  Future<void> _detectAndSaveLocation() async {
    try {
      final city = await LocationService.detectCurrentCity();
      if (city != null) {
        await CityPreference.setCity(city);
      }
    } catch (e) {
      print('AuthScreen: Konum tespiti sırasında hata oluştu: $e');
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final supabase = Supabase.instance.client;

    if (_isDetailsStep) {
      // 2. Adım: Kayıt Tamamlama veya Google Profil Tamamlama
      setState(() {
        _isSubmitting = true;
      });
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final rawTckn = _tcknController.text.trim();
        final encryptedTckn = rawTckn.isNotEmpty ? AesHelper.encrypt(rawTckn) : null;
        final fullNameVal = _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null;
        final phoneVal = _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null;

        String? userId;
        Session? session;

        if (supabase.auth.currentSession != null) {
          // Zaten oturum açılmış (profil eksik olduğu için buradayız)
          userId = supabase.auth.currentSession!.user.id;
          session = supabase.auth.currentSession;
        } else if (_isGoogleSignUp) {
          // Google ile zaten oturum açıldı, sadece profil kaydedilecek
          userId = _googleUserId;
          session = supabase.auth.currentSession;
        } else {
          // E-posta ile normal kayıt
          final authResponse = await supabase.auth.signUp(
            email: email,
            password: password,
            data: {
              'full_name': fullNameVal,
              'phone_number': phoneVal,
              'tckn': encryptedTckn,
            },
          );
          userId = authResponse.user?.id;
          session = authResponse.session;
        }

        // Eğer e-posta doğrulaması gerekiyorsa ve aktif bir oturum yoksa
        if (supabase.auth.currentSession == null && session == null) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                bool isChecking = false;
                return StatefulBuilder(
                  builder: (context, setDialogState) {
                    return AlertDialog(
                      backgroundColor: AppTheme.lightSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.mark_email_unread_outlined, color: AppTheme.primaryTeal, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Doğrulama E-postası',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hesabınızı aktifleştirmek için lütfen $email adresine gönderdiğimiz doğrulama e-postasındaki bağlantıya tıklayın.',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'E-postanızı onayladıysanız lütfen "Onayladım" butonuna basın.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: isChecking ? null : () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Kapat',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isChecking ? null : () async {
                            setDialogState(() {
                              isChecking = true;
                            });

                            try {
                              final authResponse = await supabase.auth.signInWithPassword(
                                email: email,
                                password: password,
                              );

                              final userId = authResponse.user?.id;
                              if (userId != null) {
                                // Supabase veritabanından doğrudan güncel profili çek
                                final supabaseProfile = await supabase
                                    .from('profiles')
                                    .select()
                                    .eq('user_id', userId)
                                    .maybeSingle();

                                var fullName = supabaseProfile?['full_name'] as String?;
                                var phoneNumber = supabaseProfile?['phone_number'] as String?;
                                var rawTckn = supabaseProfile?['tckn'] as String?;

                                final metadata = authResponse.user?.userMetadata;
                                if (metadata != null) {
                                  fullName ??= metadata['full_name'] as String?;
                                  phoneNumber ??= metadata['phone_number'] as String?;
                                  rawTckn ??= metadata['tckn'] as String?;
                                }

                                if (fullName != null && fullName.isNotEmpty &&
                                    phoneNumber != null && phoneNumber.isNotEmpty) {
                                  try {
                                    await supabase.from('profiles').upsert({
                                      'user_id': userId,
                                      'email': email,
                                      'full_name': fullName,
                                      'tckn': rawTckn,
                                      'phone_number': phoneNumber,
                                      'premium_status': supabaseProfile?['premium_status'] as bool? ?? false,
                                    }, onConflict: 'user_id');
                                  } catch (e) {
                                    print('AuthScreen: Direct Supabase upsert error inside dialog: $e');
                                  }

                                  final db = DbService().database;
                                  await db.insertProfile(
                                    ProfilesCompanion(
                                      userId: drift.Value(userId),
                                      email: drift.Value(email),
                                      fullName: drift.Value(fullName),
                                      phoneNumber: drift.Value(phoneNumber),
                                      tckn: drift.Value(rawTckn),
                                      premiumStatus: drift.Value(supabaseProfile?['premium_status'] as bool? ?? false),
                                    ),
                                  );
                                }
                              }

                              // Konum algıla ve varsayılan yap
                              await _detectAndSaveLocation();

                              // PowerSync bağlantısını kur
                              await PowerSyncService().connectToSupabase();

                              if (context.mounted) {
                                Navigator.pop(context); // Dialog'u kapat
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                );
                              }
                            } catch (e) {
                              setDialogState(() {
                                isChecking = false;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('E-posta henüz doğrulanmamış olabilir. Lütfen doğrulama linkine tıkladığınızdan emin olun. Hata: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Onayladım',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
          return;
        }

        if (userId != null) {
          // 1. Supabase'e doğrudan kaydet
          try {
            await supabase.from('profiles').upsert({
              'user_id': userId,
              'email': email,
              'full_name': fullNameVal,
              'tckn': encryptedTckn,
              'phone_number': phoneVal,
              'premium_status': false,
            }, onConflict: 'user_id');
          } catch (e) {
            print('AuthScreen: Direct Supabase upsert error during completion: $e');
          }

          // 2. Yerel veritabanına kaydet
          final db = DbService().database;
          await db.insertProfile(
            ProfilesCompanion(
              userId: drift.Value(userId),
              email: drift.Value(email),
              fullName: drift.Value(fullNameVal),
              tckn: drift.Value(encryptedTckn),
              phoneNumber: drift.Value(phoneVal),
              premiumStatus: const drift.Value(false),
            ),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isGoogleSignUp ? 'Profiliniz başarıyla tamamlandı!' : 'Kayıt başarıyla tamamlandı! Hoş geldiniz.'),
              backgroundColor: AppTheme.primaryTeal,
            ),
          );
        }

        // Konum algıla ve varsayılan yap
        await _detectAndSaveLocation();

        // Oturum başarılı ise PowerSync senkronizasyonunu başlat
        await PowerSyncService().connectToSupabase();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          // Eğer e-posta zaten kayıtlıysa
          if (!_isGoogleSignUp && (e.message.toLowerCase().contains('already registered') || 
              e.message.toLowerCase().contains('already exists') ||
              e.statusCode == '422' || 
              e.message.toLowerCase().contains('user_already_exists'))) {
            _showUserExistsDialog(email);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Beklenmeyen bir hata oluştu: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // 1. Adım: Giriş Denemesi
      setState(() {
        _isSubmitting = true;
      });
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final authResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final userId = authResponse.user?.id;
        if (userId != null) {
          // Supabase veritabanından doğrudan güncel profili çek (RLS izin verir çünkü artık yetkiliyiz)
          final supabaseProfile = await supabase
              .from('profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

          var fullName = supabaseProfile?['full_name'] as String?;
          var phoneNumber = supabaseProfile?['phone_number'] as String?;
          var rawTckn = supabaseProfile?['tckn'] as String?;

          // Eğer Supabase'de eksikse, auth metadata'dan almayı dene (Otomatik eşitleme için)
          final metadata = authResponse.user?.userMetadata;
          if (metadata != null) {
            fullName ??= metadata['full_name'] as String?;
            phoneNumber ??= metadata['phone_number'] as String?;
            rawTckn ??= metadata['tckn'] as String?;
          }

          // Eğer metadata'dan veya doğrudan profilden veriler tamsa, Supabase ve yerel DB'ye kaydedelim
          if (fullName != null && fullName.isNotEmpty &&
              phoneNumber != null && phoneNumber.isNotEmpty) {
            try {
              await supabase.from('profiles').upsert({
                'user_id': userId,
                'email': email,
                'full_name': fullName,
                'tckn': rawTckn,
                'phone_number': phoneNumber,
                'premium_status': supabaseProfile?['premium_status'] as bool? ?? false,
              }, onConflict: 'user_id');
            } catch (e) {
              print('AuthScreen: Direct Supabase upsert error during automatic sync: $e');
            }

            final db = DbService().database;
            await db.insertProfile(
              ProfilesCompanion(
                userId: drift.Value(userId),
                email: drift.Value(email),
                fullName: drift.Value(fullName),
                phoneNumber: drift.Value(phoneNumber),
                tckn: drift.Value(rawTckn),
                premiumStatus: drift.Value(supabaseProfile?['premium_status'] as bool? ?? false),
              ),
            );
          } else {
            // Hala eksikse profil tamamlamaya yönlendir
            String decryptedTckn = '';
            if (rawTckn != null && rawTckn.isNotEmpty) {
              try {
                decryptedTckn = AesHelper.decrypt(rawTckn);
              } catch (_) {}
            }

            // Metadata'da kayıtlı olan varsa onu da prefill edelim
            final metadataPhone = metadata?['phone_number'] as String?;

            setState(() {
              _isGoogleSignUp = false; // E-posta ile devam ediyoruz
              _isDetailsStep = true;
              _showEmailForm = true;
              _isSubmitting = false;
              _fullNameController.text = fullName ?? '';
              _phoneController.text = (phoneNumber ?? metadataPhone) != null 
                  ? PhoneInputFormatter.format(phoneNumber ?? metadataPhone!) 
                  : '';
              _tcknController.text = decryptedTckn;
              _isLoading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lütfen profilinizi tamamlamak için eksik bilgileri girin.'),
                  backgroundColor: AppTheme.primaryTeal,
                ),
              );
            }
            return;
          }
        }

        // Konum algıla ve varsayılan yap
        await _detectAndSaveLocation();

        // Oturum başarılı ise PowerSync senkronizasyonunu başlat
        await PowerSyncService().connectToSupabase();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          final errorMsg = e.message.toLowerCase().contains('invalid login credentials')
              ? 'E-posta adresi veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.'
              : e.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Beklenmeyen bir hata oluştu: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showUserExistsDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.primaryTeal, size: 28),
              SizedBox(width: 10),
              Text(
                'Zaten Kayıtlı Hesap',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            '$email adresiyle kayıtlı bir hesap zaten mevcuttur. Girdiğiniz şifre hatalı olabilir. Lütfen şifrenizi kontrol ederek tekrar giriş yapmayı deneyin.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isDetailsStep = false;
                });
              },
              child: const Text(
                'Giriş Ekranına Dön',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isValidTckn(String tckn) {
    if (tckn.length != 11) return false;
    if (tckn.startsWith('0')) return false;

    try {
      final List<int> digits = tckn.split('').map((char) => int.parse(char)).toList();
      
      final int sumOdd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
      final int sumEven = digits[1] + digits[3] + digits[5] + digits[7];
      
      final int d10 = (((sumOdd * 7) - sumEven) % 10 + 10) % 10;
      if (d10 != digits[9]) return false;
      
      final int sumFirst10 = digits.sublist(0, 10).reduce((a, b) => a + b);
      final int d11 = sumFirst10 % 10;
      if (d11 != digits[10]) return false;
      
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '384329983536-2qlbhjamvu8lce2v9cbtb077ffntu9tt.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // Geliştirici veya kullanıcı iptal etti
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Google ID Token alınamadı.');
      }

      final authResponse = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Oturum açan kullanıcının profilini yerel veritabanına kaydet (Varsa güncel bilgileri çekip yerel veritabanına yazar)
      final userId = authResponse.user?.id;
      final email = authResponse.user?.email;
      if (userId != null) {
        final db = DbService().database;
        
        final supabaseProfile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        final fullName = supabaseProfile?['full_name'] as String?;
        final phoneNumber = supabaseProfile?['phone_number'] as String?;
        final rawTckn = supabaseProfile?['tckn'] as String?;
        final emailVal = supabaseProfile?['email'] as String? ?? email;
        final premiumVal = supabaseProfile?['premium_status'] as bool? ?? false;

        await db.insertProfile(
          ProfilesCompanion(
            userId: drift.Value(userId),
            email: drift.Value(emailVal),
            fullName: drift.Value(fullName),
            phoneNumber: drift.Value(phoneNumber),
            tckn: drift.Value(rawTckn),
            premiumStatus: drift.Value(premiumVal),
          ),
        );
      }

      // Konum algıla ve varsayılan yap
      await _detectAndSaveLocation();

      // PowerSync bağlantısını başlat
      await PowerSyncService().connectToSupabase();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oturum Açma Hatası: ${e.message}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Girişi Başarısız: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted && !_isGoogleSignUp) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showHelpDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANLADIM', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ve Başlık
                const Center(
                  child: Text(
                    'DEPOMETRİK',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Akaryakıt Verimlilik & Analiz Platformu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // 1. GOOGLE ILE GIRIS BOX (Sayfayı ortalayacak şekilde en üstte)
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderLight,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _isLoading ? null : _handleGoogleSignIn,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google 'G' Logosu Çizimi
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: GoogleLogoPainter(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Google ile Giriş Yap',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. E-POSTA ILE GIRIS/KAYIT BOX (Açılır/Kapanır Yapıda Alt Bölüm)
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showEmailForm ? AppTheme.primaryTeal : AppTheme.borderLight,
                      width: _showEmailForm ? 2.0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık / Açma-Kapama Çubuğu
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showEmailForm = !_showEmailForm;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: _showEmailForm ? AppTheme.primaryTeal : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'E-posta ile Oturum Aç',
                                style: TextStyle(
                                  color: _showEmailForm ? AppTheme.primaryTeal : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _showEmailForm ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: _showEmailForm ? AppTheme.primaryTeal : AppTheme.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Animasyonlu Açılır Form İçeriği
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Divider(color: AppTheme.borderLight, height: 1),
                                if (!_isDetailsStep) ...[
                                  // E-posta Girişi
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'E-posta *',
                                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
                                      hintText: 'ornek@depometrik.com',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Lütfen e-posta adresinizi girin.';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                        return 'Lütfen geçerli bir e-posta adresi girin.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Şifre Girişi
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleEmailAuth(),
                                    decoration: InputDecoration(
                                      labelText: 'Şifre *',
                                      prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.primaryTeal),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: AppTheme.textSecondary,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Lütfen şifrenizi girin.';
                                      }
                                      if (value.length < 6) {
                                        return 'Şifre en az 6 karakter olmalıdır.';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else ...[
                                  // Kayıt Modu Ekstra Alanları (Adım 2: Zorunlu Ad Soyad ve Telefon No, İsteğe Bağlı TCKN)
                                  const SizedBox(height: 20),
                                  // Kilitli E-posta
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      labelText: 'E-posta',
                                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Adı Soyadı
                                  TextFormField(
                                    controller: _fullNameController,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: 'Ad Soyad *',
                                      prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryTeal),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.help_outline, color: AppTheme.textSecondary),
                                        onPressed: () => _showHelpDialog(
                                          'Ad Soyad Neden İsteniyor?',
                                          'Profilinizi kişiselleştirmek ve işlemlerinizi kolaylaştırmak amacıyla alınır. Girilmesi zorunludur.',
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Lütfen adınızı ve soyadınızı girin.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Telefon
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [PhoneInputFormatter()],
                                    decoration: InputDecoration(
                                      labelText: 'Telefon No *',
                                      hintText: '(530) 123 45 67',
                                      prefixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 12),
                                          const Icon(Icons.phone_outlined, color: AppTheme.primaryTeal),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '+90',
                                            style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 1,
                                            height: 18,
                                            color: AppTheme.borderLight,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.help_outline, color: AppTheme.textSecondary),
                                        onPressed: () => _showHelpDialog(
                                          'Telefon Numarası Neden İsteniyor?',
                                          'Çift aşamalı hesap güvenliği (2FA) veya kritik bildirim alımları (örneğin otopark dolumu) için gereklidir. Girilmesi zorunludur.',
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Lütfen telefon numaranızı girin.';
                                      }
                                      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                                      if (digitsOnly.length != 10) {
                                        return 'Telefon numarası 10 haneli olmalıdır.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // TCKN
                                  TextFormField(
                                    controller: _tcknController,
                                    focusNode: _tcknFocusNode,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleEmailAuth(),
                                    maxLength: 11,
                                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: 'TC Kimlik No (İsteğe Bağlı)',
                                      prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryTeal),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.help_outline, color: AppTheme.textSecondary),
                                        onPressed: () => _showHelpDialog(
                                          'TCKN Neden İsteniyor?',
                                          'KVKK/GDPR uyumluluğu kapsamında bu alan tamamen isteğe bağlıdır. '
                                          'Gelecekte resmi fatura veya elektronik ödeme işlemleri yapacağınız zaman istenir. '
                                          'TCKN bilginiz cihazınızda AES-256 standardında şifrelenir ve veritabanımızda asla açık metin olarak tutulmaz.',
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return null; // isteğe bağlı
                                      if (!_isSubmitting && _tcknFocusNode.hasFocus && value.length < 11) {
                                        return null;
                                      }
                                      if (value.length != 11) {
                                        return 'T.C. Kimlik Numarası 11 haneli olmalıdır.';
                                      }
                                      if (!_isValidTckn(value)) {
                                        return 'Geçersiz T.C. Kimlik Numarası.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                
                                const SizedBox(height: 28),
                                
                                // E-posta Giriş/Kayıt / Devam Et Butonu
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleEmailAuth,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _isDetailsStep ? 'KAYIT OL' : 'GİRİŞ YAP',
                                        ),
                                ),
                                
                                // Geri Dön Butonu (Sadece 2. Adımda Gösterilir)
                                // Hesabınız yok mu? Yeni Hesap Oluştur
                                if (!_isDetailsStep) ...[
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _isDetailsStep = true;
                                            });
                                          },
                                    child: const Text(
                                      'Hesabınız yok mu? Yeni Hesap Oluştur',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ],

                                // Geri Dön Butonu (Sadece 2. Adımda Gösterilir)
                                if (_isDetailsStep) ...[
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            if (_isGoogleSignUp) {
                                              // Kayıt tamamlanmadan geri çıkılıyorsa Supabase oturumunu kapat
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              try {
                                                await Supabase.instance.client.auth.signOut();
                                              } catch (_) {}
                                            }
                                            setState(() {
                                              _isDetailsStep = false;
                                              _isGoogleSignUp = false;
                                              _googleUserId = null;
                                              _isLoading = false;
                                            });
                                          },
                                    child: const Text(
                                      'Geri Dön',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        crossFadeState: _showEmailForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Google Logosu Custom Painter
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;

    final Paint paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final Paint paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final Paint paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final Paint paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;

    // Kırmızı Yay
    final Path pathRed = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - r * 0.7, cy - r * 0.7)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -2.356, // -135 deg
        1.571,  // 90 deg
        false,
      )
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    // Sarı Yay
    final Path pathYellow = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - r * 0.7, cy + r * 0.7)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        2.356,  // 135 deg
        -1.571, // -90 deg
        false,
      )
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    // Yeşil Yay
    final Path pathGreen = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + r * 0.7, cy + r * 0.7)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        0.785,  // 45 deg
        1.571,  // 90 deg
        false,
      )
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    // Mavi Yay ve İç Çizgi
    final Path pathBlue = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + r, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        0.0,
        -0.785, // -45 deg
        false,
      )
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);

    // Mavi Orta Çubuk
    final Path pathBlueBar = Path()
      ..moveTo(cx, cy - r * 0.25)
      ..lineTo(cx + r * 0.95, cy - r * 0.25)
      ..lineTo(cx + r * 0.95, cy + r * 0.15)
      ..lineTo(cx + r * 0.4, cy + r * 0.15)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(pathBlueBar, paintBlue);

    // Beyaz Maske (Ortadaki dairesel oyuk için)
    final Paint paintWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Telefon Numarası Formatlayıcı
class PhoneInputFormatter extends TextInputFormatter {
  static String format(String text) {
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
    final digits = cleanText.length > 10 ? cleanText.substring(0, 10) : cleanText;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(digits[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 5) {
        buffer.write(' ');
      } else if (i == 7) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
    final digits = cleanText.length > 10 ? cleanText.substring(0, 10) : cleanText;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(digits[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 5) {
        buffer.write(' ');
      } else if (i == 7) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    int selectionIndex = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
