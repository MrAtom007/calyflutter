import { useCallback, useMemo, useRef, useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import ViewShot from 'react-native-view-shot';
import * as Haptics from 'expo-haptics';
import { getWorkouts } from '../storage';
import { getExercise } from '../data/exercises';
import { totalPoints, rankFor } from '../data/ranks';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import DisciplineSwitch from '../components/DisciplineSwitch';
import ProgressShareCard from '../components/ProgressShareCard';
import FadeInView from '../components/FadeInView';
import AnimatedNumber from '../components/AnimatedNumber';
import LineChart from '../components/LineChart';
import RangeSelector from '../components/RangeSelector';
import PressableScale from '../components/PressableScale';
import { shareProgressImage } from '../share';
import { exportWorkouts } from '../export';
import { spacing, radius } from '../theme';

const RANGES = [
  { key: '4w', label: '4S', unit: 'week', count: 4 },
  { key: '8w', label: '8S', unit: 'week', count: 8 },
  { key: '12w', label: '12S', unit: 'week', count: 12 },
  { key: '6m', label: '6M', unit: 'month', count: 6 },
  { key: '12m', label: '12M', unit: 'month', count: 12 },
];

function lastNDays(n) {
  const days = [];
  for (let i = n - 1; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    days.push(d);
  }
  return days;
}

function sameDay(a, b) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

function startOfWeek(d) {
  const x = new Date(d);
  const day = (x.getDay() + 6) % 7; // 0 = lunedì
  x.setHours(0, 0, 0, 0);
  x.setDate(x.getDate() - day);
  return x;
}

// Valore di un set in base alla disciplina.
function setValue(s, isGym) {
  return isGym ? (s.weight || 0) * (s.reps || 0) : (s.reps || 0) + (s.sec || 0);
}

export default function ProgressScreen() {
  const { theme } = useTheme();
  const { discipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [workouts, setWorkouts] = useState([]);
  const [range, setRange] = useState('8w');
  const [compareA, setCompareA] = useState(null);
  const [compareB, setCompareB] = useState(null);
  const isGym = discipline === 'gym';
  const shotRef = useRef(null);

  useFocusEffect(
    useCallback(() => {
      let active = true;
      getWorkouts(discipline).then((w) => active && setWorkouts(w));
      return () => {
        active = false;
      };
    }, [discipline])
  );

  const days = lastNDays(7);
  const perDay = days.map((day) => ({
    label: day.toLocaleDateString('it-IT', { weekday: 'short' }),
    count: workouts.filter((w) => sameDay(new Date(w.date), day)).length,
  }));
  const maxDay = Math.max(1, ...perDay.map((d) => d.count));

  // Volume per esercizio.
  const volume = {};
  workouts.forEach((w) =>
    w.sets.forEach((s) => {
      const val = isGym ? (s.weight || 0) * (s.reps || 0) : s.reps || 0;
      if (val > 0) volume[s.exerciseId] = (volume[s.exerciseId] || 0) + val;
    })
  );
  const topExercises = Object.entries(volume)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 6);
  const maxVol = Math.max(1, ...topExercises.map(([, v]) => v));

  const totalVol = Object.values(volume).reduce((a, b) => a + b, 0);
  const totalSec = workouts.reduce(
    (acc, w) => acc + w.sets.reduce((a, s) => a + (s.sec || 0), 0),
    0
  );

  // Serie temporale (settimane o mesi) in base all'intervallo scelto.
  const cfg = RANGES.find((r) => r.key === range) || RANGES[1];
  const series = useMemo(() => {
    const buckets = [];
    if (cfg.unit === 'week') {
      const base = startOfWeek(new Date());
      for (let i = cfg.count - 1; i >= 0; i--) {
        const start = new Date(base);
        start.setDate(start.getDate() - i * 7);
        buckets.push({ start, key: start.getTime(), value: 0 });
      }
      workouts.forEach((w) => {
        const ws = startOfWeek(new Date(w.date)).getTime();
        const b = buckets.find((x) => x.key === ws);
        if (b) w.sets.forEach((s) => (b.value += setValue(s, isGym)));
      });
    } else {
      const now = new Date();
      for (let i = cfg.count - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        buckets.push({ start: d, key: `${d.getFullYear()}-${d.getMonth()}`, value: 0 });
      }
      workouts.forEach((w) => {
        const d = new Date(w.date);
        const k = `${d.getFullYear()}-${d.getMonth()}`;
        const b = buckets.find((x) => x.key === k);
        if (b) w.sets.forEach((s) => (b.value += setValue(s, isGym)));
      });
    }
    const step = buckets.length > 8 ? 3 : 2;
    return buckets.map((b, i) => ({
      value: Math.round(b.value),
      label:
        i % step === 0
          ? cfg.unit === 'week'
            ? `${b.start.getDate()}/${b.start.getMonth() + 1}`
            : b.start.toLocaleDateString('it-IT', { month: 'short' })
          : '',
    }));
  }, [workouts, isGym, range]);

  const hasSeriesData = series.some((d) => d.value > 0);
  const seriesPR = Math.max(0, ...series.map((d) => d.value));
  const trend = useMemo(() => {
    const vals = series.map((d) => d.value).filter((v) => v > 0);
    if (vals.length < 2) return null;
    const up = vals[vals.length - 1] >= vals[0];
    const pct = vals[0] ? Math.round(((vals[vals.length - 1] - vals[0]) / vals[0]) * 100) : 0;
    return { up, pct };
  }, [series]);

  const weekCount = perDay.reduce((a, d) => a + d.count, 0);
  const topName = topExercises[0] ? getExercise(topExercises[0][0])?.name : null;
  const rank = rankFor(totalPoints(workouts)).current;

  // ---- Confronto esercizi ----
  const exercisesWithData = useMemo(
    () =>
      Object.keys(volume)
        .map((id) => ({ id, name: getExercise(id)?.name || id, vol: volume[id] }))
        .sort((a, b) => b.vol - a.vol),
    [workouts]
  );

  const buildExerciseSeries = useCallback(
    (exerciseId) => {
      if (!exerciseId) return null;
      const entries = [];
      [...workouts]
        .sort((a, b) => new Date(a.date) - new Date(b.date))
        .forEach((w) =>
          w.sets.forEach((s) => {
            if (s.exerciseId === exerciseId) {
              const value = isGym
                ? (s.weight || 0) * (s.reps || 0)
                : s.sec || s.reps || 0;
              const d = new Date(w.date);
              entries.push({ value, label: `${d.getDate()}/${d.getMonth() + 1}` });
            }
          })
        );
      const trimmed = entries.slice(-10);
      const best = Math.max(0, ...trimmed.map((e) => e.value));
      const total = entries.reduce((a, e) => a + e.value, 0);
      return {
        points: trimmed.map((p, i) => ({ value: p.value, label: i % 2 === 0 ? p.label : '' })),
        best,
        total,
        sessions: entries.length,
      };
    },
    [workouts, isGym]
  );

  const seriesA = useMemo(() => buildExerciseSeries(compareA), [compareA, buildExerciseSeries]);
  const seriesB = useMemo(() => buildExerciseSeries(compareB), [compareB, buildExerciseSeries]);

  const pickCompare = (id) => {
    Haptics.selectionAsync();
    if (compareA === id) return setCompareA(null);
    if (compareB === id) return setCompareB(null);
    if (!compareA) return setCompareA(id);
    if (!compareB) return setCompareB(id);
    // Entrambi pieni: sostituisci il primo.
    setCompareA(id);
  };

  const onShare = () => {
    const label = isGym ? 'Palestra' : 'Calisthenics';
    const text = `📊 I miei progressi CaliStrack (${label})\n${workouts.length} allenamenti • ${weekCount} questa settimana\nVolume: ${Math.round(
      totalVol
    )} ${isGym ? 'kg' : 'reps'}${topName ? `\nTop: ${topName}` : ''}\nRango ${rank.name} ${rank.icon}`;
    shareProgressImage(shotRef, text);
  };

  return (
    <View style={styles.container}>
      <DisciplineSwitch />
      <ScrollView contentContainerStyle={styles.content}>
        <FadeInView style={styles.statsRow}>
          <View style={styles.statBox}>
            <AnimatedNumber value={isGym ? Math.round(totalVol) : totalVol} style={styles.statNumber} />
            <Text style={styles.statLabel}>{isGym ? 'Volume kg' : 'Reps totali'}</Text>
          </View>
          <View style={styles.statBox}>
            <AnimatedNumber
              value={isGym ? workouts.length : Math.round(totalSec / 60)}
              style={styles.statNumber}
              format={(n) => (isGym ? `${n}` : `${n}'`)}
            />
            <Text style={styles.statLabel}>{isGym ? 'Sessioni' : 'Hold statici'}</Text>
          </View>
        </FadeInView>

        <Text style={styles.section}>Allenamenti (ultimi 7 giorni)</Text>
        <View style={styles.chart}>
          {perDay.map((d, i) => (
            <FadeInView key={i} delay={i * 60} offset={0} style={styles.barCol}>
              <View style={styles.barTrack}>
                <View style={[styles.bar, { height: `${(d.count / maxDay) * 100}%` }]} />
              </View>
              <Text style={styles.barLabel}>{d.label}</Text>
              <Text style={styles.barValue}>{d.count}</Text>
            </FadeInView>
          ))}
        </View>

        <View style={styles.sectionRow}>
          <Text style={styles.section}>Andamento {isGym ? 'volume' : 'carico'}</Text>
          {trend && (
            <View style={[styles.trendBadge, { borderColor: trend.up ? '#2ecc71' : '#e74c3c' }]}>
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
        <View style={styles.rangeWrap}>
          <RangeSelector options={RANGES} value={range} onChange={setRange} />
        </View>
        {hasSeriesData ? (
          <FadeInView style={styles.chartCard}>
            <LineChart
              data={series}
              color={trend ? (trend.up ? '#2ecc71' : '#e74c3c') : theme.colors.primary}
              height={180}
              showEndValue
              refLine={seriesPR > 0 ? { value: seriesPR, label: `Record ${seriesPR}` } : null}
            />
          </FadeInView>
        ) : (
          <Text style={styles.empty}>Nessun dato in questo intervallo.</Text>
        )}

        <Text style={styles.section}>Top esercizi per volume {isGym ? '(kg)' : '(reps)'}</Text>
        {topExercises.length === 0 ? (
          <Text style={styles.empty}>Registra qualche allenamento per vedere i progressi.</Text>
        ) : (
          topExercises.map(([id, v]) => (
            <View key={id} style={styles.volRow}>
              <Text style={styles.volName} numberOfLines={1}>
                {getExercise(id)?.name || id}
              </Text>
              <View style={styles.volTrack}>
                <View style={[styles.volBar, { width: `${(v / maxVol) * 100}%` }]} />
              </View>
              <Text style={styles.volValue}>{Math.round(v)}</Text>
            </View>
          ))
        )}

        {/* ---- Confronto esercizi ---- */}
        {exercisesWithData.length >= 2 && (
          <>
            <Text style={styles.section}>Confronta due esercizi</Text>
            <Text style={styles.hint}>Tocca due esercizi per confrontarne l'andamento.</Text>
            <View style={styles.chipsRow}>
              {exercisesWithData.slice(0, 10).map((e) => {
                const selA = compareA === e.id;
                const selB = compareB === e.id;
                const sel = selA || selB;
                return (
                  <PressableScale
                    key={e.id}
                    style={[
                      styles.cmpChip,
                      sel && { borderColor: selA ? theme.colors.primary : '#f39c12' },
                    ]}
                    onPress={() => pickCompare(e.id)}
                  >
                    <Text style={[styles.cmpChipText, sel && { color: theme.colors.text }]} numberOfLines={1}>
                      {selA ? 'Ⓐ ' : selB ? 'Ⓑ ' : ''}
                      {e.name}
                    </Text>
                  </PressableScale>
                );
              })}
            </View>

            {(seriesA || seriesB) && (
              <FadeInView style={styles.chartCard}>
                <View style={styles.cmpHeader}>
                  <View style={styles.cmpLegend}>
                    <View style={[styles.dot, { backgroundColor: theme.colors.primary }]} />
                    <Text style={styles.cmpLegendText} numberOfLines={1}>
                      {compareA ? getExercise(compareA)?.name : '—'}
                    </Text>
                  </View>
                  <View style={styles.cmpLegend}>
                    <View style={[styles.dot, { backgroundColor: '#f39c12' }]} />
                    <Text style={styles.cmpLegendText} numberOfLines={1}>
                      {compareB ? getExercise(compareB)?.name : '—'}
                    </Text>
                  </View>
                </View>

                {seriesA && seriesA.points.length >= 2 && (
                  <LineChart data={seriesA.points} color={theme.colors.primary} height={130} showEndValue />
                )}
                {seriesB && seriesB.points.length >= 2 && (
                  <LineChart data={seriesB.points} color="#f39c12" height={130} showEndValue />
                )}

                <View style={styles.cmpTable}>
                  <View style={styles.cmpTableRow}>
                    <Text style={styles.cmpCell} />
                    <Text style={[styles.cmpCell, styles.cmpCellHead]}>Sessioni</Text>
                    <Text style={[styles.cmpCell, styles.cmpCellHead]}>Record</Text>
                    <Text style={[styles.cmpCell, styles.cmpCellHead]}>Totale</Text>
                  </View>
                  {[
                    { s: seriesA, c: theme.colors.primary, tag: 'Ⓐ' },
                    { s: seriesB, c: '#f39c12', tag: 'Ⓑ' },
                  ]
                    .filter((x) => x.s)
                    .map((x, i) => (
                      <View key={i} style={styles.cmpTableRow}>
                        <Text style={[styles.cmpCell, { color: x.c, fontWeight: '800' }]}>{x.tag}</Text>
                        <Text style={styles.cmpCell}>{x.s.sessions}</Text>
                        <Text style={styles.cmpCell}>{Math.round(x.s.best)}</Text>
                        <Text style={styles.cmpCell}>{Math.round(x.s.total)}</Text>
                      </View>
                    ))}
                </View>
              </FadeInView>
            )}
          </>
        )}

        <PressableScale style={styles.shareBtn} onPress={onShare}>
          <MaterialCommunityIcons name="share-variant" size={18} color={theme.colors.bg} />
          <Text style={styles.shareText}>Condividi i progressi</Text>
        </PressableScale>

        <View style={styles.exportRow}>
          <PressableScale style={styles.exportBtn} onPress={() => exportWorkouts('csv', discipline)}>
            <MaterialCommunityIcons name="file-delimited-outline" size={18} color={theme.colors.primary} />
            <Text style={styles.exportText}>Esporta CSV</Text>
          </PressableScale>
          <PressableScale style={styles.exportBtn} onPress={() => exportWorkouts('json', discipline)}>
            <MaterialCommunityIcons name="code-json" size={18} color={theme.colors.primary} />
            <Text style={styles.exportText}>Esporta JSON</Text>
          </PressableScale>
        </View>
      </ScrollView>

      <View style={styles.offscreen} pointerEvents="none">
        <ViewShot ref={shotRef} options={{ format: 'png', quality: 1 }}>
          <ProgressShareCard
            discipline={discipline}
            workouts={workouts.length}
            weekCount={weekCount}
            volume={totalVol}
            volumeLabel={isGym ? 'volume kg' : 'reps totali'}
            topName={topName}
            rank={rank}
          />
        </ViewShot>
      </View>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md },
    statsRow: { flexDirection: 'row', gap: spacing.md },
    statBox: {
      flex: 1,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    statNumber: { color: c.primary, fontSize: 26, fontWeight: '700' },
    statLabel: { color: c.textMuted, fontSize: 13, marginTop: spacing.xs },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.lg,
      marginBottom: spacing.sm,
    },
    hint: { color: c.textMuted, fontSize: 12, marginBottom: spacing.sm },
    chart: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-end',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      height: 180,
      borderWidth: 1,
      borderColor: c.border,
    },
    chartCard: {
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      borderWidth: 1,
      borderColor: c.border,
    },
    rangeWrap: { marginBottom: spacing.sm },
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
    barCol: { flex: 1, alignItems: 'center' },
    barTrack: { flex: 1, width: 18, justifyContent: 'flex-end' },
    bar: { width: '100%', backgroundColor: c.primary, borderRadius: radius.sm, minHeight: 4 },
    barLabel: { color: c.textMuted, fontSize: 11, marginTop: spacing.xs },
    barValue: { color: c.text, fontSize: 12, fontWeight: '600' },
    volRow: { flexDirection: 'row', alignItems: 'center', marginBottom: spacing.sm, gap: spacing.sm },
    volName: { color: c.text, width: 120, fontSize: 13 },
    volTrack: { flex: 1, height: 14, backgroundColor: c.cardAlt, borderRadius: radius.sm, overflow: 'hidden' },
    volBar: { height: '100%', backgroundColor: c.primary, borderRadius: radius.sm },
    volValue: { color: c.textMuted, width: 48, textAlign: 'right', fontSize: 12 },
    empty: { color: c.textMuted, marginTop: spacing.sm },
    chipsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
    cmpChip: {
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderRadius: radius.lg,
      backgroundColor: c.card,
      borderWidth: 1.5,
      borderColor: c.border,
      maxWidth: 180,
    },
    cmpChipText: { color: c.textMuted, fontSize: 13, fontWeight: '600' },
    cmpHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.sm },
    cmpLegend: { flexDirection: 'row', alignItems: 'center', gap: 6, flex: 1 },
    dot: { width: 10, height: 10, borderRadius: 5 },
    cmpLegendText: { color: c.text, fontSize: 12, fontWeight: '700', flexShrink: 1 },
    cmpTable: { marginTop: spacing.sm, borderTopWidth: 1, borderTopColor: c.border, paddingTop: spacing.sm },
    cmpTableRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 3 },
    cmpCell: { flex: 1, color: c.text, fontSize: 13, textAlign: 'center' },
    cmpCellHead: { color: c.textMuted, fontSize: 11, fontWeight: '700' },
    shareBtn: {
      marginTop: spacing.lg,
      backgroundColor: c.primary,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
      flexDirection: 'row',
      justifyContent: 'center',
      gap: spacing.sm,
    },
    shareText: { color: c.bg, fontWeight: '800' },
    exportRow: { flexDirection: 'row', gap: spacing.sm, marginTop: spacing.sm },
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
    exportText: { color: c.text, fontWeight: '700', fontSize: 13 },
    offscreen: { position: 'absolute', left: -1000, top: 0 },
  });
