import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'state/theme_provider.dart';
import 'state/discipline_provider.dart';
import 'state/onboarding_provider.dart';
import 'state/security_provider.dart';
import 'state/levelup_provider.dart';
import 'state/workout_provider.dart';
import 'state/locale_provider.dart';
import 'state/health_provider.dart';
import 'state/health_layout_provider.dart';
import 'state/dashboard_provider.dart';
import 'state/draft_provider.dart';
import 'services/notification_service.dart';
import 'services/feedback_service.dart';
import 'services/home_widget_service.dart';
import 'data/ranks.dart';
import 'theme/app_theme.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it');
  await initializeDateFormatting('en');
  await initializeDateFormatting('es');
  await NotificationService.init();
  await FeedbackService.init();

  // Backend cloud (salvataggio progressi legato all'account Google).
  // Se Firebase non è configurato l'app continua comunque in locale.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  final theme = ThemeProvider();
  final discipline = DisciplineProvider();
  final onboarding = OnboardingProvider();
  final security = SecurityProvider();
  final workouts = WorkoutProvider();
  final locale = LocaleProvider();
  final health = HealthProvider();
  final healthLayout = HealthLayoutProvider();
  final dashboard = DashboardProvider();
  final draft = DraftProvider();

  // Ricarica tutti i provider (tranne health) dai dati locali: usata dopo il
  // ripristino di un backup dal cloud, così l'UI riflette i progressi scaricati.
  Future<void> reloadLocalProviders() async {
    await Future.wait([
      theme.load(),
      discipline.load(),
      onboarding.load(),
      security.load(),
      workouts.load(),
      locale.load(),
      dashboard.load(),
      healthLayout.load(),
      draft.load(),
    ]);
  }

  health.onCloudRestored = reloadLocalProviders;

  await reloadLocalProviders();
  // health.load() per ultimo: può ripristinare un backup dal cloud e
  // riallineare gli altri provider tramite onCloudRestored.
  await health.load();

  // Popola il widget della schermata home col rango attuale (dati allenamento).
  final pts = totalPoints(workouts.forDiscipline(discipline.discipline));
  HomeWidgetService.update(rank: '${rankFor(pts).current.name} · $pts');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: discipline),
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: security),
        ChangeNotifierProvider.value(value: workouts),
        ChangeNotifierProvider.value(value: locale),
        ChangeNotifierProvider.value(value: health),
        ChangeNotifierProvider.value(value: healthLayout),
        ChangeNotifierProvider.value(value: dashboard),
        ChangeNotifierProvider.value(value: draft),
        ChangeNotifierProvider(create: (_) => LevelUpProvider()),
      ],
      child: const CaliStrackApp(),
    ),
  );
}

class CaliStrackApp extends StatelessWidget {
  const CaliStrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    // Il MaterialApp (e quindi tutto l'albero) viene ricostruito SOLO quando
    // cambia il tema vero e proprio. Densità, stile card, accento e glow non
    // toccano il ThemeData e vengono consumati puntualmente dai singoli widget,
    // così il cambio di quei parametri non blocca il thread UI.
    return Selector<ThemeProvider, String>(
      selector: (_, t) => t.themeId,
      builder: (context, themeId, _) {
        final skin = appThemes[themeId] ?? appThemes[defaultThemeId]!;
        SystemChrome.setSystemUIOverlayStyle(
          skin.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );
        return MaterialApp(
          title: 'CaliStrack',
          debugShowCheckedModeBanner: false,
          theme: buildThemeData(skin),
          locale: locale.locale,
          supportedLocales: const [Locale('it'), Locale('en'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppGate(),
        );
      },
    );
  }
}
