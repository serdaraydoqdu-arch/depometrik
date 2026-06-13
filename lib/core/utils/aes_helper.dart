import 'package:encrypt/encrypt.dart' as enc;

class AesHelper {
  // 32-byte key for AES-256
  static final _key = enc.Key.fromUtf8('depometrik_tckn_aes256_key_32_ch');
  // 16-byte initialization vector (IV) for CBC mode
  static final _iv = enc.IV.fromUtf8('depometrik_iv_16');
  static final _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  /// Encrypts plain text into AES-256 Base64 ciphertext
  static String encrypt(String text) {
    if (text.trim().isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(text.trim(), iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('AesHelper: Encryption error: $e');
      return '';
    }
  }

  /// Decrypts AES-256 Base64 ciphertext back to plain text
  static String decrypt(String encryptedBase64) {
    if (encryptedBase64.trim().isEmpty) return '';
    try {
      final decrypted = _encrypter.decrypt64(encryptedBase64.trim(), iv: _iv);
      return decrypted;
    } catch (e) {
      print('AesHelper: Decryption error: $e');
      return encryptedBase64; // Return original if decryption fails
    }
  }
}
