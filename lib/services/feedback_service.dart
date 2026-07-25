import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'storage_service.dart';

/// Suoni + vibrazioni centralizzati, con toggle persistenti.
class FeedbackService {
  static const _soundKey = '@calistrack/sound';
  static const _hapticsKey = '@calistrack/haptics';

  static bool soundEnabled = true;
  static bool hapticsEnabled = true;
  static bool _hasVibrator = false;

  static final Map<String, AudioPlayer> _players = {};

  static Future<void> init() async {
    soundEnabled = (await StorageService.getBool(_soundKey)) ?? true;
    hapticsEnabled = (await StorageService.getBool(_hapticsKey)) ?? true;
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
  }

  static Future<void> setSound(bool v) async {
    soundEnabled = v;
    await StorageService.setBool(_soundKey, v);
  }

  static Future<void> setHaptics(bool v) async {
    hapticsEnabled = v;
    await StorageService.setBool(_hapticsKey, v);
  }

  // ---------------- Suoni ----------------
  static Future<void> _play(String name, {double volume = 1.0}) async {
    if (!soundEnabled) return;
    try {
      final player = _players.putIfAbsent(name, () => AudioPlayer());
      await player.stop();
      await player.setVolume(volume);
      await player.play(AssetSource('sounds/$name.wav'));
    } catch (_) {}
  }

  static void tap() => _play('tap', volume: 0.6);
  static void beep() => _play('beep', volume: 0.7);
  static void success() => _play('success');
  static void complete() => _play('complete');
  static void levelUp() => _play('levelup');
  static void unlock() => _play('unlock');

  // ---------------- Vibrazioni ----------------
  static void _vibrate({List<int>? pattern}) {
    if (!hapticsEnabled) return;
    if (_hasVibrator && (pattern != null)) {
      try {
        Vibration.vibrate(pattern: pattern);
        return;
      } catch (_) {}
    }
  }

  static void selection() {
    if (!hapticsEnabled) return;
    HapticFeedback.selectionClick();
  }

  static void light() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  static void medium() {
    if (!hapticsEnabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (!hapticsEnabled) return;
    HapticFeedback.heavyImpact();
  }

  // Combinazioni tematiche (suono + vibrazione)
  static void onTap() {
    tap();
    selection();
  }

  static void onSuccess() {
    success();
    _vibrate(pattern: [0, 40, 60, 80]);
    medium();
  }

  static void onLevelUp() {
    levelUp();
    _vibrate(pattern: [0, 60, 80, 120, 80, 200]);
    heavy();
  }

  static void onComplete() {
    complete();
    _vibrate(pattern: [0, 300, 150, 300]);
  }

  static void onUnlock() {
    unlock();
    _vibrate(pattern: [0, 50, 40, 120]);
    medium();
  }
}
