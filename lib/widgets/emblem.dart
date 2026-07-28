import 'package:flutter/material.dart';

/// Stile di resa dell'emblema, scegliibile in-app.
enum EmblemStyle { classic, line, glow }

extension EmblemStyleLabel on EmblemStyle {
  String get id => name;
}

/// Soggetti disponibili (monocromatici, ricolorati dal tema).
const List<String> emblemSubjects = [
  'ulisse', 'zeus', 'cyberpunk', 'spartacus', 'kratos',
  'synthwave', 'valkyrie', 'ronin', 'anubis',
];

/// Mappa l'icona app (alias nativo) al soggetto dell'emblema.
String emblemForIcon(String appIconId) {
  switch (appIconId) {
    case 'IconZeus':
      return 'zeus';
    case 'IconCyberpunk':
      return 'cyberpunk';
    case 'IconSpartacus':
      return 'spartacus';
    case 'IconKratos':
      return 'kratos';
    case 'IconSynthwave':
      return 'synthwave';
    case 'IconValkyrie':
      return 'valkyrie';
    case 'IconRonin':
      return 'ronin';
    case 'IconAnubis':
      return 'anubis';
    case 'IconDefault':
    default:
      return 'ulisse';
  }
}

/// Mappa un id tema al soggetto dell'emblema (o null se il tema non ne ha uno).
String? emblemForTheme(String themeId) {
  switch (themeId) {
    case 'ulisse':
    case 'zeus':
    case 'cyberpunk':
    case 'spartacus':
    case 'kratos':
    case 'valkyrie':
    case 'ronin':
    case 'anubis':
      return themeId;
    case 'neonSynthwave':
      return 'synthwave';
    default:
      return null;
  }
}

/// Widget che disegna un emblema vettoriale ricolorabile.
class EmblemView extends StatelessWidget {
  const EmblemView({
    super.key,
    required this.subject,
    required this.size,
    required this.color,
    this.style = EmblemStyle.classic,
  });

  final String? subject;
  final double size;
  final Color color;
  final EmblemStyle style;

  @override
  Widget build(BuildContext context) {
    if (subject == null) return SizedBox(width: size, height: size);
    return CustomPaint(
      size: Size.square(size),
      painter: EmblemPainter(subject!, color, style),
    );
  }
}

/// Disegna il silhouette del soggetto in uno spazio 100x100 riscalato.
class EmblemPainter extends CustomPainter {
  EmblemPainter(this.subject, this.color, this.style);

  final String subject;
  final Color color;
  final EmblemStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _pathFor(subject);
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    switch (style) {
      case EmblemStyle.glow:
        final glow = Paint()
          ..color = color.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawPath(path, glow);
        canvas.drawPath(path, Paint()..color = color);
      case EmblemStyle.line:
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round,
        );
      case EmblemStyle.classic:
        canvas.drawPath(path, Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EmblemPainter old) =>
      old.subject != subject || old.color != color || old.style != style;

  // ---------------------------------------------------------------------------
  // Costruzione dei path (spazio 100x100, y verso il basso).
  // ---------------------------------------------------------------------------
  Path _pathFor(String subject) {
    switch (subject) {
      case 'zeus':
        return _zeus();
      case 'ulisse':
        return _ulisse();
      case 'cyberpunk':
        return _cyberpunk();
      case 'spartacus':
        return _spartacus();
      case 'kratos':
        return _kratos();
      case 'synthwave':
        return _synthwave();
      case 'valkyrie':
        return _valkyrie();
      case 'ronin':
        return _ronin();
      case 'anubis':
        return _anubis();
      default:
        return _zeus();
    }
  }

  Path _zeus() => Path()
    ..moveTo(58, 8)
    ..lineTo(30, 52)
    ..lineTo(48, 52)
    ..lineTo(38, 92)
    ..lineTo(74, 40)
    ..lineTo(54, 40)
    ..close();

  Path _ulisse() {
    final p = Path();
    // scafo
    p.moveTo(18, 62);
    p.quadraticBezierTo(50, 82, 82, 62);
    p.lineTo(76, 70);
    p.quadraticBezierTo(50, 84, 24, 70);
    p.close();
    // albero
    p.addRect(const Rect.fromLTRB(49, 22, 51, 60));
    // vela
    p.moveTo(51, 26);
    p.lineTo(74, 56);
    p.lineTo(51, 56);
    p.close();
    return p;
  }

