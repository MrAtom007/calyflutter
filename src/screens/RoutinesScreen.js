import { useMemo } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity } from 'react-native';
import { getRoutines } from '../data/routines';
import { getExercise } from '../data/exercises';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import DisciplineSwitch from '../components/DisciplineSwitch';
import FadeInView from '../components/FadeInView';
import PressableScale from '../components/PressableScale';
import { spacing, radius } from '../theme';

export default function RoutinesScreen({ navigation }) {
  const { theme } = useTheme();
  const { discipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const routines = getRoutines(discipline);

  const startRoutine = (routine) => {
    navigation.navigate('Home', {
      screen: 'NewWorkout',
      params: { preset: routine.sets },
    });
  };

  const renderItem = ({ item, index }) => (
    <FadeInView delay={index * 70} style={styles.card}>
      <View style={styles.cardHeader}>
        <Text style={styles.name}>{item.name}</Text>
        <Text style={styles.badge}>{item.level}</Text>
      </View>
      <Text style={styles.desc}>{item.description}</Text>
      <Text style={styles.meta}>
        {item.duration} • {item.sets.length} esercizi
      </Text>
      <View style={styles.exList}>
        {item.sets.map((s, i) => {
          const ex = getExercise(s.exerciseId);
          const val = s.weight
            ? `${s.weight}kg×${s.reps}`
            : s.sec
            ? `${s.sec}s`
            : `x${s.reps}`;
          return (
            <Text key={i} style={styles.exItem}>
              • {ex?.name} <Text style={styles.exVal}>{val}</Text>
            </Text>
          );
        })}
      </View>
      <PressableScale style={styles.startBtn} onPress={() => startRoutine(item)}>
        <Text style={styles.startText}>Avvia routine</Text>
      </PressableScale>
    </FadeInView>
  );

  return (
    <View style={styles.container}>
      <DisciplineSwitch />
      <FlatList
        data={routines}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        contentContainerStyle={styles.list}
      />
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    list: { padding: spacing.md, gap: spacing.md },
    card: {
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.md,
      borderWidth: 1,
      borderColor: c.border,
    },
    cardHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
    },
    name: { color: c.text, fontSize: 17, fontWeight: '700', flex: 1 },
    badge: {
      color: c.bg,
      backgroundColor: c.primary,
      fontSize: 11,
      fontWeight: '700',
      paddingHorizontal: spacing.sm,
      paddingVertical: 2,
      borderRadius: radius.sm,
      overflow: 'hidden',
    },
    desc: { color: c.textMuted, marginTop: spacing.xs },
    meta: { color: c.textMuted, fontSize: 12, marginTop: spacing.xs },
    exList: { marginTop: spacing.sm, gap: 2 },
    exItem: { color: c.text, fontSize: 13 },
    exVal: { color: c.primary, fontWeight: '700' },
    startBtn: {
      marginTop: spacing.md,
      backgroundColor: c.primary,
      borderRadius: radius.md,
      padding: spacing.sm,
      alignItems: 'center',
    },
    startText: { color: c.bg, fontWeight: '700' },
  });
