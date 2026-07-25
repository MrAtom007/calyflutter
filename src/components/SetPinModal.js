import { useMemo, useState } from 'react';
import { Modal, View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../ThemeContext';
import { setPin } from '../security';
import { spacing, radius } from '../theme';

const KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'del', '0', 'ok'];

export default function SetPinModal({ visible, onClose, onDone }) {
  const { theme } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [stage, setStage] = useState('first'); // first | confirm
  const [first, setFirst] = useState('');
  const [value, setValue] = useState('');
  const [error, setError] = useState('');

  const reset = () => {
    setStage('first');
    setFirst('');
    setValue('');
    setError('');
  };

  const close = () => {
    reset();
    onClose();
  };

  const confirm = async () => {
    if (value.length < 4) {
      setError('Il PIN deve avere almeno 4 cifre');
      return;
    }
    if (stage === 'first') {
      setFirst(value);
      setValue('');
      setStage('confirm');
      setError('');
    } else {
      if (value !== first) {
        setError('I PIN non coincidono, riprova');
        setValue('');
        setStage('first');
        setFirst('');
        return;
      }
      await setPin(value);
      reset();
      onDone();
    }
  };

  const onKey = (k) => {
    if (k === 'del') return setValue((v) => v.slice(0, -1));
    if (k === 'ok') return confirm();
    setValue((v) => (v.length < 6 ? v + k : v));
    setError('');
  };

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={close}>
      <View style={styles.backdrop}>
        <View style={styles.sheet}>
          <Text style={styles.title}>
            {stage === 'first' ? 'Imposta un PIN' : 'Conferma il PIN'}
          </Text>
          <Text style={styles.subtitle}>4-6 cifre</Text>

          <View style={styles.dots}>
            {[0, 1, 2, 3, 4, 5].map((i) => (
              <View
                key={i}
                style={[styles.dot, i < value.length && styles.dotFilled]}
              />
            ))}
          </View>

          {!!error && <Text style={styles.error}>{error}</Text>}

          <View style={styles.pad}>
            {KEYS.map((k) => (
              <TouchableOpacity key={k} style={styles.key} onPress={() => onKey(k)}>
                <Text
                  style={[
                    styles.keyText,
                    k === 'ok' && { color: theme.colors.primary, fontWeight: '800' },
                  ]}
                >
                  {k === 'del' ? '⌫' : k === 'ok' ? 'OK' : k}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity onPress={close}>
            <Text style={styles.cancel}>Annulla</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    backdrop: {
      flex: 1,
      backgroundColor: '#000000aa',
      alignItems: 'center',
      justifyContent: 'center',
    },
    sheet: {
      width: 320,
      backgroundColor: c.card,
      borderRadius: radius.lg,
      padding: spacing.lg,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: c.border,
    },
    title: { color: c.text, fontSize: 20, fontWeight: '800' },
    subtitle: { color: c.textMuted, marginTop: 2 },
    dots: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.lg },
    dot: {
      width: 12,
      height: 12,
      borderRadius: 6,
      borderWidth: 2,
      borderColor: c.border,
    },
    dotFilled: { backgroundColor: c.primary, borderColor: c.primary },
    error: { color: c.danger, marginTop: spacing.sm },
    pad: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      width: 240,
      justifyContent: 'center',
      marginTop: spacing.md,
    },
    key: {
      width: 68,
      height: 60,
      alignItems: 'center',
      justifyContent: 'center',
      margin: 4,
      backgroundColor: c.cardAlt,
      borderRadius: radius.md,
    },
    keyText: { color: c.text, fontSize: 22, fontWeight: '600' },
    cancel: { color: c.textMuted, marginTop: spacing.md, fontWeight: '600' },
  });
