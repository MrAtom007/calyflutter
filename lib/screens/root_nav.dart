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

  static const _navIcons = [
    Icons.dashboard_rounded,
    Icons.menu_book_rounded,
    Icons.monitor_heart_rounded,
    Icons.show_chart_rounded,
    Icons.fitness_center,
    Icons.settings_outlined,
  ];

  static const _navKeys = [
    'nav_dashboard',
    'nav_diary',
    'nav_health',
    'nav_progress',
    'nav_exercises',
    'nav_settings',
  ];

  void _select(int i) {
    FeedbackService.selection();
    setState(() => _index = i);
  }

  Widget _animatedContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final width = MediaQuery.of(context).size.width;
    // Layout desktop: navigazione laterale + area contenuti ampia e centrata.
    final isDesktop = width >= 800;

    if (isDesktop) {
      final extended = width >= 1120;
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Row(
            children: [
              _DesktopRail(
                index: _index,
                onSelect: _select,
                colors: c,
                t: t.call,
                icons: _navIcons,
                labelKeys: _navKeys,
                extended: extended,
              ),
              Container(width: 1, color: c.border),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: _animatedContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Layout mobile: bottom navigation a tutta larghezza.
    return Scaffold(
      body: _animatedContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _select,
        type: BottomNavigationBarType.fixed,
        backgroundColor: c.card,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          for (var i = 0; i < _navIcons.length; i++)
            BottomNavigationBarItem(
              icon: Icon(_navIcons[i]),
              label: t(_navKeys[i]),
            ),
        ],
      ),
    );
  }
}

/// Barra di navigazione laterale per il layout desktop.
class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.index,
    required this.onSelect,
    required this.colors,
    required this.t,
    required this.icons,
    required this.labelKeys,
    required this.extended,
  });

  final int index;
  final void Function(int) onSelect;
  final dynamic colors;
  final String Function(String) t;
  final List<IconData> icons;
  final List<String> labelKeys;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      width: extended ? 210 : 76,
      color: c.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: extended ? 18 : 0),
            child: Row(
              mainAxisAlignment: extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, color: c.primary, size: 26),
                if (extended) ...[
                  const SizedBox(width: 8),
                  Text(
                    'CaliStrack',
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < icons.length; i++)
            _RailItem(
              icon: icons[i],
              label: t(labelKeys[i]),
              selected: index == i,
              extended: extended,
              colors: c,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final dynamic colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final fg = selected ? c.primary : c.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected
            ? c.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? 14 : 0,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 24),
                if (extended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? c.text : c.textMuted,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
