import { useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  Pressable,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { spacing, radius } from '../theme';

// Menu a tendina in alto a destra con accesso a Store, Libreria, Timer, ecc.
export default function HeaderMenu({ navigation }) {
  const { theme } = useTheme();
  const [open, setOpen] = useState(false);
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);

  const items = [
    { icon: 'shopping', label: 'Neon Store', go: () => navigation.navigate('Store') },
    { icon: 'dumbbell', label: 'Libreria esercizi', go: () => navigation.navigate('EserciziStack') },
    { icon: 'timer-outline', label: 'Timer', go: () => navigation.navigate('Timer', {}) },
  ];

  return (
    <>
      <TouchableOpacity onPress={() => setOpen(true)} style={{ paddingHorizontal: 6 }}>
        <MaterialCommunityIcons name="dots-vertical" size={24} color={theme.colors.text} />
      </TouchableOpacity>

      <Modal visible={open} transparent animationType="fade" onRequestClose={() => setOpen(false)}>
        <Pressable style={styles.backdrop} onPress={() => setOpen(false)}>
          <View style={styles.menu}>
            {items.map((it) => (
              <TouchableOpacity
                key={it.label}
                style={styles.item}
                onPress={() => {
                  setOpen(false);
                  it.go();
                }}
              >
                <MaterialCommunityIcons name={it.icon} size={20} color={theme.colors.primary} />
                <Text style={styles.itemText}>{it.label}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </Pressable>
      </Modal>
    </>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    backdrop: { flex: 1, backgroundColor: '#00000055' },
    menu: {
      position: 'absolute',
      top: 8,
      right: 8,
      backgroundColor: c.card,
      borderRadius: radius.md,
      paddingVertical: spacing.xs,
      minWidth: 210,
      borderWidth: 1,
      borderColor: c.border,
      elevation: 8,
    },
    item: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.md,
    },
    itemText: { color: c.text, fontSize: 15, fontWeight: '600' },
  });
