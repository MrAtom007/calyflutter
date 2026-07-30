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

  final bool premium; // contenuto premium (sbloccabile dallo Store)
  final String? themeId; // tema associato: sbloccarlo sblocca anche l'icona

  const AppIconStyle(this.id, this.name, this.bg, this.bolt, this.asset,
      {this.glyph = Icons.bolt_rounded,
      this.appName = 'CaliStrack',
      this.premium = false,
      this.themeId});

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
        Color(0xffFFD85A), 'assets/icon_previews/zeus.png',
        appName: 'ZeusTrack', premium: true, themeId: 'zeus'),
    AppIconStyle('IconCyberpunk', 'Cyberpunk', [Color(0xff320E44), Color(0xff07030D)],
        Color(0xffFF3AD0), 'assets/icon_previews/cyberpunk.png',
        appName: 'CyberTrack', premium: true, themeId: 'cyberpunk'),
    AppIconStyle('IconSpartacus', 'Spartacus', [Color(0xffCF4233), Color(0xff1A0A09)],
        Color(0xffE9B45A), 'assets/icon_previews/spartacus.png',
        appName: 'SpartanTrack', premium: true, themeId: 'spartacus'),
    AppIconStyle('IconKratos', 'Kratos', [Color(0xff442727), Color(0xff0E0F12)],
        Color(0xffEE4A40), 'assets/icon_previews/kratos.png',
        appName: 'KratosFit', premium: true, themeId: 'kratos'),
    // Nuove icone (anteprima vettoriale, senza PNG dedicato).
    AppIconStyle('IconSynthwave', 'Synthwave',
        [Color(0xff2A0A54), Color(0xff0D0221)], Color(0xffFF2EC4), '',
        glyph: Icons.wb_sunny_rounded, appName: 'SynthTrack',
        premium: true, themeId: 'neonSynthwave'),
    AppIconStyle('IconValkyrie', 'Valkyrie',
        [Color(0xff2A323B), Color(0xff0B0E12)], Color(0xffD7DEE6), '',
        glyph: Icons.flight_rounded, appName: 'ValkyrieFit',
        premium: true, themeId: 'valkyrie'),
    AppIconStyle('IconRonin', 'Ronin',
        [Color(0xff2E1516), Color(0xff0B0808)], Color(0xffC0392B), '',
        glyph: Icons.brightness_1_rounded, appName: 'RoninTrack',
        premium: true, themeId: 'ronin'),
    AppIconStyle('IconAnubis', 'Anubis',
        [Color(0xff16233F), Color(0xff070A12)], Color(0xffF2C14E), '',
        glyph: Icons.ac_unit_rounded, appName: 'AnubisFit',
        premium: true, themeId: 'anubis'),
    AppIconStyle('IconAchille', 'Achille',
        [Color(0xff3A2A12), Color(0xff0C0A08)], Color(0xffCF9B3C), '',
        glyph: Icons.shield_moon_rounded, appName: 'AchilleTrack',
        premium: true, themeId: 'achille'),
    AppIconStyle('IconLeonida', 'Leonida',
        [Color(0xff3A1512), Color(0xff120707)], Color(0xffD13B2F), '',
        glyph: Icons.security_rounded, appName: 'LeonidaTrack',
        premium: true, themeId: 'leonida'),
    AppIconStyle('IconPoseidon', 'Poseidone',
        [Color(0xff0A2A38), Color(0xff04121A)], Color(0xff2EC4B6), '',
        glyph: Icons.water_rounded, appName: 'PoseidonTrack',
        premium: true, themeId: 'poseidon'),
    AppIconStyle('IconErcole', 'Ercole',
        [Color(0xff212E16), Color(0xff0D1109)], Color(0xffC9A24B), '',
        glyph: Icons.sports_mma_rounded, appName: 'ErcoleTrack',
        premium: true, themeId: 'ercole'),
    AppIconStyle('IconOdino', 'Odino',
        [Color(0xff202838), Color(0xff0B0F16)], Color(0xffE0B34A), '',
        glyph: Icons.change_history_rounded, appName: 'OdinoTrack',
        premium: true, themeId: 'odino'),
    AppIconStyle('IconRa', 'Ra',
        [Color(0xff2C1F0C), Color(0xff120C04)], Color(0xffF2B418), '',
        glyph: Icons.wb_sunny_rounded, appName: 'RaTrack',
        premium: true, themeId: 'ra'),
    AppIconStyle('IconAde', 'Ade',
        [Color(0xff1A1226), Color(0xff08060C)], Color(0xff7C4DFF), '',
        glyph: Icons.local_fire_department_rounded, appName: 'AdeTrack',
        premium: true, themeId: 'ade'),
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
