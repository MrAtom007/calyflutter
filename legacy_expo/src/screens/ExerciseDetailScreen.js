import { useCallback, useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { getWorkouts, saveWorkout } from '../storage';
import { getExercise } from '../data/exercises';
import { useTheme } from '../ThemeContext';
import ExerciseMedia from '../components/ExerciseMedia';
import FadeInView from '../components/FadeInView';
import LineChart from '../components/LineChart';
import { spacing, radius } from '../theme';

function fmtDate(iso) {
  return new Date(iso).toLocaleDateString('it-IT', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export default function ExerciseDetailScreen({ route, navigation }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const { exerciseId } = route.params;
  const ex = getExercise(exerciseId);

  const [history, setHistory] = useState([]);
  const [reps, setReps] = useState('');
  const [sec, setSec] = useState('');
  const [weight, setWeight] = useState('');

  const load = useCallback(() => {
    let active = true;
    getWorkouts().then((all) => {
      if (!active) return;
      const entries = [];
      all.forEach((w) => {
        w.sets.forEach((s) => {
          if (s.exerciseId === exerciseId) {
            entries.push({ date: w.date, ...s });
          }
        });
      });
      setHistory(entries);
    });
    return () => {
      active = false;
    };
  }, [exerciseId]);

  useFocusEffect(load);

  const isWeight = ex?.unit === 'weight';
  const isSec = ex?.unit === 'sec';

  // Record personale.
  const pr = useMemo(() => {
    if (history.length === 0) return null;
    if (isWeight) {
      const best = history.reduce(
        (m, e) => (Math.max(e.weight || 0) > (m.weight || 0) ? e : m),
        history[0]
      );
      return `${best.weight || 0} kg × ${best.reps || 0}`;
    }
    if (isSec) return `${Math.max(...history.map((e) => e.sec || 0))} sec`;
    return `${Math.max(...history.map((e) => e.reps || 0))} reps`;
  }, [history, isWeight, isSec]);

  const onLog = async () => {
    const entry = { exerciseId };
    if (isWeight) {
      if (!weight || !reps) return Alert.alert('Inserisci kg e ripetizioni.');
      entry.weight = parseFloat(weight);
      entry.reps = parseInt(reps, 10);
    } else if (isSec) {
      if (!sec) return Alert.alert('Inserisci i secondi.');
      entry.sec = parseInt(sec, 10);
    } else {
      if (!reps) return Alert.alert('Inserisci le ripetizioni.');
      entry.reps = parseInt(reps, 10);
    }
    await saveWorkout({
      id: `${Date.now()}`,
      date: new Date().toISOString(),
      discipline: ex.discipline,
      single: true,
      sets: [entry],
    });
    setReps('');
    setSec('');
    setWeight('');
    load();
  };

  // Serie cronologica (dal più vecchio al più recente) per il grafico.
  const series = useMemo(() => {
    const chrono = [...history].reverse();
    const pts = chrono.map((e) => {
      const value = isWeight ? e.weight || 0 : isSec ? e.sec || 0 : e.reps || 0;
      const d = new Date(e.date);
      return { value, label: `${d.getDate()}/${d.getMonth() + 1}` };
    });
    // Mostra al massimo ~10 punti, con etichette alternate.
    const trimmed = pts.slice(-10);
    return trimmed.map((p, i) => ({
      value: p.value,
      label: i % 2 === 0 ? p.label : '',
    }));
  }, [history, isWeight, isSec]);

  // Variazione tra primo e ultimo valore utile.
  const trend = useMemo(() => {
    const vals = series.map((s) => s.value).filter((v) => v > 0);
    if (vals.length < 2) return null;
    const first = vals[0];
    const last = vals[vals.length - 1];
    if (first === 0) return null;
    const pct = Math.round(((last - first) / first) * 100);
    return { pct, up: last >= first };
  }, [series]);

  const suffix = isWeight ? ' kg' : isSec ? ' s' : '';
  const seriesMax = useMemo(
    () => Math.max(0, ...series.map((s) => s.value)),
    [series]
  );

  const valueText = (e) => {
    if (isWeight) return `${e.weight || 0} kg × ${e.reps || 0}`;
    if (isSec) return `${e.sec || 0} sec`;
    return `${e.reps || 0} reps`;
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>{ex?.name}</Text>
        <Text style={styles.subtitle}>
          {ex?.category} · {ex?.level}
        </Text>

        <ExerciseMedia exercise={ex} />

        <FadeInView style={styles.statsRow}>
          <View style={styles.statBox}>
            <Text style={styles.statNum}>{history.length}</Text>
            <Text style={styles.statLabel}>volte</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statNum}>{pr || '—'}</Text>
            <Text style={styles.statLabel}>record personale</Text>
          </View>
        </FadeInView>

        {series.length >= 2 && (
          <>
            <View style={styles.sectionRow}>
              <Text style={styles.section}>
                Andamento {isWeight ? '(kg)' : isSec ? '(sec)' : '(reps)'}
              </Text>
              {trend && (
                <View
                  style={[
                    styles.trendBadge,
                    { backgroundColor: trend.up ? '#1f7a341a' : '#7a1f1f1a', borderColor: trend.up ? '#2ecc71' : '#e74c3c' },
                  ]}
                >
                  <MaterialCommunityIcons
                    name={trend.up ? 'trending-up' : 'trending-down'}
                    size={14}
                    color={trend.up ? '#2ecc71' : '#e74c3c'}
                  />
                  <Text style={[styles.trendText, { color: trend.up ? '#2ecc71' : '#e74c3c' }]}>
                    {trend.pct > 0 ? '+' : ''}
                    {trend.pct}%
                  </Text>
                </View>
              )}
            </View>
            <FadeInView style={styles.chartCard}>
              <LineChart
                data={series}
                color={theme.colors.primary}
                height={180}
                highlightMax
                showEndValue
                valueSuffix={suffix}
                refLine={
                  seriesMax > 0
                    ? { value: seriesMax, label: `PR ${seriesMax}${suffix}` }
                    : null
                }
              />
            </FadeInView>
          </>
        )}

        <Text style={styles.section}>Registra ora</Text>
        <View style={styles.logRow}>
          {isWeight && (
            <TextInput
              style={styles.input}
              placeholder="kg"
              placeholderTextColor={theme.colors.textMuted}
              keyboardType="decimal-pad"
              value={weight}
              onChangeText={setWeight}
            />
          )}
          {isSec ? (
            <TextInput
              style={styles.input}
              placeholder="sec"
              placeholderTextColor={theme.colors.textMuted}
              keyboardType="number-pad"
              value={sec}
              onChangeText={setSec}
            />
          ) : (
            <TextInput
              style={styles.input}
              placeholder="reps"
              placeholderTextColor={theme.colors.textMuted}
              keyboardType="number-pad"
              value={reps}
              onChangeText={setReps}
            />
          )}
          <TouchableOpacity style={styles.logBtn} onPress={onLog}>
            <Text style={styles.logBtnText}>Salva</Text>
          </TouchableOpacity>
        </View>

        {isSec && (
          <TouchableOpacity
            style={styles.timerLink}
            onPress={() => navigation.navigate('Timer', { name: ex.name })}
          >
            <Text style={styles.timerLinkText}>⏱️ Apri il timer per questo hold</Text>
          </TouchableOpacity>
        )}

        <Text style={styles.section}>Cronologia</Text>
        {history.length === 0 ? (
          <Text style={styles.empty}>Nessun dato ancora. Registra la prima serie!</Text>
        ) : (
          history.map((e, i) => (
            <View key={i} style={styles.histRow}>
              <Text style={styles.histDate}>{fmtDate(e.date)}</Text>
              <Text style={styles.histValue}>{valueText(e)}</Text>
            </View>
          ))
        )}
      </ScrollView>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md },
    title: { color: c.text, fontSize: 24, fontWeight: '800' },
    subtitle: { color: c.textMuted, marginTop: 2, marginBottom: spacing.md },
    statsRow: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.sm },
    statBox: {
      flex: 1,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    statNum: { color: c.primary, fontSize: 20, fontWeight: '800' },
    statLabel: { color: c.textMuted, fontSize: 12, marginTop: spacing.xs },
    chartCard: {
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      borderWidth: 1,
      borderColor: c.border,
    },
    sectionRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
    },
    trendBadge: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: 4,
      paddingHorizontal: spacing.sm,
      paddingVertical: 2,
      borderRadius: radius.sm,
      borderWidth: 1,
    },
    trendText: { fontWeight: '800', fontSize: 12 },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.lg,
      marginBottom: spacing.sm,
    },
    logRow: { flexDirection: 'row', gap: spacing.sm, alignItems: 'center' },
    input: {
      backgroundColor: c.card,
      color: c.text,
      borderRadius: radius.sm,
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      width: 90,
      textAlign: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    logBtn: {
      flex: 1,
      backgroundColor: c.primary,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
    },
    logBtnText: { color: c.bg, fontWeight: '800' },
    timerLink: { marginTop: spacing.md },
    timerLinkText: { color: c.primary, fontWeight: '700' },
    histRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    histDate: { color: c.textMuted },
    histValue: { color: c.text, fontWeight: '700' },
    empty: { color: c.textMuted },
  });
