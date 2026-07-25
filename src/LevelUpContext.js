import { createContext, useContext, useEffect, useRef, useState } from 'react';
import { View, Text, StyleSheet, Animated, Easing, Pressable } from 'react-native';
import * as Haptics from 'expo-haptics';
import Medal from './components/Medal';
import { useTheme } from './ThemeContext';

const LevelUpContext = createContext(null);

export function LevelUpProvider({ children }) {
  const [payload, setPayload] = useState(null); // { rank, level }
  const anim = useRef(new Animated.Value(0)).current;
  const { theme } = useTheme();

  const celebrate = (rank, level) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setPayload({ rank, level });
  };

  useEffect(() => {
    if (!payload) return;
    anim.setValue(0);
    Animated.spring(anim, {
      toValue: 1,
      friction: 5,
      tension: 60,
      useNativeDriver: true,
    }).start();
  }, [payload]);

  const close = () => {
    Animated.timing(anim, {
      toValue: 0,
      duration: 200,
      easing: Easing.in(Easing.ease),
      useNativeDriver: true,
    }).start(() => setPayload(null));
  };

  return (
    <LevelUpContext.Provider value={{ celebrate }}>
      {children}
      {payload && (
        <Pressable style={styles.overlay} onPress={close}>
          <Animated.View
            style={{
              transform: [
                { scale: anim.interpolate({ inputRange: [0, 1], outputRange: [0.3, 1] }) },
              ],
              opacity: anim,
              alignItems: 'center',
            }}
          >
            <Text style={styles.spark}>✨</Text>
            <Text style={[styles.title, { color: payload.rank.color }]}>LEVEL UP!</Text>
            <Medal rank={payload.rank} progress={1} size={170} />
            <Text style={[styles.rank, { color: payload.rank.color }]}>
              {payload.rank.name}
            </Text>
            <Text style={styles.level}>Livello {payload.level}</Text>
            <View style={[styles.btn, { backgroundColor: payload.rank.color }]}>
              <Text style={styles.btnText}>Continua</Text>
            </View>
          </Animated.View>
        </Pressable>
      )}
    </LevelUpContext.Provider>
  );
}

export function useLevelUp() {
  const ctx = useContext(LevelUpContext);
  if (!ctx) throw new Error('useLevelUp richiede LevelUpProvider');
  return ctx;
}

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#000000e6',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000,
  },
  spark: { fontSize: 40 },
  title: { fontSize: 34, fontWeight: '900', letterSpacing: 2, marginBottom: 16 },
  rank: { fontSize: 26, fontWeight: '800', marginTop: 16 },
  level: { color: '#c7ccd6', fontSize: 16, marginTop: 4, fontWeight: '600' },
  btn: {
    marginTop: 24,
    paddingHorizontal: 32,
    paddingVertical: 12,
    borderRadius: 14,
  },
  btnText: { color: '#0f1115', fontWeight: '800', fontSize: 16 },
});
