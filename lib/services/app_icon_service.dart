import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Uno stile di icona dell'app (alias nativo + anteprima in-app).
class AppIconStyle {
  final String id; // alias nativo Android (es. IconZeus)
  final String name;
  final List<Color> bg; // gradiente sfondo anteprima (fallback)
  final Color bolt; // colore accento
  final String asset; // immagine emblema

  const AppIconStyle(this.id, this.name, this.bg, this.bolt, this.asset);
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
        Color(0xffF3C75A), 'assets/icon_previews/ulisse.png'),
    AppIconStyle('IconZeus', 'Zeus', [Color(0xff303B5C), Color(0xff0B0E16)],
        Color(0xffFFD85A), 'assets/icon_previews/zeus.png'),
    AppIconStyle('IconCyberpunk', 'Cyberpunk', [Color(0xff320E44), Color(0xff07030D)],
        Color(0xffFF3AD0), 'assets/icon_previews/cyberpunk.png'),
    AppIconStyle('IconSpartacus', 'Spartacus', [Color(0xffCF4233), Color(0xff1A0A09)],
        Color(0xffE9B45A), 'assets/icon_previews/spartacus.png'),
    AppIconStyle('IconKratos', 'Kratos', [Color(0xff442727), Color(0xff0E0F12)],
        Color(0xffEE4A40), 'assets/icon_previews/kratos.png'),
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
