import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Uno stile di icona dell'app (alias nativo + anteprima in-app).
class AppIconStyle {
  final String id; // alias nativo Android (es. IconZeus)
  final String name;
  final List<Color> bg; // gradiente sfondo anteprima (fallback)
  final Color bolt; // colore accento
  final String asset; // immagine emblema (vuoto = usa glyph di fallback)
  final IconData glyph; // icona di fallback quando manca l'asset
  final String appName; // nome mostrato nel launcher (dock)

  const AppIconStyle(this.id, this.name, this.bg, this.bolt, this.asset,
      {this.glyph = Icons.bolt_rounded, this.appName = 'CaliStrack'});

  bool get hasAsset => asset.isNotEmpty;
}

/// Nome dell'app nel launcher associato a un alias icona.
String launcherAppName(String alias) {
  for (final s in AppIconService.styles) {
    if (s.id == alias) return s.appName;
  }
  return 'CaliTrack';
}

/// Mappa un id tema epico all'emblema corrispondente (o null).
String? themeEmblemAsset(String themeId) {
  const map = {
    'ulisse': 'assets/icon_previews/ulisse.png',
    'zeus': 'assets/icon_previews/zeus.png',
    'cyberpunk': 'assets/icon_previews/cyberpunk.png',
    'spartacus': 'assets/icon_previews/spartacus.png',
    'kratos': 'assets/icon_previews/kratos.png',
  };
  return map[themeId];
}

class AppIconService {
  static const _channel = MethodChannel('calistrack/app_icon');

  // I nomi combaciano con i temi epici dell'app.
  static const List<AppIconStyle> styles = [
    AppIconStyle('IconDefault', 'Ulisse', [Color(0xff1F526D), Color(0xff08161F)],
        Color(0xffF3C75A), 'assets/icon_previews/ulisse.png',
        appName: 'CaliTrack'),
    AppIconStyle('IconZeus', 'Zeus', [Color(0xff303B5C), Color(0xff0B0E16)],
        Color(0xffFFD85A), 'assets/icon_previews/zeus.png', appName: 'ZeusTrack'),
    AppIconStyle('IconCyberpunk', 'Cyberpunk', [Color(0xff320E44), Color(0xff07030D)],
        Color(0xffFF3AD0), 'assets/icon_previews/cyberpunk.png',
        appName: 'CyberTrack'),
    AppIconStyle('IconSpartacus', 'Spartacus', [Color(0xffCF4233), Color(0xff1A0A09)],
        Color(0xffE9B45A), 'assets/icon_previews/spartacus.png',
        appName: 'SpartanTrack'),
    AppIconStyle('IconKratos', 'Kratos', [Color(0xff442727), Color(0xff0E0F12)],
        Color(0xffEE4A40), 'assets/icon_previews/kratos.png', appName: 'KratosFit'),
    // Nuove icone (anteprima vettoriale, senza PNG dedicato).
    AppIconStyle('IconSynthwave', 'Synthwave',
        [Color(0xff2A0A54), Color(0xff0D0221)], Color(0xffFF2EC4), '',
        glyph: Icons.wb_sunny_rounded, appName: 'SynthTrack'),
    AppIconStyle('IconValkyrie', 'Valkyrie',
        [Color(0xff2A323B), Color(0xff0B0E12)], Color(0xffD7DEE6), '',
        glyph: Icons.flight_rounded, appName: 'ValkyrieFit'),
    AppIconStyle('IconRonin', 'Ronin',
        [Color(0xff2E1516), Color(0xff0B0808)], Color(0xffC0392B), '',
        glyph: Icons.brightness_1_rounded, appName: 'RoninTrack'),
    AppIconStyle('IconAnubis', 'Anubis',
        [Color(0xff16233F), Color(0xff070A12)], Color(0xffF2C14E), '',
        glyph: Icons.ac_unit_rounded, appName: 'AnubisFit'),
    AppIconStyle('IconAchille', 'Achille',
        [Color(0xff3A2A12), Color(0xff0C0A08)], Color(0xffCF9B3C), '',
        glyph: Icons.shield_moon_rounded, appName: 'AchilleTrack'),
    AppIconStyle('IconLeonida', 'Leonida',
        [Color(0xff3A1512), Color(0xff120707)], Color(0xffD13B2F), '',
        glyph: Icons.security_rounded, appName: 'LeonidaTrack'),
    AppIconStyle('IconPoseidon', 'Poseidone',
        [Color(0xff0A2A38), Color(0xff04121A)], Color(0xff2EC4B6), '',
        glyph: Icons.water_rounded, appName: 'PoseidonTrack'),
  ];

  static Future<String> current() async {
    final v = await StorageService.getString(StorageService.appIconKey);
    return (v != null && styles.any((s) => s.id == v)) ? v : 'IconDefault';
  }

  /// Applica l'icona scelta (solo Android). Ritorna true se applicata.
  static Future<bool> setIcon(String alias) async {
    try {
      final ok = await _channel.invokeMethod<bool>('setIcon', {'alias': alias});
      if (ok == true) {
        await StorageService.setString(StorageService.appIconKey, alias);
      }
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
