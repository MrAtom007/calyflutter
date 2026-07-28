import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/emblem.dart';
import '../services/storage_service.dart';
import '../services/feedback_service.dart';
import '../services/app_icon_service.dart';

/// Gestisce skin attivo, glow e temi sbloccati.
class ThemeProvider extends ChangeNotifier {
  String _themeId = defaultThemeId;
  bool _glow = true;
  Set<String> _unlocked = {...freeThemeIds};
  String _accentId = 'default';
  UiDensity _density = UiDensity.comfortable;
  CardStyle _cardStyle = CardStyle.solid;
  String _appIconId = 'IconDefault';
  EmblemStyle _emblemStyle = EmblemStyle.classic;
  bool _emblemFollowIcon = true;
  bool _iconFollowsTheme = false;
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

  String get appIconId => _appIconId;
  EmblemStyle get emblemStyle => _emblemStyle;
  bool get emblemFollowIcon => _emblemFollowIcon;
  bool get iconFollowsTheme => _iconFollowsTheme;

  /// Nome dell'app attualmente mostrato nel launcher (dock).
  String get launcherName => launcherAppName(_appIconId);

  /// Soggetto dell'emblema attivo: segue l'icona app oppure il tema.
  String? get activeEmblemSubject => _emblemFollowIcon
      ? emblemForIcon(_appIconId)
      : emblemForTheme(_themeId);

  /// Il glow è attivo solo per i temi neon con glow abilitato.
  bool get glowActive => skin.neon && _glow;
  Set<String> get unlocked => _unlocked;

  Future<void> load() async {
    final id = await StorageService.getString(StorageService.themeKey);
    if (id != null && appThemes.containsKey(id)) _themeId = id;
    FeedbackService.setPack(soundPackForTheme(_themeId));
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
    final icon = await StorageService.getString(StorageService.appIconKey);
    if (icon != null) _appIconId = icon;
    final es = await StorageService.getString(StorageService.emblemStyleKey);
    if (es != null) {
      _emblemStyle = EmblemStyle.values
          .firstWhere((e) => e.name == es, orElse: () => EmblemStyle.classic);
    }
    final ef = await StorageService.getBool(StorageService.emblemFollowKey);
    if (ef != null) _emblemFollowIcon = ef;
    final ift = await StorageService.getBool(StorageService.iconFollowThemeKey);
    if (ift != null) _iconFollowsTheme = ift;
    ready = true;
    notifyListeners();
  }

  /// Applica l'icona (e quindi il nome nel launcher) coerente col tema attivo.
  Future<void> _applyIconForTheme() async {
    final alias = iconAliasForSubject(emblemForTheme(_themeId));
    if (alias == _appIconId) return;
    final ok = await AppIconService.setIcon(alias);
    if (ok) _appIconId = alias;
  }

  Future<void> setIconFollowsTheme(bool v) async {
    _iconFollowsTheme = v;
    await StorageService.setBool(StorageService.iconFollowThemeKey, v);
    if (v) await _applyIconForTheme();
    notifyListeners();
  }

  Future<void> setAppIcon(String id) async {
    _appIconId = id;
    await StorageService.setString(StorageService.appIconKey, id);
    notifyListeners();
  }

  Future<void> setEmblemStyle(EmblemStyle s) async {
    _emblemStyle = s;
    await StorageService.setString(StorageService.emblemStyleKey, s.name);
    notifyListeners();
  }

  Future<void> setEmblemFollowIcon(bool v) async {
    _emblemFollowIcon = v;
    await StorageService.setBool(StorageService.emblemFollowKey, v);
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
    FeedbackService.setPack(soundPackForTheme(id));
    await StorageService.setString(StorageService.themeKey, id);
    if (_iconFollowsTheme) await _applyIconForTheme();
    notifyListeners();
  }

  /// Applica un tema casuale tra quelli sbloccati (diverso dall'attuale).
  Future<void> randomTheme() async {
    final ids =
        appThemes.keys.where((id) => id != _themeId && isUnlocked(id)).toList();
    if (ids.isEmpty) return;
    ids.shuffle();
    await changeTheme(ids.first);
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
