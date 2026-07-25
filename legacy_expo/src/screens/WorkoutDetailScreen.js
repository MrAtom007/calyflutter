import { useCallback, useMemo, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { getWorkouts, deleteWorkout } from '../storage';
import { getExercise } from '../data/exercises';
import { useTheme } from '../ThemeContext';
import FadeInView from '../components/FadeInView';
import { spacing, radius } from '../theme';

export default function WorkoutDetailScreen({ route, navigation }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const { id } = route.params;
  const [workout, setWorkout] = useState(null);

  useFocusEffect(
    useCallback(() => {
      let active = true;
      getWorkouts().then((all) => {
        if (active) setWorkout(all.find((w) => w.id === id) || null);
      });
      return () => {
        active = false;
      };
    }, [id])
  );

  const onDelete = () => {
    Alert.alert('Elimina allenamento', 'Sei sicuro?', [
      { text: 'Annulla', style: 'cancel' },
      {
        text: 'Elimina',
        style: 'destructive',
        onPress: async () => {
          await deleteWorkout(id);
          navigation.goBack();
        },
      },
    ]);
  };

  if (!workout) {
    return (
      <View style={styles.container}>
        <Text style={styles.empty}>Allenamento non trovato.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.date}>
          {new Date(workout.date).toLocaleString('it-IT')}
        </Text>
        {workout.sets.map((s, i) => {
          const ex = getExercise(s.exerciseId);
          const value =
            ex?.unit === 'weight'
              ? `${s.weight ?? 0} kg × ${s.reps ?? 0}`
              : ex?.unit === 'sec'
              ? `${s.sec ?? 0} sec`
              : `${s.reps ?? 0} reps`;
          return (
            <FadeInView key={i} delay={i * 50} style={styles.setRow}>
              <Text style={styles.setName}>{ex?.name}</Text>
              <Text style={styles.setValue}>{value}</Text>
            </FadeInView>
          );
        })}
      </ScrollView>
      <TouchableOpacity style={styles.deleteBtn} onPress={onDelete}>
        <Text style={styles.deleteText}>Elimina allenamento</Text>
      </TouchableOpacity>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md },
    date: { color: c.textMuted, marginBottom: spacing.md },
    setRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    setName: { color: c.text, fontWeight: '600' },
    setValue: { color: c.primary, fontWeight: '700' },
    empty: { color: c.textMuted, textAlign: 'center', marginTop: spacing.xl },
    deleteBtn: {
      margin: spacing.md,
      padding: spacing.md,
      borderRadius: radius.md,
      borderWidth: 1,
      borderColor: c.danger,
      alignItems: 'center',
    },
    deleteText: { color: c.danger, fontWeight: '700' },
  });
