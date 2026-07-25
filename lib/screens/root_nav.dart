import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import 'home_screen.dart';
import 'routines_screen.dart';
import 'progress_screen.dart';
import 'ranks_screen.dart';
import 'exercises_screen.dart';
import 'settings_screen.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    RoutinesScreen(),
    ProgressScreen(),
    RanksScreen(),
    ExercisesScreen(),
    SettingsScreen(),
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
              icon: const Icon(Icons.home_rounded), label: t('nav_home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              label: t('nav_routines')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.show_chart_rounded),
              label: t('nav_progress')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.military_tech_outlined),
              label: t('nav_medals')),
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
