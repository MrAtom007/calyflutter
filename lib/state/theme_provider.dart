import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

/// Gestisce skin attivo, glow e temi sbloccati.
class ThemeProvider extends ChangeNotifier {
  String _themeId = defaultThemeId;
  bool _glow = true;
  Set<String> _unlocked = {...freeThemeIds};
  String _accentId = 'default';
  UiDensity _density = UiDensity.comfortable;
  CardStyle _cardStyle = CardStyle.solid;
  bool ready = false;

  AppSkin get skin => appThemes[_themeId] ?? appThemes[defaultThemeId]!;
  String get themeId => _themeId;

  /// Colori effettivi, con eventuale accento personalizzato applicato.
  AppColors get colors {
    final accent = accentById(_accentId);
    if (accent == null) return skin.colors;
    return skin.colors.copyWith(primary: accent.color, primaryDark: accent.dark);
  }

  String get accentId => _accentId;
  UiDensity get density => _density;
  double get densityScale => _density.scale;
  CardStyle get cardStyle => _cardStyle;
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
    final acc = await StorageService.getString(StorageService.accentKey);
    if (acc != null && accentOptions.any((a) => a.id == acc)) _accentId = acc;
    final den = await StorageService.getString(StorageService.densityKey);
    if (den != null) {
      _density = UiDensity.values.firstWhere((d) => d.name == den,
          orElse: () => UiDensity.comfortable);
    }
    final cs = await StorageService.getString(StorageService.cardStyleKey);
    if (cs != null) {
      _cardStyle = CardStyle.values
          .firstWhere((c) => c.name == cs, orElse: () => CardStyle.solid);
    }
    ready = true;
    notifyListeners();
  }

  Future<void> setAccent(String id) async {
    _accentId = id;
    await StorageService.setString(StorageService.accentKey, id);
    notifyListeners();
  }

  Future<void> setDensity(UiDensity d) async {
    _density = d;
    await StorageService.setString(StorageService.densityKey, d.name);
    notifyListeners();
  }

  Future<void> setCardStyle(CardStyle c) async {
    _cardStyle = c;
    await StorageService.setString(StorageService.cardStyleKey, c.name);
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
