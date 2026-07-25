import { useEffect, useMemo, useRef, useState } from 'react';
import { View, Animated, Easing } from 'react-native';
import Svg, {
  Path,
  Circle,
  Line,
  Defs,
  LinearGradient,
  Stop,
  Text as SvgText,
} from 'react-native-svg';

const AnimatedPath = Animated.createAnimatedComponent(Path);

// Grafico a linea con area sfumata, punti, griglia e disegno animato.
export default function LineChart({
  data = [],
  color = '#4cd964',
  height = 170,
  showLabels = true,
  highlightMax = false,
  showEndValue = false,
  valueSuffix = '',
  refLine = null, // { value, label } linea orizzontale di riferimento (es. PR)
}) {
  const [w, setW] = useState(0);
  const draw = useRef(new Animated.Value(0)).current;

  const n = data.length;
  const padL = 10;
  const padR = 10;
  const padT = 16;
  const padB = showLabels ? 26 : 10;

  const values = data.map((d) => d.value);
  const max = Math.max(1, ...values);
  const min = Math.min(0, ...values);
  const maxIdx = values.indexOf(Math.max(...values));
  const lastIdx = n - 1;

  const geom = useMemo(() => {
    if (w <= 0 || n === 0) return null;
    const innerW = w - padL - padR;
    const innerH = height - padT - padB;
    const x = (i) => (n === 1 ? padL + innerW / 2 : padL + (i * innerW) / (n - 1));
    const y = (v) => padT + (1 - (v - min) / (max - min || 1)) * innerH;

    const pts = data.map((d, i) => ({ x: x(i), y: y(d.value) }));
    let line = '';
    let length = 0;
    pts.forEach((p, i) => {
      line += i === 0 ? `M ${p.x} ${p.y}` : ` L ${p.x} ${p.y}`;
      if (i > 0) {
        const dx = p.x - pts[i - 1].x;
        const dy = p.y - pts[i - 1].y;
        length += Math.sqrt(dx * dx + dy * dy);
      }
    });
    const baseline = height - padB;
    const area = `${line} L ${pts[pts.length - 1].x} ${baseline} L ${pts[0].x} ${baseline} Z`;
    const refY =
      refLine && typeof refLine.value === 'number' ? y(refLine.value) : null;
    return { pts, line, area, length: length || 1, baseline, refY };
  }, [w, n, height, max, min, refLine?.value]);

  useEffect(() => {
    if (!geom) return;
    draw.setValue(0);
    Animated.timing(draw, {
      toValue: 1,
      duration: 1000,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start();
  }, [geom?.line]);

  const dashOffset = geom
    ? draw.interpolate({ inputRange: [0, 1], outputRange: [geom.length, 0] })
    : 0;
  const areaOpacity = draw.interpolate({ inputRange: [0, 1], outputRange: [0, 0.25] });

  return (
    <View style={{ height }} onLayout={(e) => setW(e.nativeEvent.layout.width)}>
      {geom && (
        <Svg width={w} height={height}>
          <Defs>
            <LinearGradient id="area" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0%" stopColor={color} stopOpacity="0.5" />
              <Stop offset="100%" stopColor={color} stopOpacity="0" />
            </LinearGradient>
          </Defs>

          {/* linea di riferimento (record personale) */}
          {geom.refY != null && (
            <>
              <Line
                x1={padL}
                y1={geom.refY}
                x2={w - padR}
                y2={geom.refY}
                stroke={color}
                strokeOpacity={0.55}
                strokeWidth={1.5}
                strokeDasharray="5,4"
              />
              <SvgText
                x={w - padR}
                y={Math.max(10, geom.refY - 4)}
                fill={color}
                fillOpacity={0.9}
                fontSize="10"
                fontWeight="bold"
                textAnchor="end"
              >
                {refLine.label || `PR ${refLine.value}${valueSuffix}`}
              </SvgText>
            </>
          )}

          {/* baseline */}
          <Line
            x1={padL}
            y1={geom.baseline}
            x2={w - padR}
            y2={geom.baseline}
            stroke={color}
            strokeOpacity={0.15}
            strokeWidth={1}
          />

          {/* area */}
          <AnimatedPath d={geom.area} fill="url(#area)" fillOpacity={areaOpacity} />

          {/* linea animata */}
          <AnimatedPath
            d={geom.line}
            fill="none"
            stroke={color}
            strokeWidth={3}
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={geom.length}
            strokeDashoffset={dashOffset}
          />

          {/* punti */}
          {geom.pts.map((p, i) => (
            <Circle key={i} cx={p.x} cy={p.y} r={3.5} fill={color} />
          ))}

          {/* marcatore record (PR) */}
          {highlightMax && geom.pts[maxIdx] && (
            <>
              <Circle
                cx={geom.pts[maxIdx].x}
                cy={geom.pts[maxIdx].y}
                r={7}
                fill="none"
                stroke={color}
                strokeWidth={2}
              />
              <SvgText
                x={geom.pts[maxIdx].x}
                y={Math.max(12, geom.pts[maxIdx].y - 12)}
                fill={color}
                fontSize="11"
                fontWeight="bold"
                textAnchor="middle"
              >
                PR {max}
                {valueSuffix}
              </SvgText>
            </>
          )}

          {/* valore finale */}
          {showEndValue && geom.pts[lastIdx] && lastIdx !== maxIdx && (
            <SvgText
              x={geom.pts[lastIdx].x}
              y={Math.max(12, geom.pts[lastIdx].y - 10)}
              fill="#9aa0ad"
              fontSize="11"
              textAnchor="middle"
            >
              {values[lastIdx]}
              {valueSuffix}
            </SvgText>
          )}

          {/* etichette */}
          {showLabels &&
            data.map((d, i) =>
              d.label ? (
                <SvgText
                  key={`l${i}`}
                  x={geom.pts[i].x}
                  y={height - 8}
                  fill="#9aa0ad"
                  fontSize="10"
                  textAnchor="middle"
                >
                  {d.label}
                </SvgText>
              ) : null
            )}
        </Svg>
      )}
    </View>
  );
}
