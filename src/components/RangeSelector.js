import { useMemo } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import * as Haptics from 'expo-haptics';
import PressableScale from './PressableScale';
import { useTheme } from '../ThemeContext';
import { spacing, radius } from '../theme';

// Selettore a pillole per l'intervallo temporale dei grafici.
// options: [{ key, label }]
export default function RangeSelector({ options, value, onChange }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);

  return (
    <View style={styles.row}>
      {options.map((opt) => {
        const active = opt.key === value;
        return (
          <PressableScale
            key={opt.key}
            style={[styles.pill, active && styles.pillActive]}
            onPress={() => {
              if (!active) {
                Haptics.selectionAsync();
                onChange(opt.key);
              }
            }}
          >
            <Text style={[styles.pillText, active && styles.pillTextActive]}>
              {opt.label}
            </Text>
          </PressableScale>
        );
      })}
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    row: {
      flexDirection: 'row',
      backgroundColor: c.cardAlt,
      borderRadius: radius.lg,
      padding: 3,
      alignSelf: 'flex-start',
      gap: 3,
    },
    pill: {
      paddingHorizontal: spacing.md,
      paddingVertical: 6,
      borderRadius: radius.lg,
    },
    pillActive: { backgroundColor: c.primary },
    pillText: { color: c.textMuted, fontSize: 12, fontWeight: '700' },
    pillTextActive: { color: c.bg },
  });
