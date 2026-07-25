import 'package:flutter/widgets.dart';

/// Numero che si anima con un count-up quando cambia il valore.
class AnimatedNumber extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String Function(num)? format;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.format,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final text = format != null ? format!(v) : v.round().toString();
        return Text(text, style: style);
      },
    );
  }
}
