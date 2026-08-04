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
  // Densita' fissa su Normale.
  final UiDensity _density = UiDensity.comfortable;
  String _appIconId = 'IconDefault';
  bool ready = false;

  AppSkin get skin => appThemes[_themeId] ?? appThemes[defaultThemeId]!;
  String get themeId => _themeId;

  /// Colori del tema selezionato.
  AppColors get colors => skin.colors;

  UiDensity get density => _density;
  double get densityScale => _density.scale;

  /// Lo stile delle card e' determinato dal tema selezionato (non scelto
  /// liberamente dall'utente).
  CardStyle get cardStyle => skin.effectiveCardStyle;
  bool get glow => _glow;

  String get appIconId => _appIconId;

  /// Lo stile dell'emblema e' determinato dal tema (neon -> glow, altrimenti
  /// classic), non scelto liberamente dall'utente.
  EmblemStyle get emblemStyle =>
      skin.neon ? EmblemStyle.glow : EmblemStyle.classic;

  /// Nome dell'app attualmente mostrato nel launcher (dock).
  String get launcherName => launcherAppName(_appIconId);

  /// Soggetto dell'emblema attivo: determinato dal tema selezionato.
  String? get activeEmblemSubject => emblemForTheme(_themeId);

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
    final icon = await StorageService.getString(StorageService.appIconKey);
    if (icon != null) _appIconId = icon;
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

  bool isUnlocked(String id) => _unlocked.contains(id);

  /// Un'icona premium e' sbloccata quando lo e' il tema associato.
  bool isIconUnlocked(AppIconStyle icon) =>
      !icon.premium || (icon.themeId != null && isUnlocked(icon.themeId!));

  bool isIconIdUnlocked(String iconId) {
    final icon = AppIconService.styles.firstWhere((s) => s.id == iconId,
        orElse: () => AppIconService.styles.first);
    return isIconUnlocked(icon);
  }

  Future<void> changeTheme(String id) async {
    if (!appThemes.containsKey(id)) return;
    _themeId = id;
    FeedbackService.setPack(soundPackForTheme(id));
    await StorageService.setString(StorageService.themeKey, id);
    // L'icona dell'app segue sempre il tema selezionato.
    await _applyIconForTheme();
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

  /// Sblocca più temi in un'unica operazione (acquisto in blocco).
  Future<void> unlockMany(Iterable<String> ids) async {
    _unlocked.addAll(ids);
    final toSave = _unlocked.where((e) => !freeThemeIds.contains(e)).toList();
    await StorageService.setStringList(StorageService.unlockedKey, toSave);
    notifyListeners();
  }
}
