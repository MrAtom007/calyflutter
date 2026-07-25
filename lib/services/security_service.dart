import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LockMode {
  static const none = 'none';
  static const pin = 'pin';
  static const device = 'device';
}

class LockPolicy {
  static const launch = 'launch';
  static const grace = 'grace';
  static const immediate = 'immediate';
}

const int graceMs = 2 * 60 * 1000;

class SecuritySupport {
  final bool biometricAvailable;
  final String biometricLabel;
  final bool deviceLockAvailable;
  const SecuritySupport(
      this.biometricAvailable, this.biometricLabel, this.deviceLockAvailable);
}

/// Sicurezza: PIN, biometria, blocco dispositivo.
class SecurityService {
  static const _secure = FlutterSecureStorage();
  static final _auth = LocalAuthentication();

  static const _modeKey = 'calistrack_lock_mode';
  static const _pinHashKey = 'calistrack_pin_hash';
  static const _pinSaltKey = 'calistrack_pin_salt';
  static const _bioQuickKey = 'calistrack_bio_quick';
  static const _policyKey = 'calistrack_lock_policy';

  static String _sha256(String v) => sha256.convert(utf8.encode(v)).toString();

  static String _randomSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<String> getLockMode() async =>
      (await _secure.read(key: _modeKey)) ?? LockMode.none;

  static Future<String> getLockPolicy() async =>
      (await _secure.read(key: _policyKey)) ?? LockPolicy.launch;

  static Future<void> setLockPolicy(String p) async =>
      _secure.write(key: _policyKey, value: p);

  static Future<void> disableLock() async {
    await _secure.delete(key: _pinHashKey);
    await _secure.delete(key: _pinSaltKey);
    await _secure.delete(key: _bioQuickKey);
    await _secure.write(key: _modeKey, value: LockMode.none);
  }

  static Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    await _secure.write(key: _pinSaltKey, value: salt);
    await _secure.write(key: _pinHashKey, value: _sha256(salt + pin));
    await _secure.write(key: _modeKey, value: LockMode.pin);
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(key: _pinSaltKey);
    final stored = await _secure.read(key: _pinHashKey);
    if (salt == null || stored == null) return false;
    return _sha256(salt + pin) == stored;
  }

  static Future<void> setDeviceMode() async =>
      _secure.write(key: _modeKey, value: LockMode.device);

  static Future<bool> isBioQuickEnabled() async =>
      (await _secure.read(key: _bioQuickKey)) == 'true';

  static Future<void> setBioQuickEnabled(bool v) async =>
      _secure.write(key: _bioQuickKey, value: v ? 'true' : 'false');

  static Future<SecuritySupport> getSecuritySupport() async {
    try {
      final hasHw = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      final isFace = types.contains(BiometricType.face);
      return SecuritySupport(
        hasHw && canCheck && types.isNotEmpty,
        isFace ? 'Face ID' : 'Impronta digitale',
        hasHw,
      );
    } catch (_) {
      return const SecuritySupport(false, 'Impronta digitale', false);
    }
  }

  static Future<bool> authenticateBiometric() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Sblocca CaliStrack',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateDevice() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Sblocca CaliStrack',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } catch (_) {
      return false;
    }
  }
}
