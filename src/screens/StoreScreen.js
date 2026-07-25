import { useMemo } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import FadeInView from '../components/FadeInView';
import PressableScale from '../components/PressableScale';
import { useTheme } from '../ThemeContext';
import { themeList, spacing, radius, glowShadow } from '../theme';

// Prezzi mock: lo store è pronto per integrare pagamenti reali (Play Billing / RevenueCat).
const PRICES = {
  neonGreen: '2,99 €',
  neonCyan: '2,99 €',
  neonPink: '2,99 €',
  neonPurple: '2,99 €',
};

export default function StoreScreen() {
  const { theme, changeTheme, unlock, isUnlocked, themeId } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);

  const premium = themeList.filter((t) => t.premium);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.banner}>
        <MaterialCommunityIcons name="shopping" size={28} color={theme.colors.primary} />
        <View style={{ flex: 1 }}>
          <Text style={styles.bannerTitle}>Neon Store</Text>
          <Text style={styles.bannerText}>
            Sblocca skin neon esclusive con effetti glow.
          </Text>
        </View>
      </View>

      <Text style={styles.section}>Skin Neon</Text>
      {premium.map((t, idx) => {
        const owned = isUnlocked(t.id);
        const active = themeId === t.id;
        return (
          <FadeInView
            key={t.id}
            delay={idx * 80}
            style={[
              styles.card,
              { borderColor: t.glow },
              t.neon && glowShadow(t.glow, 10),
            ]}
          >
            <View style={styles.preview}>
              <View style={[styles.swatch, { backgroundColor: t.colors.bg }]} />
              <View style={[styles.swatch, { backgroundColor: t.colors.card }]} />
              <View
                style={[
                  styles.swatch,
                  { backgroundColor: t.colors.primary },
                  glowShadow(t.glow, 8),
                ]}
              />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={[styles.name, { color: t.glow }]}>{t.name}</Text>
              <Text style={styles.desc}>{t.description}</Text>
            </View>
            {owned ? (
              <PressableScale
                style={[styles.btn, active ? styles.btnActive : styles.btnOwned]}
                onPress={() => !active && changeTheme(t.id)}
                disabled={active}
              >
                <Text style={styles.btnText}>{active ? 'Attivo' : 'Applica'}</Text>
              </PressableScale>
            ) : (
              <PressableScale
                style={[styles.btn, { backgroundColor: t.glow }]}
                onPress={() => {
                  Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
                  unlock(t.id);
                  changeTheme(t.id);
                }}
              >
                <Text style={styles.btnText}>{PRICES[t.id] || 'Sblocca'}</Text>
              </PressableScale>
            )}
          </FadeInView>
        );
      })}

      <Text style={styles.note}>
        Nota: gli acquisti sono dimostrativi (sblocco immediato). L'infrastruttura è
        pronta per collegare i pagamenti reali di App Store e Google Play.
      </Text>
    </ScrollView>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: c.bg },
    content: { padding: spacing.md },
    banner: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      borderWidth: 1,
      borderColor: c.border,
    },
    bannerTitle: { color: c.text, fontSize: 18, fontWeight: '800' },
    bannerText: { color: c.textMuted, fontSize: 13, marginTop: 2 },
    section: {
      color: c.text,
      fontSize: 16,
      fontWeight: '700',
      marginTop: spacing.lg,
      marginBottom: spacing.sm,
    },
    card: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      backgroundColor: c.card,
      borderRadius: radius.md,
      padding: spacing.md,
      marginBottom: spacing.md,
      borderWidth: 1.5,
    },
    preview: { flexDirection: 'row', gap: 3 },
    swatch: {
      width: 16,
      height: 40,
      borderRadius: 4,
    },
    name: { fontSize: 16, fontWeight: '800' },
    desc: { color: c.textMuted, fontSize: 12, marginTop: 2 },
    btn: {
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
      borderRadius: radius.md,
      minWidth: 84,
      alignItems: 'center',
    },
    btnOwned: { backgroundColor: c.cardAlt },
    btnActive: { backgroundColor: c.border },
    btnText: { color: '#fff', fontWeight: '800' },
    note: { color: c.textMuted, fontSize: 12, lineHeight: 18, marginTop: spacing.sm },
  });