  Path _cyberpunk() {
    final p = Path()..fillType = PathFillType.evenOdd;
    // corpo chip
    p.addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTRB(36, 36, 64, 64), const Radius.circular(4)));
    // foro interno
    p.addRect(const Rect.fromLTRB(46, 46, 54, 54));
    // pin
    for (final x in [40.0, 48.0, 56.0]) {
      p.addRect(Rect.fromLTRB(x - 1.5, 28, x + 1.5, 36)); // top
      p.addRect(Rect.fromLTRB(x - 1.5, 64, x + 1.5, 72)); // bottom
    }
    for (final y in [40.0, 48.0, 56.0]) {
      p.addRect(Rect.fromLTRB(28, y - 1.5, 36, y + 1.5)); // left
      p.addRect(Rect.fromLTRB(64, y - 1.5, 72, y + 1.5)); // right
    }
    return p;
  }

  Path _spartacus() {
    final p = Path()..fillType = PathFillType.evenOdd;
    // cresta
    p.moveTo(30, 20);
    p.quadraticBezierTo(50, 0, 70, 20);
    p.quadraticBezierTo(60, 15, 50, 15);
    p.quadraticBezierTo(40, 15, 30, 20);
    p.close();
    // elmo
    p.moveTo(34, 22);
    p.quadraticBezierTo(34, 18, 50, 18);
    p.quadraticBezierTo(66, 18, 66, 22);
    p.lineTo(66, 52);
    p.quadraticBezierTo(66, 66, 50, 72);
    p.quadraticBezierTo(34, 66, 34, 52);
    p.close();
    // nasale (foro)
    p.moveTo(47, 30);
    p.lineTo(53, 30);
    p.lineTo(53, 62);
    p.quadraticBezierTo(50, 65, 47, 62);
    p.close();
    return p;
  }

  Path _kratos() {
    final p = Path();
    // manico
    p.addRect(const Rect.fromLTRB(47, 24, 53, 86));
    // lama destra
    p.moveTo(53, 30);
    p.cubicTo(70, 30, 76, 42, 72, 54);
    p.lineTo(53, 50);
    p.close();
    // lama sinistra
    p.moveTo(47, 30);
    p.cubicTo(30, 30, 24, 42, 28, 54);
    p.lineTo(47, 50);
    p.close();
    return p;
  }

  Path _synthwave() {
    final p = Path()..fillType = PathFillType.evenOdd;
    p.addOval(Rect.fromCircle(center: const Offset(50, 48), radius: 20));
    // bande (fori)
    p.addRect(const Rect.fromLTRB(34, 50, 66, 53));
    p.addRect(const Rect.fromLTRB(38, 57, 62, 60));
    p.addRect(const Rect.fromLTRB(42, 63, 58, 65.5));
    return p;
  }

  Path _valkyrie() {
    final p = Path();
    // gemma centrale
    p.moveTo(50, 30);
    p.lineTo(57, 50);
    p.lineTo(50, 70);
    p.lineTo(43, 50);
    p.close();
    // ala sinistra
    p.moveTo(46, 44);
    p.lineTo(20, 38);
    p.lineTo(30, 46);
    p.lineTo(18, 48);
    p.lineTo(30, 54);
    p.lineTo(20, 58);
    p.lineTo(44, 58);
    p.close();
    // ala destra
    p.moveTo(54, 44);
    p.lineTo(80, 38);
    p.lineTo(70, 46);
    p.lineTo(82, 48);
    p.lineTo(70, 54);
    p.lineTo(80, 58);
    p.lineTo(56, 58);
    p.close();
    return p;
  }

  Path _ronin() {
    final p = Path();
    p.addOval(Rect.fromCircle(center: const Offset(50, 46), radius: 18));
    // katana
    p.moveTo(24, 80);
    p.lineTo(70, 30);
    p.lineTo(76, 36);
    p.lineTo(30, 86);
    p.close();
    return p;
  }

  Path _anubis() {
    final p = Path()..fillType = PathFillType.evenOdd;
    // anello superiore
    p.addOval(Rect.fromCircle(center: const Offset(50, 34), radius: 13));
    p.addOval(Rect.fromCircle(center: const Offset(50, 34), radius: 7));
    // barra verticale
    p.addRect(const Rect.fromLTRB(46, 44, 54, 82));
    // barra orizzontale
    p.addRect(const Rect.fromLTRB(37, 52, 63, 60));
    return p;
  }
}
