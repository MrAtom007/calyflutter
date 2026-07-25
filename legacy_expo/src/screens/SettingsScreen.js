import { useCallback, useMemo, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert, Switch } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../ThemeContext';
import { themeList, spacing, radius } from '../theme';
import {
  clearAll,
  isEncryptionEnabled,
  enableEncryption,
  disableEncryption,
} from '../storage';
import { exportWorkouts } from '../export';
import { getReminderSettings, rescheduleReminders, disableReminders } from '../notifications';
import PressableScale from '../components/PressableScale';
import { useOnboarding } from '../OnboardingContext';
import { useSecurity } from '../SecurityContext';
import {
  LOCK_MODES,
  LOCK_POLICIES,
  disableLock,
  setDeviceMode,
  getSecuritySupport,
  isBioQuickEnabled,
  setBioQuickEnabled,
  getLockPolicy,
  setLockPolicy,
} from '../security';
import SetPinModal from '../components/SetPinModal';

// Suggerimenti di stile in base al tipo di utilizzatore.
const suggestions = [
  {
    profile: '🌙 Chi si allena la sera',
    theme: 'Midnight o Carbon',
    reason: 'Sfondi molto scuri, meno affaticamento visivo al buio.',
  },
  {
    profile: '☀️ Chi si allena all\u2019aperto',
    theme: 'Paper',
    reason: 'Tema chiaro ad alto contrasto, leggibile alla luce del sole.',
  },
  {
    profile: '🔋 Telefoni AMOLED',
    theme: 'Carbon',
    reason: 'Nero puro: risparmia batteria e dà un look elegante.',
  },
  {
    profile: '🔥 Chi cerca la carica',
    theme: 'Sunset o Grape',
    reason: 'Colori caldi e vivaci per darti energia negli allenamenti.',
  },
  {
    profile: '🧘 Chi vuole concentrazione',
    theme: 'Ocean',
    reason: 'Blu rilassante, ideale per sessioni lunghe e focus.',
  },
];

