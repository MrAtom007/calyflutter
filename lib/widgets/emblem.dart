import 'package:flutter/material.dart';

/// Stile di resa dell'emblema, scegliibile in-app.
enum EmblemStyle { classic, line, glow }

extension EmblemStyleLabel on EmblemStyle {
  String get id => name;
}

/// Soggetti disponibili (bicromatici, ricolorati dal tema).
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

/// Foto realistica opzionale per un soggetto (mostrata al posto dell'emblema
/// vettoriale nelle miniature, quando disponibile).
String? subjectPhotoAsset(String? subject) {
  switch (subject) {
    case 'kratos':
      return 'assets/icon_previews/kratos_hero.jpg';
    default:
      return null;
  }
}

/// Mappa un soggetto all'alias dell'icona app nativa corrispondente.
String iconAliasForSubject(String? subject) {
  switch (subject) {
    case 'zeus':
      return 'IconZeus';
    case 'cyberpunk':
      return 'IconCyberpunk';
    case 'spartacus':
      return 'IconSpartacus';
    case 'kratos':
      return 'IconKratos';
    case 'synthwave':
      return 'IconSynthwave';
    case 'valkyrie':
      return 'IconValkyrie';
    case 'ronin':
      return 'IconRonin';
    case 'anubis':
      return 'IconAnubis';
    case 'ulisse':
    default:
      return 'IconDefault';
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

/// Silhouette principale + dettaglio caratterizzante di un soggetto.
class _EmblemArt {
  final Path main;
  final Path? accent;
  final bool accentBehind;
  const _EmblemArt(this.main, {this.accent, this.accentBehind = false});
}

/// Disegna il soggetto (bicromatico) in uno spazio 100x100 riscalato.
class EmblemPainter extends CustomPainter {
  EmblemPainter(this.subject, this.color, this.style);

  final String subject;
  final Color color;
  final EmblemStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final art = _artFor(subject);
    // Il dettaglio usa una tinta piu chiara derivata dal colore del tema,
    // cosi l'emblema resta adattivo ma acquista profondita e carattere.
    final accentColor = Color.lerp(color, Colors.white, 0.5)!;

    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    if (art.accentBehind && art.accent != null) {
      _draw(canvas, art.accent!, accentColor, detail: true);
      _draw(canvas, art.main, color);
    } else {
      _draw(canvas, art.main, color);
      if (art.accent != null) {
        _draw(canvas, art.accent!, accentColor, detail: true);
      }
    }
    canvas.restore();
  }

  void _draw(Canvas canvas, Path path, Color col, {bool detail = false}) {
    switch (style) {
      case EmblemStyle.glow:
        if (!detail) {
          canvas.drawPath(
            path,
            Paint()
              ..color = col.withValues(alpha: 0.9)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          );
        }
        canvas.drawPath(path, Paint()..color = col);
      case EmblemStyle.line:
        // I dettagli piccoli restano leggibili come pieni; le silhouette
        // principali come contorno.
        if (detail) {
          canvas.drawPath(path, Paint()..color = col);
        } else {
          canvas.drawPath(
            path,
            Paint()
              ..color = col
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..strokeJoin = StrokeJoin.round
              ..strokeCap = StrokeCap.round,
          );
        }
      case EmblemStyle.classic:
        canvas.drawPath(path, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(covariant EmblemPainter old) =>
      old.subject != subject || old.color != color || old.style != style;

  // ---------------------------------------------------------------------------
  // Costruzione dell'arte (spazio 100x100, y verso il basso).
  // ---------------------------------------------------------------------------
  _EmblemArt _artFor(String subject) {
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

  _EmblemArt _zeus() {
    final main = Path()
      ..moveTo(58, 8)
      ..lineTo(30, 52)
      ..lineTo(48, 52)
      ..lineTo(38, 92)
      ..lineTo(74, 40)
      ..lineTo(54, 40)
      ..close();
    // Nucleo incandescente interno.
    final accent = Path()
      ..moveTo(56, 20)
      ..lineTo(41, 50)
      ..lineTo(49, 50)
      ..lineTo(44, 74)
      ..lineTo(64, 44)
      ..lineTo(53, 44)
      ..close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _ulisse() {
    final main = Path();
    // scafo
    main.moveTo(18, 62);
    main.quadraticBezierTo(50, 82, 82, 62);
    main.lineTo(76, 70);
    main.quadraticBezierTo(50, 84, 24, 70);
    main.close();
    // albero
    main.addRect(const Rect.fromLTRB(49, 22, 51, 60));
    // vela
    main.moveTo(51, 26);
    main.lineTo(74, 56);
    main.lineTo(51, 56);
    main.close();
    // Dettaglio: occhio dipinto sulla prua + banda della vela.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(28, 64), radius: 2.6));
    accent.addRect(const Rect.fromLTRB(55, 41, 70, 44));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _cyberpunk() {
    final main = Path()..fillType = PathFillType.evenOdd;
    main.addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTRB(36, 36, 64, 64), const Radius.circular(4)));
    for (final x in [40.0, 48.0, 56.0]) {
      main.addRect(Rect.fromLTRB(x - 1.5, 28, x + 1.5, 36)); // top
      main.addRect(Rect.fromLTRB(x - 1.5, 64, x + 1.5, 72)); // bottom
    }
    for (final y in [40.0, 48.0, 56.0]) {
      main.addRect(Rect.fromLTRB(28, y - 1.5, 36, y + 1.5)); // left
      main.addRect(Rect.fromLTRB(64, y - 1.5, 72, y + 1.5)); // right
    }
    // Dettaglio: core luminoso (cornice + nodo centrale).
    final accent = Path()..fillType = PathFillType.evenOdd;
    accent.addRect(const Rect.fromLTRB(44, 44, 56, 56));
    accent.addRect(const Rect.fromLTRB(48, 48, 52, 52));
    accent.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 1.6));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _spartacus() {
    final main = Path()..fillType = PathFillType.evenOdd;
    // calotta elmo
    main.moveTo(34, 24);
    main.quadraticBezierTo(34, 20, 50, 20);
    main.quadraticBezierTo(66, 20, 66, 24);
    main.lineTo(66, 54);
    main.quadraticBezierTo(66, 70, 50, 78);
    main.quadraticBezierTo(34, 70, 34, 54);
    main.close();
    // apertura viso (foro)
    main.moveTo(40, 34);
    main.lineTo(60, 34);
    main.lineTo(60, 58);
    main.quadraticBezierTo(50, 66, 40, 58);
    main.close();
    // sbarre della griglia frontale
    main.addRect(const Rect.fromLTRB(43, 34, 45.5, 62));
    main.addRect(const Rect.fromLTRB(48.75, 34, 51.25, 64));
    main.addRect(const Rect.fromLTRB(54.5, 34, 57, 62));
    // Dettaglio: cresta a ventaglio (galea da murmillo).
    final accent = Path();
    accent.moveTo(50, 6);
    accent.quadraticBezierTo(66, 8, 70, 24);
    accent.quadraticBezierTo(60, 18, 50, 18);
    accent.quadraticBezierTo(40, 18, 30, 24);
    accent.quadraticBezierTo(34, 8, 50, 6);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _kratos() {
    // Lame del Caos: due lame ricurve incrociate + catene (dettaglio).
    final main = Path();
    // lama destra
    main.moveTo(50, 64);
    main.cubicTo(60, 58, 74, 42, 86, 18);
    main.cubicTo(84, 30, 80, 41, 72, 51);
    main.cubicTo(64, 59, 56, 62, 50, 66);
    main.close();
    // lama sinistra (speculare)
    main.moveTo(50, 64);
    main.cubicTo(40, 58, 26, 42, 14, 18);
    main.cubicTo(16, 30, 20, 41, 28, 51);
    main.cubicTo(36, 59, 44, 62, 50, 66);
    main.close();
    // mozzo centrale
    main.addOval(Rect.fromCircle(center: const Offset(50, 64), radius: 4.5));
    // Dettaglio: catene che pendono dal mozzo.
    final accent = Path();
    for (final cy in [72.0, 79.0, 86.0]) {
      accent.addOval(
          Rect.fromCenter(center: Offset(50, cy), width: 6, height: 4.6));
    }
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _synthwave() {
    final main = Path()..fillType = PathFillType.evenOdd;
    main.addOval(Rect.fromCircle(center: const Offset(50, 44), radius: 19));
    // bande orizzontali (fori)
    main.addRect(const Rect.fromLTRB(34, 46, 66, 49));
    main.addRect(const Rect.fromLTRB(38, 53, 62, 56));
    main.addRect(const Rect.fromLTRB(42, 59, 58, 61.5));
    // Dettaglio: griglia prospettica retrowave.
    final accent = Path();
    void ray(double bx) {
      accent.moveTo(bx - 1, 94);
      accent.lineTo(bx + 1, 94);
      accent.lineTo(50, 70);
      accent.close();
    }
    ray(8);
    ray(27);
    ray(50);
    ray(73);
    ray(92);
    accent.addRect(const Rect.fromLTRB(24, 80, 76, 81.6));
    accent.addRect(const Rect.fromLTRB(14, 88, 86, 89.6));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _valkyrie() {
    final main = Path();
    // ala sinistra
    main.moveTo(46, 44);
    main.lineTo(20, 38);
    main.lineTo(30, 46);
    main.lineTo(18, 48);
    main.lineTo(30, 54);
    main.lineTo(20, 58);
    main.lineTo(44, 58);
    main.close();
    // ala destra
    main.moveTo(54, 44);
    main.lineTo(80, 38);
    main.lineTo(70, 46);
    main.lineTo(82, 48);
    main.lineTo(70, 54);
    main.lineTo(80, 58);
    main.lineTo(56, 58);
    main.close();
    // Dettaglio: gemma/elmo centrale.
    final accent = Path()
      ..moveTo(50, 38)
      ..lineTo(56, 51)
      ..lineTo(50, 64)
      ..lineTo(44, 51)
      ..close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _ronin() {
    final main = Path();
    // katana A (dal basso-sinistra alla punta alto-destra)
    main.moveTo(24, 86);
    main.lineTo(74, 40);
    main.lineTo(78, 44);
    main.lineTo(28, 90);
    main.close();
    main.addRect(const Rect.fromLTRB(26, 82, 36, 86)); // tsuba A
    // katana B (speculare)
    main.moveTo(76, 86);
    main.lineTo(26, 40);
    main.lineTo(22, 44);
    main.lineTo(72, 90);
    main.close();
    main.addRect(const Rect.fromLTRB(64, 82, 74, 86)); // tsuba B
    // Dettaglio (dietro): disco del sol levante.
    final accent = Path()
      ..addOval(Rect.fromCircle(center: const Offset(50, 30), radius: 12));
    return _EmblemArt(main, accent: accent, accentBehind: true);
  }

  _EmblemArt _anubis() {
    final main = Path();
    // orecchio sinistro
    main.moveTo(32, 8);
    main.lineTo(45, 36);
    main.lineTo(33, 33);
    main.close();
    // orecchio destro
    main.moveTo(68, 8);
    main.lineTo(55, 36);
    main.lineTo(67, 33);
    main.close();
    // testa e muso
    main.moveTo(35, 30);
    main.quadraticBezierTo(35, 26, 50, 26);
    main.quadraticBezierTo(65, 26, 65, 30);
    main.lineTo(61, 52);
    main.quadraticBezierTo(58, 68, 50, 86);
    main.quadraticBezierTo(42, 68, 39, 52);
    main.close();
    // Dettaglio: occhi + interno orecchie.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(45, 45), radius: 2.6));
    accent.addOval(Rect.fromCircle(center: const Offset(55, 45), radius: 2.6));
    accent.moveTo(35, 15);
    accent.lineTo(42, 32);
    accent.lineTo(37, 31);
    accent.close();
    accent.moveTo(65, 15);
    accent.lineTo(58, 32);
    accent.lineTo(63, 31);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }
}
