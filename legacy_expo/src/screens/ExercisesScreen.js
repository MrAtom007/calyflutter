import { useMemo, useState } from 'react';
import { View, Text, StyleSheet, SectionList, TouchableOpacity, TextInput } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { getLibrary, getCategories } from '../data/exercises';
import { categoryIcon } from '../data/icons';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import DisciplineSwitch from '../components/DisciplineSwitch';
import { spacing, radius } from '../theme';

export default function ExercisesScreen({ navigation }) {
  const { theme } = useTheme();
  const { discipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [query, setQuery] = useState('');

  const library = getLibrary(discipline);
  const categories = getCategories(discipline);

  const sections = useMemo(() => {
    const q = query.trim().toLowerCase();
    return categories
      .map((cat) => ({
        title: cat,
        data: library.filter(
          (e) => e.category === cat && (!q || e.name.toLowerCase().includes(q))
        ),
      }))
      .filter((s) => s.data.length > 0);
  }, [library, categories, query]);

  const total = library.length;

  return (
    <View style={styles.container}>
      <DisciplineSwitch />
      <View style={styles.searchWrap}>
        <TextInput
          style={styles.search}
          placeholder={`Cerca tra ${total} esercizi...`}
          placeholderTextColor={theme.colors.textMuted}
          value={query}
          onChangeText={setQuery}
        />
      </View>
      <SectionList
        sections={sections}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.content}
        stickySectionHeadersEnabled={false}
        renderSectionHeader={({ section }) => (
          <View style={styles.headerRow}>
            <MaterialCommunityIcons
              name={categoryIcon(section.title)}
              size={20}
              color={theme.colors.primary}
            />
            <Text style={styles.header}>
              {section.title} <Text style={styles.count}>({section.data.length})</Text>
            </Text>
          </View>
        )}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.row}
            onPress={() => navigation.navigate('ExerciseDetail', { exerciseId: item.id })}
          >
            <Text style={styles.name}>{item.name}</Text>
            <View style={styles.metaRow}>
              <View style={styles.meta}>
                <Text style={styles.level}>{item.level}</Text>
                <Text style={styles.unit}>
                  {item.unit === 'weight' ? 'kg×reps' : item.unit}
                </Text>
              </View>
              {item.unit === 'sec' && (
                <TouchableOpacity
                  style={styles.timerBtn}
                  onPress={() => navigation.navigate('Timer', { name: item.name })}
                >
                  <Text style={styles.timerBtnText}>⏱️</Text>
                </TouchableOpacity>
              )}
              <Text style={styles.chevron}>›</Text>
            </View>
          </TouchableOpacity>
        )}
        ListEmptyComponent={
          <Text style={styles.empty}>Nessun esercizio trovato.</Text>
        }
      />
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    searchWrap: { padding: spacing.md, paddingBottom: 0 },
    search: {
      backgroundColor: c.card,
      color: c.text,
      borderRadius: radius.md,
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    content: { padding: spacing.md },
    headerRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.sm,
      marginTop: spacing.md,
      marginBottom: spacing.sm,
    },
    header: {
      color: c.primary,
      fontSize: 18,
      fontWeight: '700',
    },
    count: { color: c.textMuted, fontSize: 13, fontWeight: '400' },
    row: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    name: { color: c.text, fontWeight: '600', flex: 1 },
    metaRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
    meta: { alignItems: 'flex-end' },
    level: { color: c.textMuted, fontSize: 12 },
    unit: { color: c.textMuted, fontSize: 11 },
    timerBtn: {
      backgroundColor: c.cardAlt,
      borderRadius: radius.sm,
      paddingHorizontal: spacing.sm,
      paddingVertical: spacing.xs,
    },
    timerBtnText: { fontSize: 18 },
    chevron: { color: c.textMuted, fontSize: 22, fontWeight: '300' },
    empty: { color: c.textMuted, textAlign: 'center', marginTop: spacing.xl },
  });
