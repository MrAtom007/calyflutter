import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

/// Stato onboarding: null = in caricamento.
class OnboardingProvider extends ChangeNotifier {
  bool? _onboarded;
  bool? get onboarded => _onboarded;

  Future<void> load() async {
    _onboarded = await StorageService.hasOnboarded();
    notifyListeners();
  }

  Future<void> finish() async {
    await StorageService.setOnboarded(true);
    _onboarded = true;
    notifyListeners();
    AnalyticsService.onboardingCompleted();
  }

  Future<void> replay() async {
    await StorageService.setOnboarded(false);
    _onboarded = false;
    notifyListeners();
  }
}
