import { useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Animated, Easing } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../ThemeContext';
import { useSecurity } from '../SecurityContext';
import {
  verifyPin,
  isBioQuickEnabled,
  getSecuritySupport,
  authenticateBiometric,
  authenticateDevice,
  LOCK_MODES,
} from '../security';
import { spacing, radius } from '../theme';

const KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];

export default function LockScreen() {
  const { theme } = useTheme();
  const { mode, unlock: rawUnlock } = useSecurity();
  const unlock = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    rawUnlock();
  };
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [pin, setPin] = useState('');
  const [error, setError] = useState(false);
  const [bioLabel, setBioLabel] = useState(null);
  const [busy, setBusy] = useState(false);
  const shake = useRef(new Animated.Value(0)).current;
  const authing = useRef(false); // evita chiamate concorrenti che bloccano l'app

  // Animazioni d'ingresso: header, pallini e tastierino appaiono in sequenza.
  const enterHeader = useRef(new Animated.Value(0)).current;
  const enterDots = useRef(new Animated.Value(0)).current;
  const enterPad = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.stagger(120, [
      Animated.timing(enterHeader, {
        toValue: 1,
        duration: 420,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(enterDots, {
        toValue: 1,
        duration: 380,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.spring(enterPad, { toValue: 1, friction: 7, tension: 60, useNativeDriver: true }),
    ]).start();
  }, []);

  const headerStyle = {
    opacity: enterHeader,
    transform: [
      { translateY: enterHeader.interpolate({ inputRange: [0, 1], outputRange: [-18, 0] }) },
    ],
  };
  const dotsEnterStyle = {
    opacity: enterDots,
  };
  const padStyle = {
    opacity: enterPad,
    transform: [
      { scale: enterPad.interpolate({ inputRange: [0, 1], outputRange: [0.85, 1] }) },
      { translateY: enterPad.interpolate({ inputRange: [0, 1], outputRange: [24, 0] }) },
    ],
  };

  const runDevice = async () => {
    if (authing.current) return;
    authing.current = true;
    setBusy(true);
    try {
      const ok = await authenticateDevice();
      if (ok) unlock();
    } catch (_) {
      // ignora: l'utente può ritentare col pulsante
    } finally {
      authing.current = false;
      setBusy(false);
    }
  };

  const runBiometricQuick = async () => {
    if (authing.current) return;
    authing.current = true;
    setBusy(true);
    try {
      const ok = await authenticateBiometric();
      if (ok) unlock();
    } catch (_) {
      // ignora
    } finally {
      authing.current = false;
      setBusy(false);
    }
  };

  useEffect(() => {
    (async () => {
      if (mode === LOCK_MODES.DEVICE) {
        runDevice();
        return;
      }
      const support = await getSecuritySupport();
      if (support.biometricAvailable && (await isBioQuickEnabled())) {
        setBioLabel(support.biometricLabel);
        runBiometricQuick();
      }
    })();
  }, [mode]);

  const doShake = () => {
    setError(true);
    Animated.sequence([
      Animated.timing(shake, { toValue: 10, duration: 50, useNativeDriver: true }),
      Animated.timing(shake, { toValue: -10, duration: 50, useNativeDriver: true }),
      Animated.timing(shake, { toValue: 6, duration: 50, useNativeDriver: true }),
      Animated.timing(shake, { toValue: 0, duration: 50, useNativeDriver: true }),
    ]).start();
  };

  const onKey = async (k) => {
    if (k === 'del') {
      setPin((p) => p.slice(0, -1));
      setError(false);
      return;
    }
    if (k === '') return;
    const next = (pin + k).slice(0, 6);
    setPin(next);
    setError(false);
    if (next.length >= 4) {
      if (await verifyPin(next)) {
        unlock();
      } else if (next.length === 6) {
        doShake();
        setTimeout(() => setPin(''), 350);
      }
    }
  };

  // Modalità blocco dispositivo: nessun tastierino, solo pulsante di sblocco.
  if (mode === LOCK_MODES.DEVICE) {
    return (
      <View style={styles.container}>
        <Text style={styles.lockIcon}>🔒</Text>
        <Text style={styles.title}>CaliStrack bloccata</Text>
        <Text style={styles.subtitle}>
          Usa Face ID, l'impronta o il codice del dispositivo
        </Text>
        <TouchableOpacity
          style={[styles.unlockBtn, busy && { opacity: 0.6 }]}
          onPress={runDevice}
          disabled={busy}
        >
          <Text style={styles.unlockText}>{busy ? 'Attendi…' : 'Sblocca'}</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.header, headerStyle]}>
        <Text style={styles.lockIcon}>🔒</Text>
        <Text style={styles.title}>CaliStrack bloccata</Text>
        <Text style={styles.subtitle}>Inserisci il PIN per continuare</Text>
      </Animated.View>

      <Animated.View
        style={[styles.dots, dotsEnterStyle, { transform: [{ translateX: shake }] }]}
      >
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <View
            key={i}
            style={[
              styles.dot,
              i < pin.length && styles.dotFilled,
              error && styles.dotError,
            ]}
          />
        ))}
      </Animated.View>

      <Animated.View style={[styles.pad, padStyle]}>
        {KEYS.map((k, i) => (
          <TouchableOpacity
            key={i}
            style={[styles.key, k === '' && styles.keyEmpty]}
            disabled={k === ''}
            onPress={() => onKey(k)}
          >
            <Text style={styles.keyText}>{k === 'del' ? '⌫' : k}</Text>
          </TouchableOpacity>
        ))}
      </Animated.View>

      {bioLabel && (
        <TouchableOpacity style={styles.bioBtn} onPress={runBiometricQuick}>
          <Text style={styles.bioText}>Sblocca con {bioLabel}</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: c.bg,
      alignItems: 'center',
      justifyContent: 'center',
      padding: spacing.xl,
    },
    header: { alignItems: 'center' },
    lockIcon: { fontSize: 48 },
    title: { color: c.text, fontSize: 22, fontWeight: '800', marginTop: spacing.md },
    subtitle: {
      color: c.textMuted,
      marginTop: spacing.xs,
      textAlign: 'center',
    },
    dots: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.xl },
    dot: {
      width: 14,
      height: 14,
      borderRadius: 7,
      borderWidth: 2,
      borderColor: c.border,
    },
    dotFilled: { backgroundColor: c.primary, borderColor: c.primary },
    dotError: { borderColor: c.danger },
    pad: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      width: 280,
      marginTop: spacing.xl,
      justifyContent: 'center',
    },
    key: {
      width: 80,
      height: 80,
      borderRadius: 40,
      alignItems: 'center',
      justifyContent: 'center',
      margin: 6,
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
    },
    keyEmpty: { backgroundColor: 'transparent', borderColor: 'transparent' },
    keyText: { color: c.text, fontSize: 26, fontWeight: '600' },
    bioBtn: { marginTop: spacing.xl },
    bioText: { color: c.primary, fontWeight: '700', fontSize: 16 },
    unlockBtn: {
      marginTop: spacing.xl,
      backgroundColor: c.primary,
      borderRadius: radius.md,
      paddingHorizontal: spacing.xl,
      paddingVertical: spacing.md,
    },
    unlockText: { color: c.bg, fontWeight: '800', fontSize: 16 },
  });
