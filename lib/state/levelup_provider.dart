import 'package:flutter/material.dart';
import '../data/ranks.dart';
import '../services/analytics_service.dart';

/// Segnala un level up da mostrare come overlay.
class LevelUpProvider extends ChangeNotifier {
  Rank? rank;
  int? level;

  void celebrate(Rank r, int lvl) {
    rank = r;
    level = lvl;
    notifyListeners();
    AnalyticsService.levelUp(lvl, r.id);
  }

  void dismiss() {
    rank = null;
    level = null;
    notifyListeners();
  }
}
