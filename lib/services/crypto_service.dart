import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestione cifratura at-rest (AES-256) con chiave in secure storage.
class CryptoService {
  static const _secure = FlutterSecureStorage();
  static const _keyName = 'calistrack_enc_key';
  static const _flagName = 'calistrack_enc_enabled';

  static Future<bool> isEncryptionEnabled() async =>
      (await _secure.read(key: _flagName)) == 'true';

  static Future<void> setEncryptionFlag(bool v) async {
    if (v) {
      await _secure.write(key: _flagName, value: 'true');
    } else {
      await _secure.delete(key: _flagName);
    }
  }

  /// Genera (se assente) e restituisce la chiave AES-256 (32 byte).
  static Future<enc.Key> ensureKey() async {
    var hex = await _secure.read(key: _keyName);
    if (hex == null) {
      final rnd = Random.secure();
      final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
      hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _secure.write(key: _keyName, value: hex);
    }
    final keyBytes = Uint8List.fromList(
      List<int>.generate(
        32,
        (i) => int.parse(hex!.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
    return enc.Key(keyBytes);
  }

  static Future<String> encryptString(String plain) async {
    final key = await ensureKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final ct = encrypter.encrypt(plain, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...ct.bytes]);
    return base64.encode(combined);
  }

  static Future<String> decryptString(String data) async {
    final key = await ensureKey();
    final raw = base64.decode(data);
    final iv = enc.IV(Uint8List.fromList(raw.sublist(0, 16)));
    final ct = enc.Encrypted(Uint8List.fromList(raw.sublist(16)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt(ct, iv: iv);
  }
}
