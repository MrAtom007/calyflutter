import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../l10n/app_strings.dart';
import '../services/storage_service.dart';
import '../utils/format.dart' as fmt;

/// Lingua dell'app (it/en/es), persistita.
class LocaleProvider extends ChangeNotifier {
  static const _key = '@calistrack/lang';
  String _code = 'it';

  String get code => _code;
  AppStrings get t => AppStrings(_code);
  Locale get locale => Locale(_code);

  Future<void> load() async {
    final saved = await StorageService.getString(_key);
    if (saved != null && AppStrings.supported.contains(saved)) {
      _code = saved;
    } else {
      // Prova a usare la lingua di sistema se supportata.
      final sys = PlatformDispatcher.instance.locale.languageCode;
      if (AppStrings.supported.contains(sys)) _code = sys;
    }
    fmt.appLocale = _code;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (!AppStrings.supported.contains(code)) return;
    _code = code;
    fmt.appLocale = code;
    await StorageService.setString(_key, code);
    notifyListeners();
  }
}
