import { useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, StyleSheet, Vibration, Animated, Easing } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../ThemeContext';
import PressableScale from '../components/PressableScale';
import { spacing, radius } from '../theme';

const PRESETS = [15, 30, 45, 60, 90];

function fmt(total) {
  const m = Math.floor(total / 60);
  const s = total % 60;
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

export default function TimerScreen({ route }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const exerciseName = route.params?.name;

  const [duration, setDuration] = useState(30); // countdown target
  const [remaining, setRemaining] = useState(30);
  const [running, setRunning] = useState(false);
  const intervalRef = useRef(null);
  const pulse = useRef(new Animated.Value(1)).current;

  // Pulsazione del cerchio mentre il timer scorre.
  useEffect(() => {
    if (running) {
      const loop = Animated.loop(
        Animated.sequence([
          Animated.timing(pulse, { toValue: 1.06, duration: 500, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
          Animated.timing(pulse, { toValue: 1, duration: 500, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        ])
      );
      loop.start();
      return () => loop.stop();
    }
    pulse.setValue(1);
  }, [running]);

  useEffect(() => {
    if (running) {
      intervalRef.current = setInterval(() => {
        setRemaining((r) => {
          if (r <= 1) {
            clearInterval(intervalRef.current);
            setRunning(false);
            Vibration.vibrate([0, 400, 200, 400]);
            return 0;
          }
          return r - 1;
        });
      }, 1000);
    }
    return () => clearInterval(intervalRef.current);
  }, [running]);

  const selectPreset = (sec) => {
    setRunning(false);
    setDuration(sec);
    setRemaining(sec);
  };

  const toggle = () => {
    if (remaining === 0) setRemaining(duration);
    setRunning((r) => !r);
  };

  const reset = () => {
    setRunning(false);
    setRemaining(duration);
  };

  const progress = duration > 0 ? remaining / duration : 0;

  return (
    <View style={styles.container}>
      {exerciseName && <Text style={styles.exercise}>{exerciseName}</Text>}

      <Animated.View style={[styles.circle, { transform: [{ scale: pulse }] }]}>
        <View
          style={[
            styles.progressBar,
            { height: `${progress * 100}%`, backgroundColor: theme.colors.primary },
          ]}
        />
        <Text style={styles.time}>{fmt(remaining)}</Text>
      </Animated.View>

      <View style={styles.presets}>
        {PRESETS.map((p) => (
          <PressableScale
            key={p}
            scaleTo={0.9}
            style={[styles.preset, duration === p && styles.presetActive]}
            onPress={() => {
              Haptics.selectionAsync();
              selectPreset(p);
            }}
          >
            <Text
              style={[styles.presetText, duration === p && styles.presetTextActive]}
            >
              {p}s
            </Text>
          </PressableScale>
        ))}
      </View>

      <View style={styles.controls}>
        <PressableScale style={styles.secondaryBtn} onPress={reset}>
          <Text style={styles.secondaryText}>Reset</Text>
        </PressableScale>
        <PressableScale
          style={styles.primaryBtn}
          onPress={() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
            toggle();
          }}
        >
          <Text style={styles.primaryText}>
            {running ? 'Pausa' : remaining === 0 ? 'Ricomincia' : 'Avvia'}
          </Text>
        </PressableScale>
      </View>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: c.bg,
      alignItems: 'center',
      padding: spacing.lg,
    },
    exercise: {
      color: c.text,
      fontSize: 20,
      fontWeight: '700',
      marginTop: spacing.md,
    },
    circle: {
      width: 220,
      height: 220,
      borderRadius: 110,
      backgroundColor: c.card,
      borderWidth: 2,
      borderColor: c.border,
      marginTop: spacing.xl,
      marginBottom: spacing.xl,
      alignItems: 'center',
      justifyContent: 'center',
      overflow: 'hidden',
    },
    progressBar: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      opacity: 0.25,
    },
    time: { color: c.text, fontSize: 52, fontWeight: '800', fontVariant: ['tabular-nums'] },
    presets: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      gap: spacing.sm,
      justifyContent: 'center',
    },
    preset: {
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderRadius: radius.lg,
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
    },
    presetActive: { backgroundColor: c.primary, borderColor: c.primary },
    presetText: { color: c.textMuted, fontWeight: '600' },
    presetTextActive: { color: c.bg },
    controls: {
      flexDirection: 'row',
      gap: spacing.md,
      marginTop: spacing.xl,
    },
    primaryBtn: {
      backgroundColor: c.primary,
      borderRadius: radius.md,
      paddingHorizontal: spacing.xl,
      paddingVertical: spacing.md,
    },
    primaryText: { color: c.bg, fontWeight: '700', fontSize: 16 },
    secondaryBtn: {
      borderWidth: 1,
      borderColor: c.border,
      borderRadius: radius.md,
      paddingHorizontal: spacing.xl,
      paddingVertical: spacing.md,
    },
    secondaryText: { color: c.text, fontWeight: '700', fontSize: 16 },
  });
