import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

/// Gestisce skin attivo, glow e temi sbloccati.
class ThemeProvider extends ChangeNotifier {
  String _themeId = defaultThemeId;
  bool _glow = true;
  Set<String> _unlocked = {...freeThemeIds};
  bool ready = false;

  AppSkin get skin => appThemes[_themeId] ?? appThemes[defaultThemeId]!;
  String get themeId => _themeId;
  AppColors get colors => skin.colors;
  bool get glow => _glow;

  /// Il glow è attivo solo per i temi neon con glow abilitato.
  bool get glowActive => skin.neon && _glow;
  Set<String> get unlocked => _unlocked;

  Future<void> load() async {
    final id = await StorageService.getString(StorageService.themeKey);
    if (id != null && appThemes.containsKey(id)) _themeId = id;
    final g = await StorageService.getBool(StorageService.glowKey);
    if (g != null) _glow = g;
    final saved = await StorageService.getStringList(StorageService.unlockedKey);
    _unlocked = {...freeThemeIds, ...saved};
    ready = true;
    notifyListeners();
  }

  bool isUnlocked(String id) => _unlocked.contains(id);

  Future<void> changeTheme(String id) async {
    if (!appThemes.containsKey(id)) return;
    _themeId = id;
    await StorageService.setString(StorageService.themeKey, id);
    notifyListeners();
  }

  Future<void> toggleGlow(bool v) async {
    _glow = v;
    await StorageService.setBool(StorageService.glowKey, v);
    notifyListeners();
  }

  Future<void> unlock(String id) async {
    _unlocked.add(id);
    final toSave = _unlocked.where((e) => !freeThemeIds.contains(e)).toList();
    await StorageService.setStringList(StorageService.unlockedKey, toSave);
    notifyListeners();
  }
}
