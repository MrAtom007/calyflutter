import { useRef } from 'react';
import { Animated, Pressable } from 'react-native';

// Pulsante con leggero effetto di pressione (scale).
export default function PressableScale({ children, onPress, style, disabled, scaleTo = 0.94 }) {
  const scale = useRef(new Animated.Value(1)).current;

  const to = (v) =>
    Animated.spring(scale, { toValue: v, useNativeDriver: true, friction: 6 }).start();

  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      onPressIn={() => to(scaleTo)}
      onPressOut={() => to(1)}
    >
      <Animated.View style={[style, { transform: [{ scale }] }]}>{children}</Animated.View>
    </Pressable>
  );
}
