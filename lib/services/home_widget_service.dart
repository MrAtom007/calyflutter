import 'package:home_widget/home_widget.dart';

/// Aggiorna il widget presente sulla schermata home del telefono.
class HomeWidgetService {
  static const _android = 'CaliWidgetProvider';
  static const _ios = 'CaliWidget';

  /// Salva i valori e forza il refresh del widget.
  static Future<void> update({String? bpm, String? steps, String? rank}) async {
    try {
      if (bpm != null) await HomeWidget.saveWidgetData<String>('bpm', bpm);
      if (steps != null) {
        await HomeWidget.saveWidgetData<String>('steps', steps);
      }
      if (rank != null) await HomeWidget.saveWidgetData<String>('rank', rank);
      await HomeWidget.updateWidget(androidName: _android, iOSName: _ios);
    } catch (_) {
      // Il widget potrebbe non essere presente: silenzioso.
    }
  }

  /// URI con cui l'app è stata avviata cliccando il widget (o null).
  static Future<Uri?> initialUri() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }

  /// Stream dei click successivi sul widget.
  static Stream<Uri?> get clicks => HomeWidget.widgetClicked;
}
