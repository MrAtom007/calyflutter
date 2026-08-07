import 'package:flutter_test/flutter_test.dart';
import 'package:calistrack/services/analytics_service.dart';

void main() {
  // Senza Firebase configurato (come in test/local), AnalyticsService deve
  // restare disattivato e ogni chiamata dev'essere un no-op che non lancia.
  group('AnalyticsService (no-op safe)', () {
    test('isEnabled è false senza init/Firebase', () {
      expect(AnalyticsService.isEnabled, isFalse);
      expect(AnalyticsService.observer, isNull);
    });

    test('gli eventi non lanciano quando disattivato', () {
      expect(() async {
        await AnalyticsService.appOpen();
        await AnalyticsService.onboardingCompleted();
        await AnalyticsService.workoutSaved(
          discipline: 'gym',
          sets: 3,
          points: 42,
          single: false,
        );
        await AnalyticsService.levelUp(2, 'stone');
        await AnalyticsService.storeUnlock('all', paid: true, price: 9.99);
        await AnalyticsService.storeUnlock('neon', paid: false);
        await AnalyticsService.purchase('premium', 9.99, 'EUR');
        await AnalyticsService.loginCompleted('google');
        await AnalyticsService.log('evento_custom', {'k': 1});
      }(), completes);
    });

    test('setUser/setUserProperty/recordError sono no-op sicuri', () {
      expect(() async {
        await AnalyticsService.setUser('uid-123');
        await AnalyticsService.setUser(null);
        await AnalyticsService.setUserProperty('tier', 'free');
        await AnalyticsService.recordError(
          Exception('x'),
          StackTrace.current,
          reason: 'test',
        );
      }(), completes);
    });
  });
}
