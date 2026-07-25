import { useCallback, useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
} from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { getWorkouts, getLastLevel, setLastLevel } from '../storage';
import { getExercise } from '../data/exercises';
import { totalPoints, rankFor, levelOf, maxLevel, ranks } from '../data/ranks';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import { useLevelUp } from '../LevelUpContext';
import DisciplineSwitch from '../components/DisciplineSwitch';
import Medal from '../components/Medal';
import FadeInView from '../components/FadeInView';
import * as Haptics from 'expo-haptics';
import { spacing, radius, glowShadow } from '../theme';

function formatDate(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString('it-IT', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function setSummary(s) {
  const ex = getExercise(s.exerciseId);
  if (!ex) return '';
  if (ex.unit === 'weight') return `${ex.name} ${s.weight || 0}kg×${s.reps || 0}`;
  if (ex.unit === 'sec') return `${ex.name} ${s.sec || 0}s`;
  return `${ex.name} ×${s.reps || 0}`;
}

export default function HomeScreen({ navigation }) {
  const { theme, glowActive } = useTheme();
  const { discipline } = useDiscipline();
  const { celebrate } = useLevelUp();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [workouts, setWorkouts] = useState([]);

  useFocusEffect(
    useCallback(() => {
      let active = true;
      getWorkouts(discipline).then(async (w) => {
        if (!active) return;
        setWorkouts(w);
        // Rilevamento level up.
        const pts = totalPoints(w);
        const lvl = levelOf(rankFor(pts).current.id);
        const prev = await getLastLevel(discipline);
        if (prev !== null && lvl > prev) {
          celebrate(ranks[lvl - 1], lvl);
        }
        if (prev === null || lvl !== prev) {
          await setLastLevel(discipline, lvl);
        }
      });
      return () => {
        active = false;
      };
    }, [discipline])
  );

  const totalWorkouts = workouts.length;
  const totalSets = workouts.reduce((acc, w) => acc + w.sets.length, 0);
  const points = totalPoints(workouts);
  const { current, next, progress } = rankFor(points);

  const renderItem = ({ item, index }) => (
    <FadeInView delay={Math.min(index, 8) * 55}>
      <TouchableOpacity
        style={styles.card}
        onPress={() => navigation.navigate('WorkoutDetail', { id: item.id })}
      >
        <Text style={styles.cardDate}>{formatDate(item.date)}</Text>
        <Text style={styles.cardExercises} numberOfLines={1}>
          {item.sets.length} set • {item.sets.map(setSummary).slice(0, 2).join(', ')}
        </Text>
      </TouchableOpacity>
    </FadeInView>
  );

  return (
    <View style={styles.container}>
      <DisciplineSwitch />

      <FadeInView>
      <TouchableOpacity
        style={styles.rankCard}
        onPress={() => navigation.navigate('Medaglie')}
      >
        <Medal rank={current} progress={progress} size={64} />
        <View style={{ flex: 1 }}>
          <Text style={styles.rankLevel}>
            Livello {levelOf(current.id)}/{maxLevel}
          </Text>
          <Text style={[styles.rankName, { color: current.color }]}>{current.name}</Text>
          <Text style={styles.rankPts}>
            {points} pt{next ? ` • ${next.min - points} al ${next.name}` : ' • max!'}
          </Text>
        </View>
        <Text style={styles.rankChevron}>›</Text>
      </TouchableOpacity>
      </FadeInView>

      <FadeInView delay={120} style={styles.statsRow}>
        <View style={styles.statBox}>
          <Text style={styles.statNumber}>{totalWorkouts}</Text>
          <Text style={styles.statLabel}>Allenamenti</Text>
        </View>
        <View style={styles.statBox}>
          <Text style={styles.statNumber}>{totalSets}</Text>
          <Text style={styles.statLabel}>Set totali</Text>
        </View>
        <TouchableOpacity
          style={styles.statBox}
          onPress={() => navigation.navigate('Timer', {})}
        >
          <MaterialCommunityIcons name="timer-outline" size={26} color={theme.colors.primary} />
          <Text style={styles.statLabel}>Timer</Text>
        </TouchableOpacity>
      </FadeInView>

      <FlatList
        data={workouts}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <Text style={styles.empty}>
            Nessun allenamento registrato.{'\n'}Tocca + per iniziare!
          </Text>
        }
      />

      <TouchableOpacity
        style={[styles.fab, glowActive && glowShadow(theme.glow, 16)]}
        onPress={() => {
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          navigation.navigate('NewWorkout');
        }}
      >
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    rankCard: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      margin: spacing.md,
      marginBottom: 0,
      borderWidth: 1,
      borderColor: c.border,
    },
    rankLevel: { color: c.textMuted, fontSize: 12, fontWeight: '700' },
    rankName: { color: c.text, fontSize: 17, fontWeight: '800', marginTop: 1 },
    rankPts: { color: c.textMuted, fontSize: 12, marginTop: 2 },
    rankChevron: { color: c.textMuted, fontSize: 28, fontWeight: '300' },
    statsRow: { flexDirection: 'row', padding: spacing.md, gap: spacing.md },
    statBox: {
      flex: 1,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    statNumber: { color: c.primary, fontSize: 28, fontWeight: '700' },
    statIcon: { fontSize: 26 },
    statLabel: { color: c.textMuted, fontSize: 13, marginTop: spacing.xs },
    list: { paddingHorizontal: spacing.md, paddingBottom: 90, gap: spacing.sm },
    card: {
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      borderWidth: 1,
      borderColor: c.border,
      marginBottom: spacing.sm,
    },
    cardDate: { color: c.text, fontSize: 16, fontWeight: '600' },
    cardExercises: { color: c.textMuted, marginTop: spacing.xs },
    empty: {
      color: c.textMuted,
      textAlign: 'center',
      marginTop: spacing.xl,
      lineHeight: 22,
    },
    fab: {
      position: 'absolute',
      right: spacing.lg,
      bottom: spacing.lg,
      width: 60,
      height: 60,
      borderRadius: 30,
      backgroundColor: c.primary,
      alignItems: 'center',
      justifyContent: 'center',
      elevation: 4,
    },
    fabText: { color: c.bg, fontSize: 32, fontWeight: '700', marginTop: -2 },
  });
