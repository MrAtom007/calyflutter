import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  final String? exerciseName;
  const TimerScreen({super.key, this.exerciseName});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const presets = [15, 30, 45, 60, 90];
  int _duration = 30;
  int _remaining = 30;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _select(int s) {
    FeedbackService.beep();
    FeedbackService.selection();
    _timer?.cancel();
    setState(() {
      _duration = s;
      _remaining = s;
      _running = false;
    });
  }

  void _toggle() {
    FeedbackService.medium();
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      if (_remaining == 0) _remaining = _duration;
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining <= 1) {
          t.cancel();
          setState(() {
            _remaining = 0;
            _running = false;
          });
          _onDone();
        } else {
          setState(() => _remaining--);
          if (_remaining <= 3) FeedbackService.beep();
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _duration;
      _running = false;
    });
  }

  void _onDone() {
    FeedbackService.onComplete();
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final progress = _duration == 0 ? 0.0 : _remaining / _duration;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseName != null
              ? 'Timer • ${widget.exerciseName}'
              : 'Timer',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: c.cardAlt,
                      valueColor: AlwaysStoppedAnimation(c.primary),
                    ),
                  ),
                  Text(
                    _fmt(_remaining),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Wrap(
              spacing: 8,
              children: presets.map((s) {
                final sel = s == _duration;
                return ChoiceChip(
                  label: Text('${s}s'),
                  selected: sel,
                  onSelected: (_) => _select(s),
                  selectedColor: c.primary,
                  backgroundColor: c.cardAlt,
                );
              }).toList(),
            ),
            const SizedBox(height: Spacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: _reset, child: Text(t('reset'))),
                const SizedBox(width: Spacing.md),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: c.primary),
                  onPressed: _toggle,
                  child: Text(
                    _running
                        ? t('pause')
                        : (_remaining == 0 ? t('restart') : t('start')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
