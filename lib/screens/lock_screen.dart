import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/security_provider.dart';
import '../state/locale_provider.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  bool _error = false;
  bool _bioQuick = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoAuth());
  }

  Future<void> _autoAuth() async {
    final mode = context.read<SecurityProvider>().mode;
    if (mode == LockMode.device) {
      final ok = await SecurityService.authenticateDevice();
      if (ok && mounted) context.read<SecurityProvider>().unlock();
    } else if (mode == LockMode.pin) {
      _bioQuick = await SecurityService.isBioQuickEnabled();
      if (mounted) setState(() {});
      if (_bioQuick) {
        final ok = await SecurityService.authenticateBiometric();
        if (ok && mounted) context.read<SecurityProvider>().unlock();
      }
    }
  }

  Future<void> _addDigit(String d) async {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length >= 4) {
      final ok = await SecurityService.verifyPin(_pin);
      if (ok) {
        HapticFeedback.heavyImpact();
        if (mounted) context.read<SecurityProvider>().unlock();
      } else if (_pin.length == 6) {
        HapticFeedback.vibrate();
        setState(() {
          _error = true;
          _pin = '';
        });
      }
    }
  }

  void _backspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final mode = context.watch<SecurityProvider>().mode;

    if (mode == LockMode.device) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: Spacing.md),
              Text(
                t('locked_title'),
                style: TextStyle(
                  color: c.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: c.primary),
                onPressed: () async {
                  final security = context.read<SecurityProvider>();
                  final ok = await SecurityService.authenticateDevice();
                  if (ok && mounted) {
                    security.unlock();
                  }
                },
                child: Text(t('unlock')),
              ),
            ],
          ),
        ),
      );
    }

    // PIN mode
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: Spacing.md),
            Text(t('enter_pin'), style: TextStyle(color: c.text, fontSize: 18)),
            if (_error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t('wrong_pin'), style: TextStyle(color: c.danger)),
              ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? c.primary : Colors.transparent,
                    border: Border.all(color: c.border),
                  ),
                );
              }),
            ),
            const SizedBox(height: Spacing.xl),
            _keypad(c),
            if (_bioQuick)
              TextButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: Text(t('unlock_biometric')),
                onPressed: () async {
                  final security = context.read<SecurityProvider>();
                  final ok = await SecurityService.authenticateBiometric();
                  if (ok && mounted) {
                    security.unlock();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _keypad(AppColors c) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '<'];
    return SizedBox(
      width: 260,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox();
          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => k == '<' ? _backspace() : _addDigit(k),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.card,
                border: Border.all(color: c.border),
              ),
              child: k == '<'
                  ? Icon(Icons.backspace_outlined, color: c.text)
                  : Text(
                      k,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
