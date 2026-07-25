import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Animated, Easing } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import ViewShot from 'react-native-view-shot';
import { getWorkouts } from '../storage';
import { ranks, totalPoints, rankFor, levelOf, maxLevel } from '../data/ranks';
import { useTheme } from '../ThemeContext';
import { useDiscipline } from '../DisciplineContext';
import DisciplineSwitch from '../components/DisciplineSwitch';
import Medal from '../components/Medal';
import ShareCard from '../components/ShareCard';
import FadeInView from '../components/FadeInView';
import AnimatedNumber from '../components/AnimatedNumber';
import PressableScale from '../components/PressableScale';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { shareProgressImage } from '../share';
import { spacing, radius } from '../theme';

export default function RanksScreen() {
  const { theme } = useTheme();
  const { discipline } = useDiscipline();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [points, setPoints] = useState(0);
  const [count, setCount] = useState(0);
  const shotRef = useRef(null);

  useFocusEffect(
    useCallback(() => {
      let active = true;
      getWorkouts(discipline).then((w) => {
        if (!active) return;
        setPoints(totalPoints(w));
        setCount(w.length);
      });
      return () => {
        active = false;
      };
    }, [discipline])
  );

  const { current, next, progress } = rankFor(points);
  const level = levelOf(current.id);

  const onShare = () => {
    const label = discipline === 'gym' ? 'Palestra' : 'Calisthenics';
    const text = `💪 CaliStrack (${label})\nRango ${current.name} ${current.icon} — Livello ${level}/${maxLevel}\n${points} punti • ${count} allenamenti${next ? `\nProssimo: ${next.name} ${next.icon}` : ' • rango MAX!'}`;
    shareProgressImage(shotRef, text);
  };

  return (
    <View style={styles.container}>
      <DisciplineSwitch />
      <ScrollView contentContainerStyle={styles.content}>
        <FadeInView style={[styles.hero, { borderColor: current.color }]}>
          <Medal rank={current} progress={progress} size={140} />
          <Text style={[styles.heroName, { color: current.color }]}>
            {current.name}
          </Text>
          <Text style={styles.heroLevel}>
            Livello {level} / {maxLevel}
          </Text>
          <View style={styles.heroPtsRow}>
            <AnimatedNumber value={points} style={styles.heroPtsNum} />
            <Text style={styles.heroPts}> punti • {count} allenamenti</Text>
          </View>
          <Text style={styles.heroNext}>
            {next
              ? `Ancora ${next.min - points} punti per il ${next.name}`
              : 'Hai raggiunto il rango massimo!'}
          </Text>

          <PressableScale style={styles.shareBtn} onPress={onShare}>
            <MaterialCommunityIcons name="share-variant" size={18} color={theme.colors.bg} />
            <Text style={styles.shareText}>Condividi i progressi</Text>
          </PressableScale>
        </FadeInView>

        <Text style={styles.section}>Scala dei ranghi</Text>
        {[...ranks].reverse().map((r, idx) => {
          const unlocked = points >= r.min;
          const isCurrent = r.id === current.id;
          return (
            <FadeInView
              key={r.id}
              delay={60 + idx * 45}
              style={[
                styles.rankRow,
                isCurrent && { borderColor: r.color, borderWidth: 2 },
                !unlocked && styles.locked,
              ]}
            >
              <Medal
                rank={r}
                progress={unlocked ? 1 : 0}
                size={54}
                showLevel={false}
                locked={!unlocked}
              />
              <View style={{ flex: 1 }}>
                <Text
                  style={[
                    styles.rankName,
                    { color: unlocked ? r.color : theme.colors.textMuted },
                  ]}
                >
                  Lv {levelOf(r.id)} · {r.name}
                </Text>
                <Text style={styles.rankReq}>{r.min} punti</Text>
              </View>
              {isCurrent && <Text style={styles.badge}>ATTUALE</Text>}
            </FadeInView>
          );
        })}

        <Text style={styles.info}>
          Guadagni punti a ogni allenamento. Nel calisthenics: 1 punto per ripetizione
          e 0,5 per secondo di hold. In palestra: volume (kg × reps) diviso 10.
        </Text>
      </ScrollView>

      {/* Card fuori schermo, catturata per la condivisione */}
      <View style={styles.offscreen} pointerEvents="none">
        <ViewShot ref={shotRef} options={{ format: 'png', quality: 1 }}>
          <ShareCard
            rank={current}
            progress={progress}
            points={points}
            next={next}
            discipline={discipline}
            workouts={count}
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
    hero: {
      backgroundColor: c.card,
      borderRadius: radius.lg,
      padding: spacing.lg,
      alignItems: 'center',
      borderWidth: 2,
    },
    heroName: { fontSize: 26, fontWeight: '800', marginTop: spacing.md },
    heroLevel: { color: c.text, fontSize: 15, fontWeight: '700', marginTop: 2 },
    heroPtsRow: { flexDirection: 'row', alignItems: 'baseline', marginTop: spacing.xs },
    heroPtsNum: { color: c.primary, fontWeight: '900', fontSize: 16 },
    heroPts: { color: c.textMuted },
    heroNext: { color: c.textMuted, marginTop: spacing.sm, textAlign: 'center' },
    shareBtn: {
      marginTop: spacing.md,
      backgroundColor: c.primary,
      borderRadius: radius.md,
      paddingVertical: spacing.sm,
      paddingHorizontal: spacing.lg,
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.sm,
    },
    shareText: { color: c.bg, fontWeight: '800' },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.lg,
      marginBottom: spacing.sm,
    },
    rankRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.sm,
      borderWidth: 1,
      borderColor: c.border,
    },
    locked: { opacity: 0.55 },
    rankName: { fontSize: 16, fontWeight: '700' },
    rankReq: { color: c.textMuted, fontSize: 12, marginTop: 2 },
    badge: {
      color: c.bg,
      backgroundColor: c.primary,
      fontSize: 10,
      fontWeight: '800',
      paddingHorizontal: spacing.sm,
      paddingVertical: 3,
      borderRadius: radius.sm,
      overflow: 'hidden',
    },
    info: { color: c.textMuted, fontSize: 12, marginTop: spacing.md, lineHeight: 18 },
    offscreen: { position: 'absolute', left: -1000, top: 0 },
  });
