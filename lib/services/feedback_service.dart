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

  /// Pacchetto sonoro attivo (cartella in `assets/sounds/<pack>/`).
  /// Impostato in base al tema attivo.
  static String pack = 'clean';

  static void setPack(String p) {
    if (p == pack) return;
    pack = p;
    // I player sono legati al percorso del file: svuota la cache così
    // il prossimo suono usa il nuovo pacchetto.
    for (final pl in _players.values) {
      pl.dispose();
    }
    _players.clear();
  }

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
      final player = _players.putIfAbsent(name, () {
        final p = AudioPlayer();
        // Riproduce sul canale multimediale a volume pieno, senza abbassare
        // gli altri suoni (mix), per la massima udibilità in palestra.
        p.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient,
              options: const {AVAudioSessionOptions.mixWithOthers},
            ),
          ),
        );
        return p;
      });
      await player.stop();
      await player.setVolume(volume);
      await player.play(AssetSource('sounds/$pack/$name.wav'));
    } catch (_) {}
  }

  static void tap() => _play('tap', volume: 0.55);
  static void beep() => _play('beep', volume: 0.85);
  static void success() => _play('success', volume: 0.9);
  static void complete() => _play('complete', volume: 0.9);
  static void levelUp() => _play('levelup', volume: 0.95);
  static void unlock() => _play('unlock', volume: 0.9);

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
    // Suono (rispetta lo switch Effetti sonori) + haptic ritmico sincronizzato.
    levelUp();
    if (!hapticsEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
      Future.delayed(
        const Duration(milliseconds: 90),
        HapticFeedback.mediumImpact,
      );
    });
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
