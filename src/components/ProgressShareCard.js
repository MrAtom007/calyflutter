import { View, Text, StyleSheet } from 'react-native';

// Card riassuntiva dei progressi, pensata per la condivisione come immagine.
export default function ProgressShareCard({
  discipline,
  workouts,
  weekCount,
  volume,
  volumeLabel,
  topName,
  rank,
}) {
  const disciplineLabel = discipline === 'gym' ? 'Palestra' : 'Calisthenics';
  const accent = rank?.color || '#4cd964';
  return (
    <View style={[styles.card, { borderColor: accent }]}>
      <View style={styles.header}>
        <Text style={styles.brand}>CaliStrack</Text>
        <Text style={[styles.badge, { backgroundColor: accent }]}>{disciplineLabel}</Text>
      </View>

      <Text style={styles.title}>I miei progressi</Text>

      <View style={styles.row}>
        <View style={styles.stat}>
          <Text style={[styles.num, { color: accent }]}>{workouts}</Text>
          <Text style={styles.label}>allenamenti</Text>
        </View>
        <View style={styles.stat}>
          <Text style={[styles.num, { color: accent }]}>{weekCount}</Text>
          <Text style={styles.label}>questa settimana</Text>
        </View>
      </View>

      <View style={styles.row}>
        <View style={styles.stat}>
          <Text style={[styles.num, { color: accent }]}>{Math.round(volume)}</Text>
          <Text style={styles.label}>{volumeLabel}</Text>
        </View>
        <View style={styles.stat}>
          <Text style={styles.topName} numberOfLines={1}>
            {topName || '—'}
          </Text>
          <Text style={styles.label}>esercizio top</Text>
        </View>
      </View>

      {rank && (
        <Text style={styles.rank}>
          {rank.icon} {rank.name}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    width: 320,
    backgroundColor: '#0f1115',
    borderRadius: 24,
    borderWidth: 2,
    padding: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  brand: { color: '#fff', fontSize: 20, fontWeight: '900' },
  badge: {
    color: '#0f1115',
    fontSize: 12,
    fontWeight: '800',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
    overflow: 'hidden',
  },
  title: { color: '#fff', fontSize: 24, fontWeight: '900', marginTop: 16 },
  row: { flexDirection: 'row', marginTop: 18 },
  stat: { flex: 1 },
  num: { fontSize: 30, fontWeight: '900' },
  topName: { color: '#fff', fontSize: 18, fontWeight: '800' },
  label: { color: '#9aa0ad', fontSize: 12, marginTop: 2 },
  rank: { color: '#c7ccd6', fontSize: 15, fontWeight: '700', marginTop: 20 },
});
