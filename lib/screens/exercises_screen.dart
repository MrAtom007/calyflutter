import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/locale_provider.dart';
import '../data/exercises.dart';
import '../data/category_icons.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';
import '../widgets/discipline_switch.dart';
import 'exercise_detail_screen.dart';
import 'timer_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final discipline = context.watch<DisciplineProvider>().discipline;
    final categories = getCategories(discipline);
    final library = getLibrary(discipline);
    final filtered = _query.isEmpty
        ? library
        : library
            .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('library'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: const DisciplineSwitch(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: t.p('search_exercises', {'n': '${library.length}'}),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.md)),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              children: [
                for (final cat in categories)
                  ..._buildCategory(context, cat, filtered, c),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategory(
      BuildContext context, String cat, List<Exercise> list, AppColors c) {
    final items = list.where((e) => e.category == cat).toList();
    if (items.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            Icon(categoryIcon(cat), color: c.primary, size: 18),
            const SizedBox(width: 8),
            Text('$cat (${items.length})',
                style: TextStyle(
                    color: c.textMuted, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      ...items.map((ex) => Card(
            color: c.card,
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              side: BorderSide(color: c.border),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c.primary.withValues(alpha: 0.14),
                child: Icon(categoryIcon(ex.category),
                    color: c.primary, size: 20),
              ),
              title: Text(ex.name),
              subtitle: Text(_meta(ex), style: TextStyle(color: c.textMuted)),
              trailing: ex.unit == 'sec'
                  ? IconButton(
                      icon: Icon(Icons.timer_outlined, color: c.primary),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TimerScreen(exerciseName: ex.name))),
                    )
                  : Icon(Icons.chevron_right, color: c.textMuted),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ExerciseDetailScreen(exerciseId: ex.id)),
              ),
            ),
          )),
    ];
  }

  String _meta(Exercise ex) {
    final unit = ex.unit == 'weight'
        ? 'kg×reps'
        : ex.unit == 'sec'
            ? 'secondi'
            : 'ripetizioni';
    return '${ex.level} · $unit';
  }
}
