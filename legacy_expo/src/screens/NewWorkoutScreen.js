import { useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
} from 'react-native';
import * as Haptics from 'expo-haptics';
import { getLibrary, getCategories, getExercise } from '../data/exercises';
import { saveWorkout } from '../storage';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import PressableScale from '../components/PressableScale';
import { spacing, radius } from '../theme';

export default function NewWorkoutScreen({ navigation, route }) {
  const { theme } = useTheme();
  const { discipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);

  const library = getLibrary(discipline);
  const categories = getCategories(discipline);

  const preset = route.params?.preset;
  const [sets, setSets] = useState(
    preset
      ? preset.map((p) => ({
          key: Date.now() + Math.random(),
          exerciseId: p.exerciseId,
          reps: p.reps ? String(p.reps) : '',
          sec: p.sec ? String(p.sec) : '',
          weight: p.weight ? String(p.weight) : '',
        }))
      : []
  );
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);

  const addSet = (exerciseId) => {
    setSets((prev) => [
      ...prev,
      { key: Date.now() + Math.random(), exerciseId, reps: '', sec: '', weight: '' },
    ]);
  };

  const updateSet = (key, field, value) => {
    setSets((prev) => prev.map((s) => (s.key === key ? { ...s, [field]: value } : s)));
  };

  const removeSet = (key) => setSets((prev) => prev.filter((s) => s.key !== key));

  const onSave = async () => {
    if (sets.length === 0) {
      Alert.alert('Aggiungi almeno un set prima di salvare.');
      return;
    }
    const workout = {
      id: `${Date.now()}`,
      date: new Date().toISOString(),
      discipline,
      sets: sets.map((s) => ({
        exerciseId: s.exerciseId,
        reps: s.reps ? parseInt(s.reps, 10) : null,
        sec: s.sec ? parseInt(s.sec, 10) : null,
        weight: s.weight ? parseFloat(s.weight) : null,
      })),
    };
    await saveWorkout(workout);
    navigation.navigate('Diario');
  };

  const filtered = library.filter((e) => e.category === selectedCategory);

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.section}>Categoria</Text>
        <View style={styles.chipsRow}>
          {categories.map((cat) => (
            <PressableScale
              key={cat}
              scaleTo={0.9}
              style={[styles.chip, selectedCategory === cat && styles.chipActive]}
              onPress={() => {
                Haptics.selectionAsync();
                setSelectedCategory(cat);
              }}
            >
              <Text
                style={[styles.chipText, selectedCategory === cat && styles.chipTextActive]}
              >
                {cat}
              </Text>
            </PressableScale>
          ))}
        </View>

        <Text style={styles.section}>Esercizi</Text>
        <View style={styles.exerciseGrid}>
          {filtered.map((ex) => (
            <PressableScale
              key={ex.id}
              scaleTo={0.92}
              style={styles.exerciseBtn}
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                addSet(ex.id);
              }}
            >
              <Text style={styles.exerciseName}>{ex.name}</Text>
              <Text style={styles.exerciseLevel}>{ex.level}</Text>
            </PressableScale>
          ))}
        </View>

        {sets.length > 0 && <Text style={styles.section}>Set aggiunti</Text>}
        {sets.map((s) => {
          const ex = getExercise(s.exerciseId);
          return (
            <View key={s.key} style={styles.setRow}>
              <Text style={styles.setName} numberOfLines={1}>
                {ex?.name}
              </Text>
              {ex?.unit === 'weight' ? (
                <>
                  <TextInput
                    style={styles.input}
                    placeholder="kg"
                    placeholderTextColor={theme.colors.textMuted}
                    keyboardType="decimal-pad"
                    value={s.weight}
                    onChangeText={(v) => updateSet(s.key, 'weight', v)}
                  />
                  <TextInput
                    style={styles.input}
                    placeholder="reps"
                    placeholderTextColor={theme.colors.textMuted}
                    keyboardType="number-pad"
                    value={s.reps}
                    onChangeText={(v) => updateSet(s.key, 'reps', v)}
                  />
                </>
              ) : ex?.unit === 'sec' ? (
                <TextInput
                  style={styles.input}
                  placeholder="sec"
                  placeholderTextColor={theme.colors.textMuted}
                  keyboardType="number-pad"
                  value={s.sec}
                  onChangeText={(v) => updateSet(s.key, 'sec', v)}
                />
              ) : (
                <TextInput
                  style={styles.input}
                  placeholder="reps"
                  placeholderTextColor={theme.colors.textMuted}
                  keyboardType="number-pad"
                  value={s.reps}
                  onChangeText={(v) => updateSet(s.key, 'reps', v)}
                />
              )}
              <TouchableOpacity onPress={() => removeSet(s.key)}>
                <Text style={styles.remove}>✕</Text>
              </TouchableOpacity>
            </View>
          );
        })}
      </ScrollView>

      <View style={styles.saveWrap}>
        <PressableScale style={styles.saveBtn} onPress={onSave}>
          <Text style={styles.saveText}>Salva allenamento</Text>
        </PressableScale>
      </View>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md, paddingBottom: 100 },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.md,
      marginBottom: spacing.sm,
    },
    chipsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
    chip: {
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderRadius: radius.lg,
      backgroundColor: c.card,
      borderWidth: 1,
      borderColor: c.border,
    },
    chipActive: { backgroundColor: c.primary, borderColor: c.primary },
    chipText: { color: c.textMuted },
    chipTextActive: { color: c.bg, fontWeight: '700' },
    exerciseGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
    exerciseBtn: {
      backgroundColor: c.cardAlt,
      borderRadius: radius.md,
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    exerciseName: { color: c.text, fontWeight: '600' },
    exerciseLevel: { color: c.textMuted, fontSize: 11 },
    setRow: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.sm,
      marginBottom: spacing.sm,
      gap: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    setName: { color: c.text, flex: 1 },
    input: {
      backgroundColor: c.bg,
      color: c.text,
      borderRadius: radius.sm,
      paddingHorizontal: spacing.sm,
      paddingVertical: spacing.sm,
      width: 64,
      textAlign: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    remove: { color: c.danger, fontSize: 18, paddingHorizontal: spacing.xs },
    saveWrap: {
      position: 'absolute',
      left: spacing.md,
      right: spacing.md,
      bottom: spacing.md,
    },
    saveBtn: {
      backgroundColor: c.primary,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
    },
    saveText: { color: c.bg, fontWeight: '700', fontSize: 16 },
  });
