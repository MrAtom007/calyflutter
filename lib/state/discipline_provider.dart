import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class DisciplineInfo {
  final String label;
  final String icon;
  const DisciplineInfo(this.label, this.icon);
}

const Map<String, DisciplineInfo> disciplines = {
  'calisthenics': DisciplineInfo('Calisthenics', '🤸'),
  'gym': DisciplineInfo('Palestra', '🏋️'),
};

/// Disciplina attiva (calisthenics/gym).
class DisciplineProvider extends ChangeNotifier {
  String _discipline = 'calisthenics';
  String get discipline => _discipline;

  Future<void> load() async {
    final d = await StorageService.getString(StorageService.disciplineKey);
    if (d == 'gym' || d == 'calisthenics') _discipline = d!;
    notifyListeners();
  }

  Future<void> setDiscipline(String d) async {
    _discipline = d;
    await StorageService.setString(StorageService.disciplineKey, d);
    notifyListeners();
  }
}
