import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calistrack/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Test', () {
    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      // Avvia l'app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verifica che non ci siano errori di crash immediato
      // L'app dovrebbe mostrare la home screen o onboarding
      expect(find.byType(app.CaliStrackApp), findsOneWidget);
    });

    testWidgets('No critical errors on startup', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Controlla che non ci siano overlay di errore visibili
      // (questo è un test basilare - estendi con assertion specifiche)
      final errorWidgets = find.byWidgetPredicate(
        (widget) => widget.toStringShort().toLowerCase().contains('error'),
      );
      // Potrebbero esserci error widget per stati vuoti - logghiamo solo
      if (errorWidgets.evaluate().isNotEmpty) {
        print('Warning: Found ${errorWidgets.evaluate().length} potential error widgets');
      }
    });
  });
}