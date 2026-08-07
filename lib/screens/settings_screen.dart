import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/onboarding_provider.dart';
import '../state/security_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../services/feedback_service.dart';
import '../services/security_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emblem.dart';
import '../modules/weighted/weighted_settings_screen.dart';
import 'achievements_screen.dart';
import 'store_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _encryption = false;
  SecuritySupport? _support;
  ReminderSettings _reminder = const ReminderSettings();
  bool _bioQuick = false;
  String _policy = LockPolicy.launch;
  bool _sound = FeedbackService.soundEnabled;
  bool _haptics = FeedbackService.hapticsEnabled;
  String _themeTab = 'classic';

  static const _dayLabels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _encryption = await StorageService.isEncryptionEnabled();
    _support = await SecurityService.getSecuritySupport();
    _reminder = await NotificationService.getSettings();
    _bioQuick = await SecurityService.isBioQuickEnabled();
    _policy = await SecurityService.getLockPolicy();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final security = context.watch<SecurityProvider>();
    final localeP = context.watch<LocaleProvider>();
    final t = localeP.t;

    return Scaffold(
      appBar: AppBar(title: Text(t('nav_settings'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _categoryCard(
            c,
            icon: Icons.palette_rounded,
            title: t('cat_personalization'),
            initiallyExpanded: true,
            children: _personalizationChildren(context, theme, c, t),
          ),
          _categoryCard(
            c,
            icon: Icons.fitness_center_rounded,
            title: t('cat_equipment'),
            children: _equipmentChildren(context, c, t),
          ),
          _categoryCard(
            c,
            icon: Icons.shield_rounded,
            title: t('cat_security'),
            children: _securityChildren(context, security, c, t),
          ),
          _categoryCard(
            c,
            icon: Icons.tune_rounded,
            title: t('cat_preferences'),
            children: _preferencesChildren(context, localeP, c, t),
          ),
          _categoryCard(
            c,
            icon: Icons.storage_rounded,
            title: t('cat_data'),
            children: _dataChildren(context, c, t),
          ),
          // Traguardi (link a schermata dedicata)
          Container(
            margin: const EdgeInsets.only(bottom: Spacing.md),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: c.border.withValues(alpha: 0.7)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.emoji_events_rounded, color: c.primary),
              title: Text(
                t('achievements'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                t('achievements_hint'),
                style: TextStyle(color: c.textMuted, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: c.textMuted),
              onTap: () {
                FeedbackService.onTap();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'CaliStrack • v4.11.0',
                style: TextStyle(color: c.textMuted, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===========================================================================
  // Card categoria
  // ===========================================================================
  Widget _categoryCard(
    AppColors c, {
    required IconData icon,
    required String title,
    bool initiallyExpanded = false,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.md),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.border.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: c.primary),
          tilePadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.md,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _subLabel(AppColors c, String text) => Padding(
    padding: const EdgeInsets.only(top: Spacing.md, bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: c.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  // ===========================================================================
  // 1. Personalizzazione & Temi
  // ===========================================================================
  List<Widget> _personalizationChildren(
    BuildContext context,
    ThemeProvider theme,
    AppColors c,
    dynamic t,
  ) {
    return [
      _subLabel(c, t('theme_color')),
      // Schede per stile: Classici / Neon / Leggendari.
      Row(
        children:
            [
              ('classic', t('theme_tab_classic')),
              ('neon', t('theme_tab_neon')),
              ('legendary', t('theme_tab_legendary')),
            ].map((e) {
              final active = _themeTab == e.$1;
              final count = _themesIn(e.$1).length;
              final activeInside = _themesIn(
                e.$1,
              ).any((s) => s.id == theme.themeId);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: _AnimatedSelectChip(
                    c: c,
                    label: e.$2,
                    hint: '$count',
                    selected: active,
                    dot: activeInside && !active,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _themeTab = e.$1);
                    },
                  ),
                ),
              );
            }).toList(),
      ),
      const SizedBox(height: Spacing.sm),
      _themeGrid(context, theme, c, _themesIn(_themeTab)),
      const SizedBox(height: Spacing.sm),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            FeedbackService.onTap();
            theme.randomTheme();
          },
          icon: const Icon(Icons.casino_rounded, size: 18),
          label: Text(t('surprise_me')),
        ),
      ),
      if (theme.skin.neon)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t('glow_effect')),
          value: theme.glow,
          activeThumbColor: c.primary,
          onChanged: (v) => theme.toggleGlow(v),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.smartphone_rounded, size: 16, color: c.textMuted),
            const SizedBox(width: 6),
            Text(
              '${t('dock_name')}: ',
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
            Text(
              theme.launcherName,
              style: TextStyle(
                color: c.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ===========================================================================
  // 2. Attrezzatura & Pesi
  // ===========================================================================
  List<Widget> _equipmentChildren(
    BuildContext context,
    AppColors c,
    dynamic t,
  ) {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.scale_rounded, color: c.primary),
        title: Text(t('weighted_settings')),
        subtitle: Text(
          t('weighted_settings_hint'),
          style: TextStyle(color: c.textMuted, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: c.textMuted),
        onTap: () {
          FeedbackService.onTap();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightedSettingsScreen()),
          );
        },
      ),
    ];
  }

  // ===========================================================================
  // 3. Sicurezza & Privacy
  // ===========================================================================
  List<Widget> _securityChildren(
    BuildContext context,
    SecurityProvider security,
    AppColors c,
    dynamic t,
  ) {
    return [
      _radioTile(t('no_protection'), LockMode.none, security.mode, () async {
        await SecurityService.disableLock();
        await security.syncSettings();
        setState(() {});
      }),
      _radioTile(t('app_pin'), LockMode.pin, security.mode, () async {
        final pin = await _askPin();
        if (pin != null) {
          await SecurityService.setPin(pin);
          await security.syncSettings();
          setState(() {});
        }
      }),
      if (_support?.deviceLockAvailable ?? false)
        _radioTile(t('device_lock'), LockMode.device, security.mode, () async {
          await SecurityService.setDeviceMode();
          await security.syncSettings();
          setState(() {});
        }),
      if (security.mode == LockMode.pin &&
          (_support?.biometricAvailable ?? false))
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${t('quick_unlock')} ${_support!.biometricLabel}'),
          value: _bioQuick,
          activeThumbColor: c.primary,
          onChanged: (v) async {
            await SecurityService.setBioQuickEnabled(v);
            setState(() => _bioQuick = v);
          },
        ),
      if (security.mode != LockMode.none) ...[
        _subLabel(c, t('when_unlock')),
        _policyTile(t('on_launch'), LockPolicy.launch),
        _policyTile(t('after_2min'), LockPolicy.grace),
        _policyTile(t('always'), LockPolicy.immediate),
      ],
      _subLabel(c, t('backup_privacy')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(t('encryption')),
        value: _encryption,
        activeThumbColor: c.primary,
        onChanged: (v) async {
          final workouts = context.read<WorkoutProvider>();
          if (v) {
            await StorageService.enableEncryption();
          } else {
            await StorageService.disableEncryption();
          }
          await workouts.reencrypt();
          if (mounted) setState(() => _encryption = v);
        },
      ),
    ];
  }

  // ===========================================================================
  // 4. Preferenze & Suoni
  // ===========================================================================
  List<Widget> _preferencesChildren(
    BuildContext context,
    LocaleProvider localeP,
    AppColors c,
    dynamic t,
  ) {
    return [
      Row(
        children: [
          Icon(Icons.language, color: c.primary),
          const SizedBox(width: 12),
          Text(t('language')),
          const Spacer(),
          DropdownButton<String>(
            value: localeP.code,
            underline: const SizedBox(),
            onChanged: (v) {
              if (v != null) {
                FeedbackService.selection();
                context.read<LocaleProvider>().setLanguage(v);
              }
            },
            items: AppStrings.supported
                .map(
                  (code) => DropdownMenuItem(
                    value: code,
                    child: Text(AppStrings.languageNames[code]!),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(Icons.volume_up, color: c.primary),
        title: Text(t('sound_effects')),
        value: _sound,
        activeThumbColor: c.primary,
        onChanged: (v) async {
          await FeedbackService.setSound(v);
          if (v) FeedbackService.success();
          setState(() => _sound = v);
        },
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(Icons.vibration, color: c.primary),
        title: Text(t('vibrations')),
        value: _haptics,
        activeThumbColor: c.primary,
        onChanged: (v) async {
          await FeedbackService.setHaptics(v);
          if (v) FeedbackService.medium();
          setState(() => _haptics = v);
        },
      ),
      _subLabel(c, t('reminders')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(t('reminder_notifications')),
        value: _reminder.enabled,
        activeThumbColor: c.primary,
        onChanged: (v) async {
          final updated = _reminder.copyWith(enabled: v);
          final ok = await NotificationService.reschedule(updated);
          setState(() => _reminder = updated.copyWith(enabled: v && ok));
        },
      ),
      if (_reminder.enabled) ...[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t('time')),
          trailing: Text(
            '${_reminder.hour.toString().padLeft(2, '0')}:${_reminder.minute.toString().padLeft(2, '0')}',
          ),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: _reminder.hour,
                minute: _reminder.minute,
              ),
            );
            if (picked != null) {
              final updated = _reminder.copyWith(
                hour: picked.hour,
                minute: picked.minute,
              );
              await NotificationService.reschedule(updated);
              setState(() => _reminder = updated);
            }
          },
        ),
        Wrap(
          spacing: 6,
          children: List.generate(7, (uiIdx) {
            final day = (uiIdx + 1) % 7;
            final sel = _reminder.days.contains(day);
            return ChoiceChip(
              label: Text(_dayLabels[uiIdx]),
              selected: sel,
              selectedColor: c.primary,
              onSelected: (_) async {
                final days = [..._reminder.days];
                if (sel) {
                  days.remove(day);
                } else {
                  days.add(day);
                }
                final updated = _reminder.copyWith(days: days);
                await NotificationService.reschedule(updated);
                setState(() => _reminder = updated);
              },
            );
          }),
        ),
      ],
    ];
  }

  // ===========================================================================
  // 5. Dati & Backup
  // ===========================================================================
  List<Widget> _dataChildren(BuildContext context, AppColors c, dynamic t) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _export('csv'),
                child: Text(t('export_csv')),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _export('json'),
                child: Text(t('export_json')),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.replay),
        title: Text(t('replay_tutorial')),
        onTap: () => context.read<OnboardingProvider>().replay(),
      ),
      const Divider(height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.delete_forever, color: c.danger),
        title: Text(t('clear_all'), style: TextStyle(color: c.danger)),
        onTap: _confirmClear,
      ),
    ];
  }

  // ===========================================================================
  // Azioni / helper
  // ===========================================================================
  Future<void> _export(String fmt) async {
    final all = await StorageService.getWorkouts();
    if (all.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessun dato da esportare')),
        );
      }
      return;
    }
    await ExportService.export(all, fmt);
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancella tutti i dati'),
        content: const Text(
          'Questa azione eliminerà definitivamente tutti gli allenamenti. Continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutProvider>().clear();
              Navigator.pop(ctx);
            },
            child: const Text('Cancella'),
          ),
        ],
      ),
    );
  }

  Future<String?> _askPin() async {
    final ctrl = TextEditingController();
    final ctrl2 = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Imposta un PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'PIN (4-6 cifre)'),
            ),
            TextField(
              controller: ctrl2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Conferma PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              final p = ctrl.text;
              if (p.length >= 4 && p == ctrl2.text) {
                Navigator.pop(ctx, p);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('PIN non valido o non coincidente'),
                  ),
                );
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Widget _radioTile(
    String label,
    String value,
    String groupValue,
    VoidCallback onTap,
  ) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: (_) => onTap(),
    );
  }

  Widget _policyTile(String label, String value) {
    return RadioListTile<String>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      // ignore: deprecated_member_use
      groupValue: _policy,
      // ignore: deprecated_member_use
      onChanged: (v) async {
        final security = context.read<SecurityProvider>();
        await SecurityService.setLockPolicy(v!);
        await security.syncSettings();
        if (mounted) setState(() => _policy = v);
      },
    );
  }

  // ---- Temi raggruppati per categoria ----
  static const _legendaryIds = {
    'spartacus',
    'kratos',
    'ulisse',
    'zeus',
    'cyberpunk',
    'valkyrie',
    'ronin',
    'anubis',
    'achille',
    'leonida',
    'poseidon',
    'ercole',
    'odino',
    'ra',
    'ade',
    'cavaliere',
    'cerberus',
    'igris',
    'sukuna',
    'toji',
  };

  List<AppSkin> _themesIn(String category) {
    return themeList.where((s) {
      final legendary = _legendaryIds.contains(s.id);
      switch (category) {
        case 'legendary':
          return legendary;
        case 'neon':
          return s.neon && !legendary;
        default: // classic
          return !s.neon && !legendary;
      }
    }).toList();
  }

  Widget _themeGrid(
    BuildContext context,
    ThemeProvider theme,
    AppColors c,
    List<AppSkin> skins,
  ) {
    if (skins.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Colonne in base allo spazio: tile larghi ~220px, min 2 colonne.
        final cols = (constraints.maxWidth / 220).floor().clamp(2, 4);
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          mainAxisSpacing: Spacing.sm,
          crossAxisSpacing: Spacing.sm,
          children: skins
              .map((skin) => _themeCard(context, theme, c, skin))
              .toList(),
        );
      },
    );
  }

  Widget _themeCard(
    BuildContext context,
    ThemeProvider theme,
    AppColors c,
    AppSkin skin,
  ) {
    final active = theme.themeId == skin.id;
    final locked = skin.premium && !theme.isUnlocked(skin.id);
    final t = context.read<LocaleProvider>().t;
    return GestureDetector(
      onTap: () {
        FeedbackService.onTap();
        if (locked) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreScreen()),
          );
        } else {
          theme.changeTheme(skin.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: active ? c.primary : c.border.withValues(alpha: 0.5),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (subjectPhotoAsset(emblemForTheme(skin.id)) != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      subjectPhotoAsset(emblemForTheme(skin.id))!,
                      width: 26,
                      height: 26,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else if (emblemForTheme(skin.id) != null) ...[
                  EmblemView(
                    subject: emblemForTheme(skin.id),
                    size: 26,
                    color: skin.colors.primary,
                    style: theme.emblemStyle,
                  ),
                  const SizedBox(width: 6),
                ],
                _sw(skin.colors.bg),
                _sw(skin.colors.card),
                _sw(skin.colors.primary),
              ],
            ),
            const Spacer(),
            Text(
              '${skin.name}${skin.premium ? ' ✦' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              active
                  ? '✓ ${t('active')}'
                  : (locked ? '🔒 Store' : skin.description),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? c.primary : c.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sw(Color color) => Container(
    width: 20,
    height: 20,
    margin: const EdgeInsets.only(right: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.white24),
    ),
  );
}

/// Chip di selezione con feedback aptico immediato e transizione animata
/// dello stato selezionato (150ms), prima del rebuild del tema.
class _AnimatedSelectChip extends StatelessWidget {
  const _AnimatedSelectChip({
    required this.c,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint,
    this.dot = false,
  });

  final AppColors c;
  final String label;
  final String? hint;
  final bool selected;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Feedback immediato al tocco, prima di qualsiasi rebuild.
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.cardAlt,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: selected ? c.primary : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? _onPrimary(c.primary) : c.text,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (dot) ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (hint != null)
              Text(
                hint!,
                style: TextStyle(
                  color: selected
                      ? _onPrimary(c.primary).withValues(alpha: 0.85)
                      : c.textMuted,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Colore leggibile sopra il primary (nero o bianco a seconda della luminanza).
  Color _onPrimary(Color primary) =>
      primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
