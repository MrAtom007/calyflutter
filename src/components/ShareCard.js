import { View, Text, StyleSheet } from 'react-native';
import Medal from './Medal';
import { levelOf, maxLevel } from '../data/ranks';

// Card grafica pensata per essere catturata e condivisa come immagine.
// Ha uno stile proprio (indipendente dal tema) per risultare sempre leggibile.
export default function ShareCard({ rank, progress, points, next, discipline, workouts }) {
  const level = levelOf(rank.id);
  const disciplineLabel = discipline === 'gym' ? 'Palestra' : 'Calisthenics';

  return (
    <View style={[styles.card, { borderColor: rank.color }]}>
      <View style={styles.header}>
        <Text style={styles.brand}>CaliStrack</Text>
        <Text style={styles.discipline}>{disciplineLabel}</Text>
      </View>

      <Medal rank={rank} progress={progress} size={150} animate={false} />

      <Text style={[styles.rankName, { color: rank.color }]}>{rank.name}</Text>
      <Text style={styles.level}>
        Livello {level} / {maxLevel}
      </Text>

      <View style={styles.statsRow}>
        <View style={styles.stat}>
          <Text style={[styles.statNum, { color: rank.color }]}>{points}</Text>
          <Text style={styles.statLabel}>punti</Text>
        </View>
        <View style={styles.divider} />
        <View style={styles.stat}>
          <Text style={[styles.statNum, { color: rank.color }]}>{workouts}</Text>
          <Text style={styles.statLabel}>allenamenti</Text>
        </View>
      </View>

      <Text style={styles.footer}>
        {next
          ? `Prossimo rango: ${next.name} ${next.icon}`
          : 'Rango massimo raggiunto! ⚛️'}
      </Text>
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
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignSelf: 'stretch',
    marginBottom: 12,
  },
  brand: { color: '#fff', fontSize: 20, fontWeight: '900', letterSpacing: 0.5 },
  discipline: {
    color: '#0f1115',
    backgroundColor: '#4cd964',
    fontSize: 12,
    fontWeight: '800',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
    overflow: 'hidden',
  },
  rankName: { fontSize: 28, fontWeight: '900', marginTop: 12 },
  level: { color: '#9aa0ad', fontSize: 15, marginTop: 2, fontWeight: '600' },
  statsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 18,
    gap: 20,
  },
  stat: { alignItems: 'center' },
  statNum: { fontSize: 26, fontWeight: '900' },
  statLabel: { color: '#9aa0ad', fontSize: 12, marginTop: 2 },
  divider: { width: 1, height: 34, backgroundColor: '#2c313c' },
  footer: { color: '#c7ccd6', fontSize: 13, marginTop: 18, fontWeight: '600' },
});
