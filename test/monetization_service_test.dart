import 'package:flutter_test/flutter_test.dart';
import 'package:calistrack/services/monetization_service.dart';

void main() {
  // Senza API key (nessun --dart-define), la monetizzazione dev'essere
  // completamente disattivata: l'app usa lo sblocco locale e nulla lancia.
  group('MonetizationService (feature-flag off)', () {
    test('isAvailable è false senza RC_ANDROID_KEY/RC_IOS_KEY', () {
      expect(MonetizationService.isAvailable, isFalse);
    });

    test('stato premium iniziale è false', () {
      expect(MonetizationService.hasPremium, isFalse);
      expect(MonetizationService.premium.value, isFalse);
    });

    test('entitlement id atteso', () {
      expect(MonetizationService.kEntitlementId, 'premium');
    });

    test('init non lancia e non attiva nulla', () async {
      await MonetizationService.init();
      expect(MonetizationService.hasPremium, isFalse);
    });

    test(
      'acquisto/ripristino ritornano false quando non configurato',
      () async {
        expect(await MonetizationService.buyPremium(), isFalse);
        expect(await MonetizationService.restore(), isFalse);
        expect(await MonetizationService.currentOffering(), isNull);
      },
    );

    test('identify/signOut sono no-op sicuri', () {
      expect(() async {
        await MonetizationService.identify('uid-123');
        await MonetizationService.signOut();
      }(), completes);
    });
  });
}
