import { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';

// Logo dell'app con effetto neon pulsante e motto.
export default function NeonLogo({ size = 34, showTagline = true }) {
  const { theme } = useTheme();
  const glow = theme.glow || theme.colors.primary;
  const pulse = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, {
          toValue: 1,
          duration: 1300,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(pulse, {
          toValue: 0,
          duration: 1300,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ])
    );
    loop.start();
    return () => loop.stop();
  }, []);

  const opacity = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.55, 1] });
  const scale = pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 1.04] });

  const glowStyle = {
    textShadowColor: glow,
    textShadowRadius: 16,
    textShadowOffset: { width: 0, height: 0 },
  };

  return (
    <View style={styles.wrap}>
      <Animated.View
        style={{ flexDirection: 'row', alignItems: 'center', opacity, transform: [{ scale }] }}
      >
        <MaterialCommunityIcons name="arm-flex" size={size} color={theme.colors.primary} />
        <Text style={[styles.name, { fontSize: size, color: theme.colors.text }, glowStyle]}>
          CALI
          <Text style={{ color: theme.colors.primary }}>STRACK</Text>
        </Text>
      </Animated.View>
      {showTagline && (
        <Text style={[styles.tagline, { color: glow }]}>
          L'UNICA STRADA PER LA CIMA È SPINGERE
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { alignItems: 'center' },
  name: { fontWeight: '900', letterSpacing: 2, marginLeft: 6 },
  tagline: {
    fontSize: 11,
    fontWeight: '800',
    letterSpacing: 2,
    marginTop: 6,
    textTransform: 'uppercase',
  },
});
