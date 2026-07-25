import { useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Animated } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../ThemeContext';
import { useDiscipline, DISCIPLINES } from '../DisciplineContext';
import { spacing, radius, glowShadow } from '../theme';

export default function DisciplineSwitch() {
  const { theme, glowActive } = useTheme();
  const { discipline, setDiscipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [w, setW] = useState(0);
  const anim = useRef(new Animated.Value(0)).current;

  const list = Object.values(DISCIPLINES);
  const index = list.findIndex((d) => d.id === discipline);

  useEffect(() => {
    Animated.spring(anim, {
      toValue: index,
      useNativeDriver: true,
      friction: 8,
      tension: 80,
    }).start();
  }, [index]);

  const pad = 4;
  const segW = w > 0 ? (w - pad * 2) / list.length : 0;
  const translateX = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, segW],
  });

  return (
    <View style={styles.wrap} onLayout={(e) => setW(e.nativeEvent.layout.width)}>
      {segW > 0 && (
        <Animated.View
          style={[
            styles.indicator,
            glowActive && glowShadow(theme.glow, 10),
            { width: segW, transform: [{ translateX }] },
          ]}
        />
      )}
      {list.map((d) => {
        const active = discipline === d.id;
        return (
          <TouchableOpacity
            key={d.id}
            style={styles.segment}
            onPress={() => {
              Haptics.selectionAsync();
              setDiscipline(d.id);
            }}
          >
            <Text style={[styles.text, active && styles.textActive]}>
              {d.icon} {d.label}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    wrap: {
      flexDirection: 'row',
      backgroundColor: c.card,
      borderRadius: radius.lg,
      padding: 4,
      margin: spacing.md,
      marginBottom: 0,
      borderWidth: 1,
      borderColor: c.border,
    },
    indicator: {
      position: 'absolute',
      top: 4,
      left: 4,
      bottom: 4,
      backgroundColor: c.primary,
      borderRadius: radius.md,
    },
    segment: {
      flex: 1,
      paddingVertical: spacing.sm,
      alignItems: 'center',
      borderRadius: radius.md,
    },
    text: { color: c.textMuted, fontWeight: '600' },
    textActive: { color: c.bg, fontWeight: '700' },
  });
