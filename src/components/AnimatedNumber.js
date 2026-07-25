import { useEffect, useRef, useState } from 'react';
import { Text, Animated, Easing } from 'react-native';

// Numero che conta fino al valore target con animazione.
export default function AnimatedNumber({ value = 0, style, duration = 900, format }) {
  const anim = useRef(new Animated.Value(0)).current;
  const [display, setDisplay] = useState(0);

  useEffect(() => {
    const id = anim.addListener(({ value: v }) => setDisplay(v));
    Animated.timing(anim, {
      toValue: value,
      duration,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start();
    return () => anim.removeListener(id);
  }, [value]);

  const rounded = Math.round(display);
  return <Text style={style}>{format ? format(rounded) : rounded}</Text>;
}
