import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/dashboard_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import '../widgets/discipline_switch.dart';
import '../widgets/dashboard_widgets.dart';

/// Home personalizzabile a widget.
class DashboardScreen extends StatefulWidget {
  final void Function(String tab) onOpenTab;
  const DashboardScreen({super.key, required this.onOpenTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final dash = context.watch<DashboardProvider>();
    final scale = context.watch<ThemeProvider>().densityScale;
    final gap = Spacing.md * scale;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(t('nav_dashboard')),
          actions: [
            if (_editing)
              IconButton(
                tooltip: t('dash_add'),
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showAddSheet(context, dash),
              ),
            IconButton(
              tooltip: _editing ? t('done') : t('customize'),
              icon: Icon(_editing ? Icons.check_rounded : Icons.tune_rounded),
              onPressed: () {
                FeedbackService.onTap();
                setState(() => _editing = !_editing);
              },
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ReorderableListView(
            padding: EdgeInsets.fromLTRB(gap, gap, gap, gap * 4),
            buildDefaultDragHandles: false,
            onReorder: (o, n) {
              FeedbackService.selection();
              dash.reorder(o, n);
            },
            header: Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: const DisciplineSwitch(),
            ),
            footer: _editing
                ? Padding(
                    padding: EdgeInsets.only(top: gap),
                    child: TextButton.icon(
                      onPressed: () => dash.reset(),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(t('dash_reset')),
                    ),
                  )
                : null,
            children: [
              for (int i = 0; i < dash.widgets.length; i++)
                Padding(
                  key: ValueKey(dash.widgets[i].name),
                  padding: EdgeInsets.only(bottom: gap),
                  child: _wrap(
                    context,
                    dash,
                    i,
                    buildDashWidget(context, dash.widgets[i], widget.onOpenTab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrap(BuildContext context, DashboardProvider dash, int index, Widget child) {
    final c = context.watch<ThemeProvider>().colors;
    if (!_editing) return child;
    return Stack(
      children: [
        Opacity(opacity: 0.96, child: IgnorePointer(child: child)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: c.primary.withValues(alpha: 0.5), width: 1.4),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.cardAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 18, color: c.textMuted),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  FeedbackService.onTap();
                  dash.remove(dash.widgets[index]);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.danger.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: c.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, DashboardProvider dash) {
    final c = context.read<ThemeProvider>().colors;
    final t = context.read<LocaleProvider>().t;
    final available = dash.available;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('dash_add'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: Spacing.sm),
              if (available.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Text(t('dash_all_added'),
                      style: TextStyle(color: c.textMuted)),
                ),
              ...available.map((w) => ListTile(
                    leading: Icon(w.icon, color: c.primary),
                    title: Text(t(w.titleKey)),
                    trailing: const Icon(Icons.add_circle_outline_rounded),
                    onTap: () {
                      FeedbackService.onTap();
                      dash.add(w);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
