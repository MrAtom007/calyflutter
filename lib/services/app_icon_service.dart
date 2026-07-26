import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Uno stile di icona dell'app (alias nativo + anteprima in-app).
class AppIconStyle {
  final String id; // alias nativo Android (es. IconZeus)
  final String name;
  final List<Color> bg; // gradiente sfondo anteprima
  final Color bolt; // colore fulmine anteprima

  const AppIconStyle(this.id, this.name, this.bg, this.bolt);
}

class AppIconService {
  static const _channel = MethodChannel('calistrack/app_icon');

  // I nomi combaciano con i temi epici dell'app.
  static const List<AppIconStyle> styles = [
    AppIconStyle('IconDefault', 'Ulisse',
        [Color(0xff1B4A63), Color(0xff07131C)], Color(0xffF0C85A)),
    AppIconStyle('IconZeus', 'Zeus',
        [Color(0xff2A3350), Color(0xff0A0C12)], Color(0xffFFD85A)),
    AppIconStyle('IconCyberpunk', 'Cyberpunk',
        [Color(0xff2A0A3A), Color(0xff05020A)], Color(0xffFF2EC4)),
    AppIconStyle('IconSpartacus', 'Spartacus',
        [Color(0xffC0392B), Color(0xff160807)], Color(0xffE2A63F)),
    AppIconStyle('IconKratos', 'Kratos',
        [Color(0xff3A2020), Color(0xff0C0D0F)], Color(0xffE63329)),
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
