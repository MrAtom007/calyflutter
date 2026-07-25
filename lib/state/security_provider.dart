import 'package:flutter/material.dart';
import '../services/security_service.dart';

/// Gestisce lo stato di blocco dell'app in base a modalità e politica.
class SecurityProvider extends ChangeNotifier with WidgetsBindingObserver {
  String _mode = LockMode.none;
  String _policy = LockPolicy.launch;
  bool _locked = false;
  bool ready = false;
  DateTime? _bgSince;

  String get mode => _mode;
  String get policy => _policy;
  bool get locked => _locked;

  SecurityProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> load() async {
    _mode = await SecurityService.getLockMode();
    _policy = await SecurityService.getLockPolicy();
    _locked = _mode != LockMode.none; // blocca al cold-start
    ready = true;
    notifyListeners();
  }

  Future<void> syncSettings() async {
    _mode = await SecurityService.getLockMode();
    _policy = await SecurityService.getLockPolicy();
    if (_mode == LockMode.none) _locked = false;
    notifyListeners();
  }

  void unlock() {
    _locked = false;
    notifyListeners();
  }

  void setLocked(bool v) {
    _locked = v;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_mode == LockMode.none) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _bgSince = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      switch (_policy) {
        case LockPolicy.immediate:
          setLocked(true);
          break;
        case LockPolicy.grace:
          if (_bgSince != null &&
              DateTime.now().difference(_bgSince!).inMilliseconds > graceMs) {
            setLocked(true);
          }
          break;
        case LockPolicy.launch:
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
