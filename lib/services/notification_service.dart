import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final List<int> days; // 0=dom .. 6=sab
  const ReminderSettings({
    this.enabled = false,
    this.hour = 18,
    this.minute = 0,
    this.days = const [1, 2, 3, 4, 5],
  });

  Map<String, dynamic> toJson() =>
      {'enabled': enabled, 'hour': hour, 'minute': minute, 'days': days};

  factory ReminderSettings.fromJson(Map<String, dynamic> j) => ReminderSettings(
        enabled: j['enabled'] == true,
        hour: (j['hour'] as num?)?.toInt() ?? 18,
        minute: (j['minute'] as num?)?.toInt() ?? 0,
        days: ((j['days'] as List?) ?? [1, 2, 3, 4, 5])
            .map((e) => (e as num).toInt())
            .toList(),
      );

  ReminderSettings copyWith(
          {bool? enabled, int? hour, int? minute, List<int>? days}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        days: days ?? this.days,
      );
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _phrases = [
    'È il momento di allenarti 💪',
    'Il tuo corpo aspetta solo te 🔥',
    'Un set alla volta: si comincia!',
    'Non spezzare la serie: alleniamoci! ⛓️',
    'Pochi minuti oggi, grandi risultati domani.',
  ];

  static Future<void> init() async {
    if (_ready) return;
    try {
      tz.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } catch (_) {
      // Notifiche non disponibili (es. web): degrada silenziosamente.
    }
  }

  static Future<ReminderSettings> getSettings() async {
    final raw = await StorageService.getString(StorageService.reminderKey);
    if (raw != null) {
      try {
        return ReminderSettings.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    return const ReminderSettings();
  }

  static Future<void> _saveSettings(ReminderSettings s) =>
      StorageService.setString(
          StorageService.reminderKey, jsonEncode(s.toJson()));

  static Future<bool> _ensurePermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static tz.TZDateTime _nextInstance(int weekday, int hour, int minute) {
    // weekday: 1=lun .. 7=dom (DateTime). Convertiamo dom=0..sab=6.
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<bool> reschedule(ReminderSettings s) async {
    if (!_ready) return false;
    try {
      await _plugin.cancelAll();
      if (!s.enabled || s.days.isEmpty) {
        await _saveSettings(s);
        return true;
      }
      final granted = await _ensurePermission();
      if (!granted) {
        await _saveSettings(s.copyWith(enabled: false));
        return false;
      }
      const androidDetails = AndroidNotificationDetails(
        'reminders',
        'Promemoria allenamento',
        importance: Importance.defaultImportance,
      );
      const details = NotificationDetails(
          android: androidDetails, iOS: DarwinNotificationDetails());
      final rnd = Random();
      for (final day in s.days) {
        // day 0=dom..6=sab -> DateTime weekday 1..7 (lun..dom)
        final weekday = day == 0 ? 7 : day;
        await _plugin.zonedSchedule(
          1000 + day,
          'CaliStrack',
          _phrases[rnd.nextInt(_phrases.length)],
          _nextInstance(weekday, s.hour, s.minute),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      await _saveSettings(s);
      return true;
    } catch (_) {
      await _saveSettings(s.copyWith(enabled: false));
      return false;
    }
  }

  static Future<void> disable() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
    final s = await getSettings();
    await _saveSettings(s.copyWith(enabled: false));
  }
}
