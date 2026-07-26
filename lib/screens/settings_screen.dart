import 'package:flutter/material.dart';
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
import '../services/app_icon_service.dart';
import '../theme/app_theme.dart';
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
  String _appIcon = 'IconDefault';

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
    _appIcon = await AppIconService.current();
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
          // ---- Esperienza (lingua, suoni, vibrazioni) ----
          _section(c, t('experience')),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
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
                          .map((code) => DropdownMenuItem(
                                value: code,
                                child: Text(AppStrings.languageNames[code]!),
                              ))
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
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _section(c, t('theme_color')),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            mainAxisSpacing: Spacing.sm,
            crossAxisSpacing: Spacing.sm,
            children: themeList.map((skin) {
              final active = theme.themeId == skin.id;
              final locked = skin.premium && !theme.isUnlocked(skin.id);
              return GestureDetector(
                onTap: () {
                  if (locked) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StoreScreen()));
                  } else {
                    theme.changeTheme(skin.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(
                        color: active ? c.primary : c.border,
                        width: active ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _sw(skin.colors.bg),
                          _sw(skin.colors.card),
                          _sw(skin.colors.primary),
                        ],
                      ),
                      const Spacer(),
                      Text('${skin.name}${skin.premium ? ' ✦' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        active
                            ? '✓ Attivo'
                            : (locked ? '🔒 Store' : skin.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: active ? c.primary : c.textMuted,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (theme.skin.neon)
            SwitchListTile(
              title: Text(t('glow_effect')),
              value: theme.glow,
              activeThumbColor: c.primary,
              onChanged: (v) => theme.toggleGlow(v),
            ),

          // ---- Aspetto (densità, accento, stile card) ----
          const SizedBox(height: Spacing.lg),
          _section(c, t('appearance')),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t('density'),
                style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          Wrap(
            spacing: Spacing.sm,
            children: UiDensity.values.map((d) {
              final active = theme.density == d;
              return ChoiceChip(
                label: Text(d.label),
                selected: active,
                selectedColor: c.primary,
                onSelected: (_) {
                  FeedbackService.selection();
                  theme.setDensity(d);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t('accent'),
                style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: accentOptions.map((a) {
              final active = theme.accentId == a.id;
              final isDefault = a.id == 'default';
              return GestureDetector(
                onTap: () {
                  FeedbackService.selection();
                  theme.setAccent(a.id);
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDefault ? c.card : a.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: active ? c.text : c.border,
                        width: active ? 2.5 : 1),
                  ),
                  child: isDefault
                      ? Icon(Icons.format_color_reset_rounded,
                          size: 18, color: c.textMuted)
                      : (active
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t('card_style'),
                style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          Wrap(
            spacing: Spacing.sm,
            children: [
              (CardStyle.solid, t('card_solid')),
              (CardStyle.glass, t('card_glass')),
              (CardStyle.outline, t('card_outline')),
            ].map((e) {
              final active = theme.cardStyle == e.$1;
              return ChoiceChip(
                label: Text(e.$2),
                selected: active,
                selectedColor: c.primary,
                onSelected: (_) {
                  FeedbackService.selection();
                  theme.setCardStyle(e.$1);
                },
              );
            }).toList(),
          ),

          // ---- Icona app ----
          const SizedBox(height: Spacing.lg),
          _section(c, t('app_icon')),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t('app_icon_hint'),
                style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppIconService.styles.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
              itemBuilder: (context, i) {
                final s = AppIconService.styles[i];
                final active = _appIcon == s.id;
                return GestureDetector(
                  onTap: () async {
                    FeedbackService.onTap();
                    final ok = await AppIconService.setIcon(s.id);
                    if (ok) {
                      setState(() => _appIcon = s.id);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('app_icon_failed'))));
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.4),
                            radius: 1.1,
                            colors: s.bg,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: active ? c.primary : c.border,
                              width: active ? 2.5 : 1),
                        ),
                        child: Icon(Icons.bolt, color: s.bolt, size: 30),
                      ),
                      const SizedBox(height: 4),
                      Text(s.name,
                          style: TextStyle(
                              fontSize: 11,
                              color: active ? c.primary : c.textMuted,
                              fontWeight:
                                  active ? FontWeight.w800 : FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: Spacing.lg),
          _section(c, t('security')),
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
            _radioTile(t('device_lock'), LockMode.device, security.mode,
                () async {
              await SecurityService.setDeviceMode();
              await security.syncSettings();
              setState(() {});
            }),
          if (security.mode == LockMode.pin &&
              (_support?.biometricAvailable ?? false))
            SwitchListTile(
              title: Text('${t('quick_unlock')} ${_support!.biometricLabel}'),
              value: _bioQuick,
              activeThumbColor: c.primary,
              onChanged: (v) async {
                await SecurityService.setBioQuickEnabled(v);
                setState(() => _bioQuick = v);
              },
            ),
          if (security.mode != LockMode.none) ...[
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm, bottom: 4),
              child: Text(t('when_unlock'),
                  style: TextStyle(color: c.textMuted, fontSize: 12)),
            ),
            _policyTile(t('on_launch'), LockPolicy.launch),
            _policyTile(t('after_2min'), LockPolicy.grace),
            _policyTile(t('always'), LockPolicy.immediate),
          ],

          const SizedBox(height: Spacing.lg),
          _section(c, t('reminders')),
          SwitchListTile(
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
              title: Text(t('time')),
              trailing: Text(
                  '${_reminder.hour.toString().padLeft(2, '0')}:${_reminder.minute.toString().padLeft(2, '0')}'),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: _reminder.hour, minute: _reminder.minute),
                );
                if (picked != null) {
                  final updated =
                      _reminder.copyWith(hour: picked.hour, minute: picked.minute);
                  await NotificationService.reschedule(updated);
                  setState(() => _reminder = updated);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 6,
                children: List.generate(7, (uiIdx) {
                  // uiIdx 0=Lun..6=Dom -> storage day (dom=0)
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
            ),
          ],

          const SizedBox(height: Spacing.lg),
          _section(c, t('backup_privacy')),
          SwitchListTile(
            title: Text(t('encryption')),
            value: _encryption,
            activeThumbColor: c.primary,
            onChanged: (v) async {
              if (v) {
                await StorageService.enableEncryption();
              } else {
                await StorageService.disableEncryption();
              }
              await context.read<WorkoutProvider>().reencrypt();
              setState(() => _encryption = v);
            },
          ),
          Row(
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

          const SizedBox(height: Spacing.lg),
          _section(c, t('guide')),
          ListTile(
            leading: const Icon(Icons.replay),
            title: Text(t('replay_tutorial')),
            onTap: () => context.read<OnboardingProvider>().replay(),
          ),

          const SizedBox(height: Spacing.lg),
          _section(c, t('data')),
          ListTile(
            leading: Icon(Icons.delete_forever, color: c.danger),
            title: Text(t('clear_all'), style: TextStyle(color: c.danger)),
            onTap: _confirmClear,
          ),

          const SizedBox(height: Spacing.xl),
          Center(
            child: Text('CaliStrack • v4.1.3',
                style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

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
            'Questa azione eliminerà definitivamente tutti gli allenamenti. Continuare?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla')),
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
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              final p = ctrl.text;
              if (p.length >= 4 && p == ctrl2.text) {
                Navigator.pop(ctx, p);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('PIN non valido o non coincidente')));
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Widget _radioTile(
      String label, String value, String groupValue, VoidCallback onTap) {
    return RadioListTile<String>(
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
      title: Text(label),
      value: value,
      // ignore: deprecated_member_use
      groupValue: _policy,
      // ignore: deprecated_member_use
      onChanged: (v) async {
        await SecurityService.setLockPolicy(v!);
        await context.read<SecurityProvider>().syncSettings();
        setState(() => _policy = v);
      },
    );
  }

  Widget _section(AppColors c, String t) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.sm),
        child: Text(t,
            style: TextStyle(
                color: c.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

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
