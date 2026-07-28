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
    // cresta a ventaglio (galea da murmillo)
    p.moveTo(50, 6);
    p.quadraticBezierTo(66, 8, 70, 24);
    p.quadraticBezierTo(60, 18, 50, 18);
    p.quadraticBezierTo(40, 18, 30, 24);
    p.quadraticBezierTo(34, 8, 50, 6);
    p.close();
    // calotta elmo
    p.moveTo(34, 24);
    p.quadraticBezierTo(34, 20, 50, 20);
    p.quadraticBezierTo(66, 20, 66, 24);
    p.lineTo(66, 54);
    p.quadraticBezierTo(66, 70, 50, 78);
    p.quadraticBezierTo(34, 70, 34, 54);
    p.close();
    // apertura viso (foro)
    p.moveTo(40, 34);
    p.lineTo(60, 34);
    p.lineTo(60, 58);
    p.quadraticBezierTo(50, 66, 40, 58);
    p.close();
    // sbarre della griglia frontale (rientrano nel foro)
    p.addRect(const Rect.fromLTRB(43, 34, 45.5, 62));
    p.addRect(const Rect.fromLTRB(48.75, 34, 51.25, 64));
    p.addRect(const Rect.fromLTRB(54.5, 34, 57, 62));
    return p;
  }

  Path _kratos() {
    final p = Path();
    // manico
    p.addRect(const Rect.fromLTRB(47.5, 20, 52.5, 88));
    // pomello
    p.addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTRB(45, 84, 55, 90), const Radius.circular(2)));
    // lama destra (bordo concavo da ascia da guerra)
    p.moveTo(52.5, 30);
    p.lineTo(74, 26);
    p.quadraticBezierTo(66, 42, 74, 58);
    p.lineTo(52.5, 54);
    p.close();
    // lama sinistra
    p.moveTo(47.5, 30);
    p.lineTo(26, 26);
    p.quadraticBezierTo(34, 42, 26, 58);
    p.lineTo(47.5, 54);
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
    // disco (sol levante) sullo sfondo
    p.addOval(Rect.fromCircle(center: const Offset(50, 30), radius: 11));
    // katana A (dal basso-sinistra alla punta alto-destra)
    p.moveTo(24, 86);
    p.lineTo(74, 40);
    p.lineTo(78, 44);
    p.lineTo(28, 90);
    p.close();
    // guardia (tsuba) katana A
    p.addRect(const Rect.fromLTRB(26, 82, 36, 86));
    // katana B (speculare)
    p.moveTo(76, 86);
    p.lineTo(26, 40);
    p.lineTo(22, 44);
    p.lineTo(72, 90);
    p.close();
    // guardia katana B
    p.addRect(const Rect.fromLTRB(64, 82, 74, 86));
    return p;
  }

  Path _anubis() {
    // Testa di sciacallo (di fronte): orecchie appuntite + muso affusolato.
    final p = Path();
    // orecchio sinistro
    p.moveTo(32, 8);
    p.lineTo(45, 36);
    p.lineTo(33, 33);
    p.close();
    // orecchio destro
    p.moveTo(68, 8);
    p.lineTo(55, 36);
    p.lineTo(67, 33);
    p.close();
    // testa e muso
    p.moveTo(35, 30);
    p.quadraticBezierTo(35, 26, 50, 26);
    p.quadraticBezierTo(65, 26, 65, 30);
    p.lineTo(61, 52);
    p.quadraticBezierTo(58, 68, 50, 86);
    p.quadraticBezierTo(42, 68, 39, 52);
    p.close();
    return p;
  }
}
