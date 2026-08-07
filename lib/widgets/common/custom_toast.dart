import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_provider.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';

/// Toast galleggiante a capsula con icona d'accento e feedback tattile.
class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    bool error = false,
  }) {
    final c = context.read<ThemeProvider>().colors;
    final accent = error ? c.danger : c.primary;
    FeedbackService.light();

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        padding: EdgeInsets.zero,
        content: _ToastBody(
          message: message,
          icon: icon,
          color: c,
          accent: accent,
        ),
      ),
    );
  }
}

class _ToastBody extends StatelessWidget {
  final String message;
  final IconData icon;
  final AppColors color;
  final Color accent;
  const _ToastBody({
    required this.message,
    required this.icon,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: color.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
