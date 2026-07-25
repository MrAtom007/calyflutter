import { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import Svg, {
  Circle,
  Defs,
  LinearGradient,
  RadialGradient,
  Stop,
  G,
} from 'react-native-svg';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { levelOf } from '../data/ranks';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

// Medaglia grafica: anello di progresso + disco col gradiente del materiale,
// numero di livello grande al centro e nome sotto (opzionale).
export default function Medal({
  rank,
  progress = 0,
  size = 120,
  showLevel = true,
  locked = false,
  animate = true,
}) {
  const level = levelOf(rank.id);
  const stroke = Math.max(6, size * 0.08);
  const r = (size - stroke) / 2;
  const cx = size / 2;
  const cy = size / 2;
  const circumference = 2 * Math.PI * r;
  const target = Math.min(1, Math.max(0, progress));

  const anim = useRef(new Animated.Value(animate ? 0 : target)).current;
  useEffect(() => {
    if (!animate) {
      anim.setValue(target);
      return;
    }
    Animated.timing(anim, {
      toValue: target,
      duration: 900,
      useNativeDriver: false,
    }).start();
  }, [target, animate]);

  const dashOffset = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [circumference, 0],
  });

  const c1 = locked ? '#4b4f57' : rank.color;
  const c2 = locked ? '#2c2f36' : rank.color2;
  const ring = locked ? '#3a3d44' : rank.glow;

  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={size} height={size}>
        <Defs>
          <RadialGradient id={`disc-${rank.id}`} cx="35%" cy="30%" r="80%">
            <Stop offset="0%" stopColor={c1} />
            <Stop offset="100%" stopColor={c2} />
          </RadialGradient>
          <LinearGradient id={`ring-${rank.id}`} x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0%" stopColor={ring} />
            <Stop offset="100%" stopColor={c1} />
          </LinearGradient>
        </Defs>

        {/* traccia anello */}
        <Circle cx={cx} cy={cy} r={r} stroke="#00000033" strokeWidth={stroke} fill="none" />
        {/* progresso */}
        <G rotation="-90" origin={`${cx}, ${cy}`}>
          <AnimatedCircle
            cx={cx}
            cy={cy}
            r={r}
            stroke={`url(#ring-${rank.id})`}
            strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={dashOffset}
            fill="none"
          />
        </G>
        {/* disco centrale */}
        <Circle cx={cx} cy={cy} r={r - stroke * 0.9} fill={`url(#disc-${rank.id})`} />
        <Circle
          cx={cx}
          cy={cy}
          r={r - stroke * 0.9}
          fill="none"
          stroke="#ffffff33"
          strokeWidth={1}
        />
      </Svg>

      {/* contenuto sovrapposto */}
      <View style={[StyleSheet.absoluteFill, styles.center]}>
        {locked ? (
          <MaterialCommunityIcons name="lock" size={size * 0.3} color="#ffffffcc" />
        ) : (
          <>
            <MaterialCommunityIcons
              name={rank.mci || 'medal'}
              size={size * 0.34}
              color="#ffffff"
              style={{
                textShadowColor: '#0009',
                textShadowRadius: 4,
              }}
            />
            {showLevel && (
              <Text
                style={{
                  color: '#fff',
                  fontWeight: '900',
                  fontSize: size * 0.16,
                  textShadowColor: '#0009',
                  textShadowRadius: 3,
                }}
              >
                LV {level}
              </Text>
            )}
          </>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  center: { alignItems: 'center', justifyContent: 'center' },
});