export default function SettingsScreen({ navigation }) {
  const { theme, themeId, changeTheme, glow, toggleGlow, isUnlocked } = useTheme();
  const { replay } = useOnboarding();
  const { mode, syncSettings } = useSecurity();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);

  const [support, setSupport] = useState(null);
  const [bioQuick, setBioQuick] = useState(false);
  const [pinModal, setPinModal] = useState(false);
  const [policy, setPolicy] = useState(LOCK_POLICIES.LAUNCH);
  const [encrypted, setEncrypted] = useState(false);
  const [reminder, setReminder] = useState({
    enabled: false,
    hour: 18,
    minute: 0,
    days: [1, 2, 3, 4, 5],
  });

  useFocusEffect(
    useCallback(() => {
      getSecuritySupport().then(setSupport);
      isBioQuickEnabled().then(setBioQuick);
      getLockPolicy().then(setPolicy);
      isEncryptionEnabled().then(setEncrypted);
      getReminderSettings().then(setReminder);
    }, [mode])
  );

  const DAYS = ['L', 'M', 'M', 'G', 'V', 'S', 'D']; // indice 0..6 = lun..dom
  const dayToIdx = (uiIdx) => (uiIdx + 1) % 7; // ui lun=0 -> storage lun=1, dom(ui6)->0

  const applyReminder = async (next) => {
    setReminder(next);
    const ok = await rescheduleReminders(next);
    if (!ok && next.enabled) {
      Alert.alert(
        'Permesso negato',
        'Attiva le notifiche per CaliStrack nelle impostazioni del telefono.'
      );
      setReminder({ ...next, enabled: false });
    }
  };

  const toggleReminder = (value) => {
    Haptics.selectionAsync();
    if (!value) {
      disableReminders();
      setReminder((r) => ({ ...r, enabled: false }));
      return;
    }
    applyReminder({ ...reminder, enabled: true });
  };

  const toggleDay = (idx) => {
    const has = reminder.days.includes(idx);
    const days = has ? reminder.days.filter((d) => d !== idx) : [...reminder.days, idx];
    const next = { ...reminder, days: days.sort((a, b) => a - b) };
    if (reminder.enabled) applyReminder(next);
    else setReminder(next);
  };

  const shiftTime = (deltaMin) => {
    let total = reminder.hour * 60 + reminder.minute + deltaMin;
    total = (total + 24 * 60) % (24 * 60);
    const next = { ...reminder, hour: Math.floor(total / 60), minute: total % 60 };
    if (reminder.enabled) applyReminder(next);
    else setReminder(next);
  };

  const fmtTime = () =>
    `${String(reminder.hour).padStart(2, '0')}:${String(reminder.minute).padStart(2, '0')}`;

  const toggleEncryption = async (value) => {
    Haptics.selectionAsync();
    try {
      if (value) await enableEncryption();
      else await disableEncryption();
      setEncrypted(value);
    } catch (e) {
      Alert.alert('Errore', 'Impossibile aggiornare la cifratura.');
    }
  };

  const changePolicy = async (p) => {
    await setLockPolicy(p);
    setPolicy(p);
    await syncSettings();
  };

  const policyOptions = [
    { id: LOCK_POLICIES.LAUNCH, label: 'Solo all\u2019avvio', desc: 'Riaprendo dal background non chiede nulla.' },
    { id: LOCK_POLICIES.GRACE, label: 'Dopo 2 minuti', desc: 'Chiede solo se resta a lungo in background.' },
    { id: LOCK_POLICIES.IMMEDIATE, label: 'Sempre', desc: 'Ogni volta che torni nell\u2019app.' },
  ];

  const chooseNone = async () => {
    await disableLock();
    await syncSettings();
  };

  const choosePin = () => setPinModal(true);

  const chooseDevice = async () => {
    if (!support?.deviceLockAvailable) {
      Alert.alert(
        'Non disponibile',
        'Imposta prima un codice di blocco o la biometria nelle impostazioni del telefono.'
      );
      return;
    }
    await setDeviceMode();
    await syncSettings();
  };

  const onPinDone = async () => {
    setPinModal(false);
    await syncSettings();
  };

  const toggleBioQuick = async (value) => {
    await setBioQuickEnabled(value);
    setBioQuick(value);
  };

  const securityOptions = [
    {
      id: LOCK_MODES.NONE,
      icon: 'lock-open-variant-outline',
      title: 'Nessuna protezione',
      desc: 'L\u2019app si apre senza sblocco.',
      onPress: chooseNone,
      enabled: true,
    },
    {
      id: LOCK_MODES.PIN,
      icon: 'dialpad',
      title: 'PIN dell\u2019app',
      desc: 'Codice di 4-6 cifre dedicato a CaliStrack.',
      onPress: choosePin,
      enabled: true,
    },
    {
      id: LOCK_MODES.DEVICE,
      icon: 'cellphone-key',
      title: 'Blocco del dispositivo',
      desc: support?.biometricAvailable
        ? `${support.biometricLabel} o codice dello schermo.`
        : 'Face ID, impronta o codice dello schermo.',
      onPress: chooseDevice,
      enabled: true,
    },
  ];

  const onReset = () => {
    Alert.alert('Cancella dati', 'Eliminare tutti gli allenamenti salvati?', [
      { text: 'Annulla', style: 'cancel' },
      { text: 'Elimina', style: 'destructive', onPress: () => clearAll() },
    ]);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.section}>Tema colore</Text>
      <View style={styles.grid}>
        {themeList.map((t) => {
          const active = t.id === themeId;
          const locked = t.premium && !isUnlocked(t.id);
          return (
            <TouchableOpacity
              key={t.id}
              style={[
                styles.themeCard,
                active && styles.themeCardActive,
                t.neon && !locked && { borderColor: t.glow },
              ]}
              onPress={() =>
                locked
                  ? navigation.navigate('Home', { screen: 'Store' })
                  : changeTheme(t.id)
              }
            >
              <View style={styles.swatches}>
                <View style={[styles.swatch, { backgroundColor: t.colors.bg }]} />
                <View style={[styles.swatch, { backgroundColor: t.colors.card }]} />
                <View style={[styles.swatch, { backgroundColor: t.colors.primary }]} />
              </View>
              <Text style={styles.themeName}>
                {t.name} {t.premium ? '✦' : ''}
              </Text>
              <Text style={styles.themeDesc}>{t.description}</Text>
              {locked ? (
                <Text style={styles.lockedTag}>🔒 Store</Text>
              ) : active ? (
                <Text style={styles.activeTag}>✓ Attivo</Text>
              ) : null}
            </TouchableOpacity>
          );
        })}
      </View>

      {theme.neon && (
        <View style={styles.secRow}>
          <MaterialCommunityIcons name="lightning-bolt" size={22} color={theme.colors.primary} />
          <View style={{ flex: 1 }}>
            <Text style={styles.secTitle}>Effetto glow neon</Text>
            <Text style={styles.secDesc}>Aloni luminosi sui temi neon.</Text>
          </View>
          <Switch value={glow} onValueChange={toggleGlow} trackColor={{ true: theme.colors.primary }} />
        </View>
      )}

      <Text style={styles.section}>Stili suggeriti</Text>
      {suggestions.map((s, i) => (
        <View key={i} style={styles.suggestion}>
          <Text style={styles.suggProfile}>{s.profile}</Text>
          <Text style={styles.suggTheme}>Consigliato: {s.theme}</Text>
          <Text style={styles.suggReason}>{s.reason}</Text>
        </View>
      ))}

      <Text style={styles.section}>Sicurezza e sblocco</Text>
      {securityOptions.map((opt) => {
        const active = mode === opt.id;
        return (
          <TouchableOpacity
            key={opt.id}
            style={[styles.secRow, active && styles.secRowActive]}
            onPress={opt.onPress}
          >
            <MaterialCommunityIcons name={opt.icon} size={24} color={theme.colors.primary} />
            <View style={{ flex: 1 }}>
              <Text style={styles.secTitle}>{opt.title}</Text>
              <Text style={styles.secDesc}>{opt.desc}</Text>
            </View>
            <View style={[styles.radio, active && styles.radioActive]}>
              {active && <View style={styles.radioDot} />}
            </View>
          </TouchableOpacity>
        );
      })}

      {mode === LOCK_MODES.PIN && support?.biometricAvailable && (
        <View style={styles.secRow}>
          <Text style={styles.secIcon}>👆</Text>
          <View style={{ flex: 1 }}>
            <Text style={styles.secTitle}>Sblocco rapido {support.biometricLabel}</Text>
            <Text style={styles.secDesc}>Usa la biometria oltre al PIN.</Text>
          </View>
          <Switch
            value={bioQuick}
            onValueChange={toggleBioQuick}
            trackColor={{ true: theme.colors.primary }}
          />
        </View>
      )}

      {mode !== LOCK_MODES.NONE && (
        <>
          <Text style={styles.subSection}>Quando richiedere lo sblocco</Text>
          {policyOptions.map((opt) => {
            const active = policy === opt.id;
            return (
              <TouchableOpacity
                key={opt.id}
                style={[styles.secRow, active && styles.secRowActive]}
                onPress={() => changePolicy(opt.id)}
              >
                <View style={{ flex: 1 }}>
                  <Text style={styles.secTitle}>{opt.label}</Text>
                  <Text style={styles.secDesc}>{opt.desc}</Text>
                </View>
                <View style={[styles.radio, active && styles.radioActive]}>
                  {active && <View style={styles.radioDot} />}
                </View>
              </TouchableOpacity>
            );
          })}
        </>
      )}

      <Text style={styles.securityNote}>
        🔐 I dati restano solo sul tuo dispositivo (nessun invio online). Il PIN è
        salvato cifrato con hash SHA-256 nel Secure Store del sistema. L'app si blocca
        automaticamente quando la chiudi o passa in background.
      </Text>

      <Text style={styles.section}>Promemoria allenamento</Text>
      <View style={styles.secRow}>
        <MaterialCommunityIcons name="bell-ring-outline" size={24} color={theme.colors.primary} />
        <View style={{ flex: 1 }}>
          <Text style={styles.secTitle}>Notifiche di allenamento</Text>
          <Text style={styles.secDesc}>Ricevi un promemoria nei giorni scelti.</Text>
        </View>
        <Switch
          value={reminder.enabled}
          onValueChange={toggleReminder}
          trackColor={{ true: theme.colors.primary }}
        />
      </View>

      {reminder.enabled && (
        <>
          <View style={styles.timeRow}>
            <Text style={styles.secTitle}>Orario</Text>
            <View style={styles.timeControls}>
              <PressableScale style={styles.timeBtn} onPress={() => shiftTime(-30)}>
                <MaterialCommunityIcons name="minus" size={20} color={theme.colors.text} />
              </PressableScale>
              <Text style={styles.timeValue}>{fmtTime()}</Text>
              <PressableScale style={styles.timeBtn} onPress={() => shiftTime(30)}>
                <MaterialCommunityIcons name="plus" size={20} color={theme.colors.text} />
              </PressableScale>
            </View>
          </View>
          <View style={styles.daysRow}>
            {DAYS.map((label, uiIdx) => {
              const idx = dayToIdx(uiIdx);
              const active = reminder.days.includes(idx);
              return (
                <PressableScale
                  key={uiIdx}
                  scaleTo={0.88}
                  style={[styles.dayChip, active && styles.dayChipActive]}
                  onPress={() => toggleDay(idx)}
                >
                  <Text style={[styles.dayChipText, active && styles.dayChipTextActive]}>
                    {label}
                  </Text>
                </PressableScale>
              );
            })}
          </View>
        </>
      )}

      <Text style={styles.section}>Backup e privacy</Text>
      <View style={styles.secRow}>
        <MaterialCommunityIcons name="shield-lock-outline" size={24} color={theme.colors.primary} />
        <View style={{ flex: 1 }}>
          <Text style={styles.secTitle}>Cifratura end-to-end</Text>
          <Text style={styles.secDesc}>
            Cronologia cifrata AES-256 con chiave nel Secure Store.
          </Text>
        </View>
        <Switch
          value={encrypted}
          onValueChange={toggleEncryption}
          trackColor={{ true: theme.colors.primary }}
        />
      </View>

      <View style={styles.exportRow}>
        <PressableScale style={styles.exportBtn} onPress={() => exportWorkouts('csv')}>
          <MaterialCommunityIcons name="file-delimited-outline" size={18} color={theme.colors.primary} />
          <Text style={styles.actionText}>Esporta CSV</Text>
        </PressableScale>
        <PressableScale style={styles.exportBtn} onPress={() => exportWorkouts('json')}>
          <MaterialCommunityIcons name="code-json" size={18} color={theme.colors.primary} />
          <Text style={styles.actionText}>Esporta JSON</Text>
        </PressableScale>
      </View>

      <Text style={styles.section}>Guida</Text>
      <TouchableOpacity style={styles.actionBtn} onPress={replay}>
        <MaterialCommunityIcons name="restart" size={18} color={theme.colors.text} />
        <Text style={styles.actionText}>Rivedi il tutorial</Text>
      </TouchableOpacity>

      <Text style={styles.section}>Dati</Text>
      <TouchableOpacity style={styles.dangerBtn} onPress={onReset}>
        <Text style={styles.dangerText}>Cancella tutti gli allenamenti</Text>
      </TouchableOpacity>

      <Text style={styles.footer}>CaliStrack • v2.6.0</Text>

      <SetPinModal
        visible={pinModal}
        onClose={() => setPinModal(false)}
        onDone={onPinDone}
      />
    </ScrollView>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md, paddingBottom: spacing.xl },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.md,
      marginBottom: spacing.sm,
    },
    grid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
    themeCard: {
      width: '48%',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      borderWidth: 2,
      borderColor: c.border,
    },
    themeCardActive: { borderColor: c.primary },
    swatches: { flexDirection: 'row', gap: 4, marginBottom: spacing.sm },
    swatch: {
      width: 22,
      height: 22,
      borderRadius: 6,
      borderWidth: 1,
      borderColor: c.border,
    },
    themeName: { color: c.text, fontWeight: '700' },
    themeDesc: { color: c.textMuted, fontSize: 11, marginTop: 2 },
    activeTag: { color: c.primary, fontSize: 12, fontWeight: '700', marginTop: spacing.sm },
    lockedTag: { color: c.textMuted, fontSize: 12, fontWeight: '700', marginTop: spacing.sm },
    suggestion: {
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    suggProfile: { color: c.text, fontWeight: '700' },
    suggTheme: { color: c.primary, fontSize: 13, marginTop: 2 },
    suggReason: { color: c.textMuted, fontSize: 13, marginTop: 2 },
    actionBtn: {
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
      flexDirection: 'row',
      justifyContent: 'center',
      gap: spacing.sm,
    },
    actionText: { color: c.text, fontWeight: '700' },
    timeRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    timeControls: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
    timeBtn: {
      width: 38,
      height: 38,
      borderRadius: 19,
      backgroundColor: c.cardAlt,
      alignItems: 'center',
      justifyContent: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    timeValue: {
      color: c.text,
      fontSize: 20,
      fontWeight: '800',
      fontVariant: ['tabular-nums'],
      minWidth: 64,
      textAlign: 'center',
    },
    daysRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.sm },
    dayChip: {
      width: 40,
      height: 40,
      borderRadius: 20,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
    },
    dayChipActive: { backgroundColor: c.primary, borderColor: c.primary },
    dayChipText: { color: c.textMuted, fontWeight: '700' },
    dayChipTextActive: { color: c.bg },
    exportRow: { flexDirection: 'row', gap: spacing.sm, marginBottom: spacing.sm },
    exportBtn: {
      flex: 1,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      gap: spacing.xs,
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
      borderRadius: radius.md,
      padding: spacing.md,
    },
    secRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    secRowActive: { borderColor: c.primary },
    subSection: {
      color: c.textMuted,
      fontSize: 13,
      fontWeight: '700',
      marginTop: spacing.sm,
      marginBottom: spacing.sm,
      textTransform: 'uppercase',
      letterSpacing: 0.5,
    },
    secIcon: { fontSize: 24 },
    secTitle: { color: c.text, fontWeight: '700' },
    secDesc: { color: c.textMuted, fontSize: 12, marginTop: 2 },
    radio: {
      width: 22,
      height: 22,
      borderRadius: 11,
      borderWidth: 2,
      borderColor: c.border,
      alignItems: 'center',
      justifyContent: 'center',
    },
    radioActive: { borderColor: c.primary },
    radioDot: {
      width: 10,
      height: 10,
      borderRadius: 5,
      backgroundColor: c.primary,
    },
    securityNote: {
      color: c.textMuted,
      fontSize: 12,
      lineHeight: 18,
      marginTop: spacing.sm,
    },
    dangerBtn: {
      borderWidth: 1,
      borderColor: c.danger,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
    },
    dangerText: { color: c.danger, fontWeight: '700' },
    footer: {
      color: c.textMuted,
      textAlign: 'center',
      marginTop: spacing.xl,
      fontSize: 12,
    },
  });
