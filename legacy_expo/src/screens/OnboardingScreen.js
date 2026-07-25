import { useMemo, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  useWindowDimensions,
} from 'react-native';
import { useTheme } from '../ThemeContext';
import NeonLogo from '../components/NeonLogo';
import { spacing, radius } from '../theme';

const slides = [
  {
    logo: true,
    title: 'Benvenuto in CaliStrack',
    text: 'La tua app per allenarti a corpo libero e in palestra, tutto in un unico posto.',
  },
  {
    icon: '🤸🏋️',
    title: 'Due discipline',
    text: 'Usa lo switch in alto per passare tra Calisthenics e Palestra. Ogni sezione ha esercizi, routine e progressi separati.',
  },
  {
    icon: '➕',
    title: 'Registra gli allenamenti',
    text: 'Tocca il pulsante + nella Home, scegli gli esercizi e inserisci ripetizioni, secondi di hold o kg × reps.',
  },
  {
    icon: '📋',
    title: 'Routine e Timer',
    text: 'Avvia routine predefinite con un tocco e usa il timer integrato per gli esercizi statici come plank e L-sit.',
  },
  {
    icon: '📈',
    title: 'Progressi',
    text: 'Nella sezione Progressi vedi i grafici degli allenamenti settimanali e il volume dei tuoi esercizi migliori.',
  },
  {
    icon: '🏅',
    title: 'Medaglie e ranghi',
    text: 'Ogni allenamento vale punti: scala i ranghi dal Legno fino all\u2019Antimateria, il materiale piu\u2019 prezioso dell\u2019universo!',
  },
  {
    icon: '🎨',
    title: 'Personalizza',
    text: 'Nelle Impostazioni scegli il tema colore piu\u2019 adatto a te tra tanti stili suggeriti. Iniziamo!',
  },
];

export default function OnboardingScreen({ onDone }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const { width } = useWindowDimensions();
  const listRef = useRef(null);
  const [index, setIndex] = useState(0);

  const goNext = () => {
    if (index < slides.length - 1) {
      const next = index + 1;
      listRef.current?.scrollToIndex({ index: next });
      setIndex(next);
    } else {
      onDone();
    }
  };

  const onScroll = (e) => {
    const i = Math.round(e.nativeEvent.contentOffset.x / width);
    if (i !== index) setIndex(i);
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.skip} onPress={onDone}>
        <Text style={styles.skipText}>Salta</Text>
      </TouchableOpacity>

      <FlatList
        ref={listRef}
        data={slides}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={onScroll}
        keyExtractor={(_, i) => `${i}`}
        renderItem={({ item }) => (
          <View style={[styles.slide, { width }]}>
            {item.logo ? (
              <View style={{ marginBottom: spacing.lg }}>
                <NeonLogo size={40} />
              </View>
            ) : (
              <Text style={styles.icon}>{item.icon}</Text>
            )}
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.text}>{item.text}</Text>
          </View>
        )}
      />

      <View style={styles.dots}>
        {slides.map((_, i) => (
          <View key={i} style={[styles.dot, i === index && styles.dotActive]} />
        ))}
      </View>

      <TouchableOpacity style={styles.btn} onPress={goNext}>
        <Text style={styles.btnText}>
          {index === slides.length - 1 ? 'Inizia' : 'Avanti'}
        </Text>
      </TouchableOpacity>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg, paddingBottom: spacing.xl },
    skip: {
      alignSelf: 'flex-end',
      padding: spacing.lg,
    },
    skipText: { color: c.textMuted, fontWeight: '600' },
    slide: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      padding: spacing.xl,
    },
    icon: { fontSize: 80, marginBottom: spacing.lg },
    title: {
      color: c.text,
      fontSize: 24,
      fontWeight: '800',
      textAlign: 'center',
      marginBottom: spacing.md,
    },
    text: {
      color: c.textMuted,
      fontSize: 16,
      textAlign: 'center',
      lineHeight: 24,
    },
    dots: {
      flexDirection: 'row',
      justifyContent: 'center',
      gap: spacing.sm,
      marginBottom: spacing.lg,
    },
    dot: {
      width: 8,
      height: 8,
      borderRadius: 4,
      backgroundColor: c.border,
    },
    dotActive: { backgroundColor: c.primary, width: 22 },
    btn: {
      backgroundColor: c.primary,
      marginHorizontal: spacing.lg,
      borderRadius: radius.md,
      padding: spacing.md,
      alignItems: 'center',
    },
    btnText: { color: c.bg, fontWeight: '700', fontSize: 16 },
  });
