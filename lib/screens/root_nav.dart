import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../services/home_widget_service.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'health_screen.dart';
import 'progress_screen.dart';
import 'exercises_screen.dart';
import 'settings_screen.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _tabIndex = {
    'dashboard': 0,
    'diary': 1,
    'health': 2,
    'progress': 3,
    'exercises': 4,
    'settings': 5,
  };

  StreamSubscription<Uri?>? _widgetSub;

  @override
  void initState() {
    super.initState();
    // Deep-link dal widget della schermata home (caliwidget://<sezione>).
    HomeWidgetService.initialUri().then(_handleUri);
    _widgetSub = HomeWidgetService.clicks.listen(_handleUri);
  }

  @override
  void dispose() {
    _widgetSub?.cancel();
    super.dispose();
  }

  void _handleUri(Uri? uri) {
    if (uri == null || !mounted) return;
    _openTab(uri.host);
  }

  void _openTab(String tab) {
    final i = _tabIndex[tab];
    if (i != null) setState(() => _index = i);
  }

  late final List<Widget> _pages = [
    DashboardScreen(onOpenTab: _openTab),
    const HomeScreen(),
    const HealthScreen(),
    const ProgressScreen(),
    const ExercisesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.02), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          FeedbackService.selection();
          setState(() => _index = i);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: c.card,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: t('nav_dashboard')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_rounded), label: t('nav_diary')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.monitor_heart_rounded),
              label: t('nav_health')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.show_chart_rounded),
              label: t('nav_progress')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center),
              label: t('nav_exercises')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              label: t('nav_settings')),
        ],
      ),
    );
  }
}
