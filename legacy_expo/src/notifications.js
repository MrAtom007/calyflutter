import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Promemoria allenamento: notifiche locali ricorrenti (giornaliere) all'orario
// scelto dall'utente. Nessun server: tutto pianificato in locale dal sistema.

const REMINDER_KEY = '@calistrack/reminder'; // { enabled, hour, minute, days: [0..6] }

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

const PHRASES = [
  'È il momento di allenarti 💪',
  'Il tuo corpo aspetta solo te 🔥',
  'Un set alla volta: si comincia!',
  'Non spezzare la serie: alleniamoci! ⛓️',
  'Pochi minuti oggi, grandi risultati domani.',
];

export async function getReminderSettings() {
  try {
    const raw = await AsyncStorage.getItem(REMINDER_KEY);
    if (raw) return JSON.parse(raw);
  } catch (_) {}
  return { enabled: false, hour: 18, minute: 0, days: [1, 2, 3, 4, 5] };
}

async function saveReminderSettings(settings) {
  await AsyncStorage.setItem(REMINDER_KEY, JSON.stringify(settings));
}

export async function ensurePermission() {
  const current = await Notifications.getPermissionsAsync();
  let status = current.status;
  if (status !== 'granted') {
    const req = await Notifications.requestPermissionsAsync();
    status = req.status;
  }
  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('reminders', {
      name: 'Promemoria allenamento',
      importance: Notifications.AndroidImportance.DEFAULT,
    });
  }
  return status === 'granted';
}

// Riprogramma tutte le notifiche in base alle impostazioni correnti.
export async function rescheduleReminders(settings) {
  await Notifications.cancelAllScheduledNotificationsAsync();
  if (!settings.enabled || !settings.days || settings.days.length === 0) {
    await saveReminderSettings(settings);
    return true;
  }
  const granted = await ensurePermission();
  if (!granted) {
    await saveReminderSettings({ ...settings, enabled: false });
    return false;
  }
  // Expo usa weekday 1..7 con 1 = domenica. I nostri giorni: 0=dom..6=sab.
  for (const day of settings.days) {
    await Notifications.scheduleNotificationAsync({
      content: {
        title: 'CaliStrack',
        body: PHRASES[Math.floor(Math.random() * PHRASES.length)],
      },
      trigger: {
        type: Notifications.SchedulableTriggerInputTypes.WEEKLY,
        weekday: (day % 7) + 1,
        hour: settings.hour,
        minute: settings.minute,
        channelId: 'reminders',
      },
    });
  }
  await saveReminderSettings(settings);
  return true;
}

export async function disableReminders() {
  await Notifications.cancelAllScheduledNotificationsAsync();
  const s = await getReminderSettings();
  await saveReminderSettings({ ...s, enabled: false });
}
