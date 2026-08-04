import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Stile di resa dell'emblema, scegliibile in-app.
enum EmblemStyle { classic, line, glow }

extension EmblemStyleLabel on EmblemStyle {
  String get id => name;
}

/// Soggetti "leggendari" (temi/icone mitologiche) che ricevono una resa
/// premium: aura piu' intensa e bordo dorato luminoso.
const Set<String> legendarySubjects = {
  'spartacus', 'kratos', 'ulisse', 'zeus', 'cyberpunk',
  'valkyrie', 'ronin', 'anubis', 'achille', 'leonida', 'poseidon',
  'ercole', 'odino', 'ra', 'ade',
  'cavaliere', 'cerberus', 'igris', 'sukuna', 'toji',
};

bool isLegendarySubject(String? subject) => legendarySubjects.contains(subject);

/// Riflesso dorato usato per rifinire i bordi degli emblemi leggendari.
const Color _legendaryGold = Color(0xFFFFE39A);

/// Soggetti disponibili (bicromatici, ricolorati dal tema).
const List<String> emblemSubjects = [
  'ulisse', 'zeus', 'cyberpunk', 'spartacus', 'kratos',
  'synthwave', 'valkyrie', 'ronin', 'anubis',
  'achille', 'leonida', 'poseidon',
  'ercole', 'odino', 'ra', 'ade',
  'cavaliere', 'cerberus', 'igris', 'sukuna', 'toji',
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
    case 'IconAchille':
      return 'achille';
    case 'IconLeonida':
      return 'leonida';
    case 'IconPoseidon':
      return 'poseidon';
    case 'IconErcole':
      return 'ercole';
    case 'IconOdino':
      return 'odino';
    case 'IconRa':
      return 'ra';
    case 'IconAde':
      return 'ade';
    case 'IconCavaliere':
      return 'cavaliere';
    case 'IconCerberus':
      return 'cerberus';
    case 'IconIgris':
      return 'igris';
    case 'IconSukuna':
      return 'sukuna';
    case 'IconToji':
      return 'toji';
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
    case 'achille':
    case 'leonida':
    case 'poseidon':
    case 'ercole':
    case 'odino':
    case 'ra':
    case 'ade':
    case 'cavaliere':
    case 'cerberus':
    case 'igris':
    case 'sukuna':
    case 'toji':
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
    case 'achille':
      return 'IconAchille';
    case 'leonida':
      return 'IconLeonida';
    case 'poseidon':
      return 'IconPoseidon';
    case 'ercole':
      return 'IconErcole';
    case 'odino':
      return 'IconOdino';
    case 'ra':
      return 'IconRa';
    case 'ade':
      return 'IconAde';
    case 'cavaliere':
      return 'IconCavaliere';
    case 'cerberus':
      return 'IconCerberus';
    case 'igris':
      return 'IconIgris';
    case 'sukuna':
      return 'IconSukuna';
    case 'toji':
      return 'IconToji';
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
    this.legendary,
  });

  final String? subject;
  final double size;
  final Color color;
  final EmblemStyle style;

  /// Se null, viene dedotto automaticamente dal soggetto.
  final bool? legendary;

  @override
  Widget build(BuildContext context) {
    if (subject == null) return SizedBox(width: size, height: size);
    return CustomPaint(
      size: Size.square(size),
      painter: EmblemPainter(
        subject!,
        color,
        style,
        legendary: legendary ?? isLegendarySubject(subject),
      ),
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
  EmblemPainter(this.subject, this.color, this.style,
      {this.legendary = false});

  final String subject;
  final Color color;
  final EmblemStyle style;
  final bool legendary;

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
        _drawGlow(canvas, path, col, detail: detail);
      case EmblemStyle.line:
        _drawLine(canvas, path, col, detail: detail);
      case EmblemStyle.classic:
        canvas.drawPath(path, Paint()..color = col);
    }
  }

  /// Glow "neon": bloom morbido a piu' strati + nucleo pieno e highlight,
  /// per un aspetto luminoso e premium. Gli emblemi leggendari ricevono
  /// un'aura extra e una rifinitura dorata sui bordi.
  void _drawGlow(Canvas canvas, Path path, Color col, {bool detail = false}) {
    final bounds = path.getBounds();
    // Alone diffuso ampio (solo sulle silhouette principali).
    if (!detail) {
      if (legendary) {
        // Aura extra molto ampia per un bagliore imponente.
        canvas.drawPath(
          path,
          Paint()
            ..color = col.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = col.withValues(alpha: legendary ? 0.34 : 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = col.withValues(alpha: legendary ? 0.6 : 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    // Nucleo pieno con leggera sfumatura verticale per dare volume.
    final core = Color.lerp(col, Colors.white, 0.12)!;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [core, col],
        ).createShader(bounds),
    );
    // Highlight sottile sul bordo superiore per il "vetro luminoso".
    if (!detail) {
      // Sui leggendari il rim e' dorato per un tocco prezioso.
      final rim = legendary
          ? _legendaryGold.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.35);
      canvas.drawPath(
        path,
        Paint()
          ..color = rim
          ..style = PaintingStyle.stroke
          ..strokeWidth = legendary ? 1.8 : 1.4
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }

  /// Line: contorno elegante con alone morbido, tratto sfumato e highlight
  /// interno. I dettagli piccoli restano pieni per la leggibilita'.
  void _drawLine(Canvas canvas, Path path, Color col, {bool detail = false}) {
    if (detail) {
      canvas.drawPath(path, Paint()..color = col);
      return;
    }
    final bounds = path.getBounds();
    // Alone morbido dietro il tratto.
    canvas.drawPath(
      path,
      Paint()
        ..color = col.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
    // Tratto principale con sfumatura per dare profondita'.
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(col, Colors.white, 0.35)!, col],
        ).createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    // Highlight interno sottile e luminoso (dorato sui leggendari).
    canvas.drawPath(
      path,
      Paint()
        ..color = (legendary ? _legendaryGold : Colors.white)
            .withValues(alpha: legendary ? 0.6 : 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant EmblemPainter old) =>
      old.subject != subject ||
      old.color != color ||
      old.style != style ||
      old.legendary != legendary;

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
      case 'achille':
        return _achille();
      case 'leonida':
        return _leonida();
      case 'poseidon':
        return _poseidon();
      case 'ercole':
        return _ercole();
      case 'odino':
        return _odino();
      case 'ra':
        return _ra();
      case 'ade':
        return _ade();
      case 'cavaliere':
        return _cavaliere();
      case 'cerberus':
        return _cerberus();
      case 'igris':
        return _igris();
      case 'sukuna':
        return _sukuna();
      case 'toji':
        return _toji();
      default:
        return _zeus();
    }
  }

  _EmblemArt _zeus() {
    // Fulmine affilato ed elegante (singola saetta diagonale).
    final main = Path()
      ..moveTo(74, 6)
      ..lineTo(40, 50)
      ..lineTo(52, 48)
      ..lineTo(26, 94)
      ..lineTo(62, 44)
      ..lineTo(50, 46)
      ..close();
    // Nucleo incandescente interno.
    final accent = Path()
      ..moveTo(66, 18)
      ..lineTo(45, 48)
      ..lineTo(53, 47)
      ..lineTo(38, 76)
      ..lineTo(57, 46)
      ..lineTo(49, 47)
      ..close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _ulisse() {
    // Trireme greca: scafo a mezzaluna con prua e poppa ricurve, albero,
    // vela quadra e banchi di remi.
    final main = Path();
    // scafo (mezzaluna)
    main.moveTo(12, 60);
    main.quadraticBezierTo(50, 84, 88, 60);
    main.lineTo(82, 70);
    main.quadraticBezierTo(50, 88, 18, 70);
    main.close();
    // prua ricurva (sinistra)
    main.moveTo(12, 60);
    main.quadraticBezierTo(5, 53, 10, 46);
    main.lineTo(15, 49);
    main.quadraticBezierTo(13, 56, 20, 62);
    main.close();
    // poppa ricurva (aphlaston, destra)
    main.moveTo(88, 60);
    main.quadraticBezierTo(96, 52, 90, 44);
    main.lineTo(84, 47);
    main.quadraticBezierTo(89, 55, 80, 62);
    main.close();
    // albero
    main.addRect(const Rect.fromLTRB(49, 24, 51, 60));
    // pennone
    main.addRect(const Rect.fromLTRB(30, 26, 70, 29));
    // vela quadra
    main.moveTo(32, 29);
    main.lineTo(68, 29);
    main.lineTo(64, 52);
    main.lineTo(36, 52);
    main.close();
    // Dettaglio: occhio sulla prua, banda vela, remi.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(24, 63), radius: 2.6));
    accent.addRect(const Rect.fromLTRB(35, 39, 65, 42));
    for (final x in [30.0, 40.0, 50.0, 60.0, 70.0]) {
      accent.addRect(Rect.fromLTRB(x - 0.8, 66, x + 0.8, 74));
    }
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _cyberpunk() {
    // Maschera oni/samurai con fiamma e zanne (stile Cyberpunk Samurai).
    final main = Path();
    // volto della maschera
    main.moveTo(30, 46);
    main.quadraticBezierTo(30, 30, 50, 28);
    main.quadraticBezierTo(70, 30, 70, 46);
    main.lineTo(66, 60);
    main.quadraticBezierTo(50, 73, 34, 60);
    main.close();
    // fiamma/corna sopra la testa
    main.moveTo(37, 31);
    main.lineTo(33, 9);
    main.lineTo(44, 26);
    main.lineTo(50, 5);
    main.lineTo(56, 26);
    main.lineTo(67, 9);
    main.lineTo(63, 31);
    main.close();
    // zanne
    main.moveTo(41, 60);
    main.lineTo(38, 71);
    main.lineTo(45, 62);
    main.close();
    main.moveTo(59, 60);
    main.lineTo(62, 71);
    main.lineTo(55, 62);
    main.close();
    // Dettaglio: occhi aggressivi + bocca.
    final accent = Path();
    accent.moveTo(37, 45);
    accent.lineTo(47, 49);
    accent.lineTo(46, 53);
    accent.lineTo(37, 49);
    accent.close();
    accent.moveTo(63, 45);
    accent.lineTo(53, 49);
    accent.lineTo(54, 53);
    accent.lineTo(63, 49);
    accent.close();
    accent.addRect(const Rect.fromLTRB(43, 58, 57, 61));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _spartacus() {
    // Elmo corinzio DI PROFILO (rivolto a sinistra) con cresta fluente.
    final main = Path()..fillType = PathFillType.evenOdd;
    main.moveTo(36, 46);
    main.cubicTo(36, 24, 68, 22, 74, 44); // calotta
    main.lineTo(74, 52);
    main.cubicTo(74, 60, 66, 62, 62, 55); // paranuca posteriore
    main.lineTo(60, 50);
    main.lineTo(56, 50);
    main.lineTo(56, 62);
    main.lineTo(50, 62);
    main.lineTo(50, 50);
    main.lineTo(42, 50);
    main.lineTo(42, 66); // paranaso lungo anteriore
    main.lineTo(36, 66);
    main.close();
    // feritoia dell'occhio (foro)
    main.moveTo(43, 42);
    main.lineTo(52, 42);
    main.lineTo(52, 46);
    main.lineTo(43, 46);
    main.close();
    // Dettaglio: cresta (pennacchio) che si inarca all'indietro.
    final accent = Path();
    accent.moveTo(46, 24);
    accent.cubicTo(48, 6, 74, 5, 84, 20);
    accent.cubicTo(76, 13, 58, 15, 51, 28);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _kratos() {
    // Lame del Caos: due lame ricurve a V con impugnatura avvolta.
    final main = Path();
    // lama sinistra (punta in alto-sinistra)
    main.moveTo(50, 62);
    main.cubicTo(42, 54, 30, 38, 12, 16); // filo esterno fino alla punta
    main.lineTo(20, 18); // spessore punta
    main.cubicTo(30, 36, 40, 48, 50, 56); // filo interno di rientro
    main.close();
    // lama destra (speculare)
    main.moveTo(50, 62);
    main.cubicTo(58, 54, 70, 38, 88, 16);
    main.lineTo(80, 18);
    main.cubicTo(70, 36, 60, 48, 50, 56);
    main.close();
    // mozzo centrale
    main.addOval(Rect.fromCircle(center: const Offset(50, 58), radius: 5));
    // impugnatura avvolta che pende dal mozzo
    main.moveTo(47, 60);
    main.lineTo(53, 60);
    main.lineTo(52, 86);
    main.lineTo(48, 86);
    main.close();
    main.addOval(Rect.fromCircle(center: const Offset(50, 88), radius: 3.4));
    // Dettaglio: occhi del drago + fasce dell'avvolgimento.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(45, 57), radius: 1.7));
    accent.addOval(Rect.fromCircle(center: const Offset(55, 57), radius: 1.7));
    for (final cy in [66.0, 72.0, 78.0]) {
      accent.addRect(Rect.fromLTRB(47.5, cy, 52.5, cy + 2));
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
    // Elmo alato cornuto della Valchiria: elmo centrale con corna e ali spiegate.
    final main = Path();
    // elmo centrale
    main.moveTo(42, 42);
    main.quadraticBezierTo(42, 30, 50, 29);
    main.quadraticBezierTo(58, 30, 58, 42);
    main.lineTo(56, 54);
    main.lineTo(50, 60);
    main.lineTo(44, 54);
    main.close();
    // corno sinistro
    main.moveTo(43, 34);
    main.cubicTo(34, 24, 33, 13, 38, 7);
    main.cubicTo(37, 16, 40, 27, 47, 33);
    main.close();
    // corno destro
    main.moveTo(57, 34);
    main.cubicTo(66, 24, 67, 13, 62, 7);
    main.cubicTo(63, 16, 60, 27, 53, 33);
    main.close();
    // ala sinistra (piume)
    main.moveTo(44, 44);
    main.lineTo(20, 40);
    main.lineTo(30, 47);
    main.lineTo(16, 50);
    main.lineTo(30, 56);
    main.lineTo(20, 60);
    main.lineTo(42, 60);
    main.close();
    // ala destra
    main.moveTo(56, 44);
    main.lineTo(80, 40);
    main.lineTo(70, 47);
    main.lineTo(84, 50);
    main.lineTo(70, 56);
    main.lineTo(80, 60);
    main.lineTo(58, 60);
    main.close();
    // Dettaglio: gemma e feritoia dell'elmo.
    final accent = Path()
      ..moveTo(50, 33)
      ..lineTo(53, 38)
      ..lineTo(50, 43)
      ..lineTo(47, 38)
      ..close();
    accent.addRect(const Rect.fromLTRB(45, 45, 55, 47));
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
    // Testa di sciacallo FRONTALE con copricapo nemes a strisce e diadema:
    // la silhouette iconica e simmetrica di Anubis.
    final main = Path();
    // orecchie appuntite
    main.moveTo(38, 44);
    main.lineTo(31, 7);
    main.lineTo(46, 40);
    main.close();
    main.moveTo(62, 44);
    main.lineTo(69, 7);
    main.lineTo(54, 40);
    main.close();
    // volto affusolato verso il muso
    main.moveTo(43, 36);
    main.lineTo(57, 36);
    main.lineTo(60, 52);
    main.lineTo(55, 72);
    main.lineTo(50, 82);
    main.lineTo(45, 72);
    main.lineTo(40, 52);
    main.close();
    // falde del nemes ai lati del volto
    main.moveTo(24, 46);
    main.lineTo(40, 44);
    main.lineTo(43, 80);
    main.lineTo(27, 88);
    main.close();
    main.moveTo(76, 46);
    main.lineTo(60, 44);
    main.lineTo(57, 80);
    main.lineTo(73, 88);
    main.close();
    // Dettaglio (tinta chiara): diadema, occhi, strisce del nemes, naso.
    final accent = Path();
    // diadema a goccia sulla fronte
    accent.moveTo(50, 28);
    accent.lineTo(54, 34);
    accent.lineTo(50, 40);
    accent.lineTo(46, 34);
    accent.close();
    // occhi
    accent.addOval(Rect.fromCenter(
        center: const Offset(46, 51), width: 5, height: 3));
    accent.addOval(Rect.fromCenter(
        center: const Offset(54, 51), width: 5, height: 3));
    // naso
    accent.moveTo(47, 78);
    accent.lineTo(53, 78);
    accent.lineTo(50, 83);
    accent.close();
    // strisce del nemes
    accent.addRect(const Rect.fromLTRB(28, 53, 40, 56));
    accent.addRect(const Rect.fromLTRB(28, 61, 41, 64));
    accent.addRect(const Rect.fromLTRB(28, 69, 42, 72));
    accent.addRect(const Rect.fromLTRB(60, 53, 72, 56));
    accent.addRect(const Rect.fromLTRB(59, 61, 72, 64));
    accent.addRect(const Rect.fromLTRB(58, 69, 72, 72));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _achille() {
    // Elmo corinzio FRONTALE con paranaso, feritoie e alto cimiero verticale.
    final main = Path()..fillType = PathFillType.evenOdd;
    // sagoma elmo (calotta + paraguance + paranaso)
    main.moveTo(33, 44);
    main.cubicTo(33, 24, 67, 24, 67, 44); // calotta
    main.lineTo(67, 58);
    main.lineTo(59, 58);
    main.lineTo(59, 64); // paraguancia destra
    main.lineTo(53, 64);
    main.lineTo(53, 46); // paranaso (lato destro)
    main.lineTo(47, 46); // paranaso (lato sinistro)
    main.lineTo(47, 64);
    main.lineTo(41, 64); // paraguancia sinistra
    main.lineTo(41, 58);
    main.lineTo(33, 58);
    main.close();
    // feritoie degli occhi (fori)
    main.moveTo(37, 47);
    main.lineTo(45, 47);
    main.lineTo(45, 51);
    main.lineTo(37, 51);
    main.close();
    main.moveTo(55, 47);
    main.lineTo(63, 47);
    main.lineTo(63, 51);
    main.lineTo(55, 51);
    main.close();
    // Dettaglio: cimiero (pennacchio) verticale sopra la calotta.
    final accent = Path();
    accent.moveTo(47, 26);
    accent.lineTo(45, 5);
    accent.lineTo(50, 15);
    accent.lineTo(55, 5);
    accent.lineTo(53, 26);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _leonida() {
    // Scudo rotondo spartano con Lambda (Λ).
    final main = Path()
      ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 30));
    // Dettaglio: bordo (anello) + Lambda.
    final accent = Path()..fillType = PathFillType.evenOdd;
    accent.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 30));
    accent.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 25.5));
    // Lambda
    accent.moveTo(46, 30);
    accent.lineTo(54, 30);
    accent.lineTo(66, 72);
    accent.lineTo(58, 72);
    accent.lineTo(50, 44);
    accent.lineTo(42, 72);
    accent.lineTo(34, 72);
    accent.close();
    // borchie sul bordo dello scudo
    for (var i = 0; i < 8; i++) {
      final a = i * 3.14159 / 4;
      accent.addOval(Rect.fromCircle(
          center: Offset(50 + 27.5 * math.cos(a), 50 + 27.5 * math.sin(a)),
          radius: 1.4));
    }
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _poseidon() {
    // Tridente con rebbi esterni ricurvi a fiocina e asta avvolta.
    final main = Path();
    main.addRect(const Rect.fromLTRB(48.5, 42, 51.5, 90)); // asta
    main.moveTo(48.5, 90); // punta inferiore
    main.lineTo(51.5, 90);
    main.lineTo(50, 98);
    main.close();
    main.addRect(const Rect.fromLTRB(33, 41, 67, 45)); // traversa
    main.addOval(Rect.fromCircle(center: const Offset(33, 43), radius: 2.4));
    main.addOval(Rect.fromCircle(center: const Offset(67, 43), radius: 2.4));
    // rebbio centrale a lancia
    main.moveTo(47, 43);
    main.lineTo(47, 22);
    main.lineTo(50, 10);
    main.lineTo(53, 22);
    main.lineTo(53, 43);
    main.close();
    // rebbio sinistro ricurvo verso l'esterno
    main.moveTo(35, 44);
    main.cubicTo(27, 34, 25, 22, 31, 13);
    main.lineTo(34, 15);
    main.cubicTo(30, 24, 31, 34, 39, 44);
    main.close();
    // rebbio destro (speculare)
    main.moveTo(65, 44);
    main.cubicTo(73, 34, 75, 22, 69, 13);
    main.lineTo(66, 15);
    main.cubicTo(70, 24, 69, 34, 61, 44);
    main.close();
    // Dettaglio: gemma sulla traversa + avvolgimento a spirale sull'asta.
    final accent = Path();
    accent.moveTo(50, 36);
    accent.lineTo(53, 40);
    accent.lineTo(50, 44);
    accent.lineTo(47, 40);
    accent.close();
    accent.addRect(const Rect.fromLTRB(45, 55, 55, 58));
    accent.addRect(const Rect.fromLTRB(45, 64, 55, 67));
    accent.addRect(const Rect.fromLTRB(45, 73, 55, 76));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _ercole() {
    // Clava di Ercole (in diagonale) con borchie.
    final main = Path();
    // impugnatura + asta
    main.moveTo(22, 88);
    main.lineTo(30, 80);
    main.lineTo(58, 52);
    main.lineTo(50, 60);
    main.close();
    // testa nodosa
    main.addOval(Rect.fromCircle(center: const Offset(70, 40), radius: 17));
    // Dettaglio: borchie sulla testa + fascia impugnatura.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(64, 34), radius: 3));
    accent.addOval(Rect.fromCircle(center: const Offset(77, 37), radius: 3));
    accent.addOval(Rect.fromCircle(center: const Offset(70, 48), radius: 3));
    accent.addOval(Rect.fromCircle(center: const Offset(72, 30), radius: 2.4));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _odino() {
    // Valknut: tre triangoli intrecciati (anelli triangolari).
    final ring = Path()..fillType = PathFillType.evenOdd;
    void tri(double cx, double cy, double s) {
      // triangolo esterno
      ring.moveTo(cx, cy - s);
      ring.lineTo(cx - s * 0.92, cy + s * 0.72);
      ring.lineTo(cx + s * 0.92, cy + s * 0.72);
      ring.close();
      // triangolo interno (foro)
      final i = s * 0.5;
      ring.moveTo(cx, cy - i);
      ring.lineTo(cx - i * 0.92, cy + i * 0.72);
      ring.lineTo(cx + i * 0.92, cy + i * 0.72);
      ring.close();
    }

    tri(50, 30, 16);
    tri(39, 58, 16);
    tri(61, 58, 16);
    // Anello runico attorno al Valknut.
    final accent = Path()..fillType = PathFillType.evenOdd;
    accent.addOval(Rect.fromCircle(center: const Offset(50, 48), radius: 44));
    accent.addOval(Rect.fromCircle(center: const Offset(50, 48), radius: 40));
    // tacche runiche sull'anello
    for (var i = 0; i < 12; i++) {
      final a = i * 3.14159 / 6;
      final cx = 50 + 42 * math.cos(a);
      final cy = 48 + 42 * math.sin(a);
      accent.addRect(Rect.fromCenter(center: Offset(cx, cy), width: 2, height: 2));
    }
    return _EmblemArt(ring, accent: accent, accentBehind: true);
  }

  _EmblemArt _ra() {
    // Occhio di Horus (Wedjat), simbolo solare di Ra.
    final main = Path();
    // sopracciglio
    main.moveTo(28, 34);
    main.quadraticBezierTo(50, 24, 74, 32);
    main.lineTo(72, 39);
    main.quadraticBezierTo(50, 31, 31, 40);
    main.close();
    // contorno dell'occhio (mandorla)
    main.moveTo(26, 50);
    main.quadraticBezierTo(48, 40, 76, 48);
    main.quadraticBezierTo(52, 60, 30, 55);
    main.close();
    // linea verticale sotto l'occhio
    main.addRect(const Rect.fromLTRB(39, 55, 42, 72));
    // coda a spirale
    main.moveTo(42, 68);
    main.quadraticBezierTo(52, 82, 66, 75);
    main.lineTo(65, 70);
    main.quadraticBezierTo(53, 75, 46, 66);
    main.close();
    // guancia diagonale
    main.moveTo(60, 55);
    main.lineTo(69, 70);
    main.lineTo(65, 71);
    main.lineTo(56, 57);
    main.close();
    // Dettaglio: pupilla.
    final accent = Path();
    accent.addOval(Rect.fromCircle(center: const Offset(51, 50), radius: 4.5));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _ade() {
    // Bidente di Ade con rebbi ricurvi verso l'esterno.
    final main = Path();
    main.addRect(const Rect.fromLTRB(48.5, 44, 51.5, 92)); // asta
    main.moveTo(48.5, 92);
    main.lineTo(51.5, 92);
    main.lineTo(50, 98);
    main.close();
    main.addRect(const Rect.fromLTRB(37, 42, 63, 46)); // traversa
    main.addOval(Rect.fromCircle(center: const Offset(37, 44), radius: 2.4));
    main.addOval(Rect.fromCircle(center: const Offset(63, 44), radius: 2.4));
    // rebbio sinistro ricurvo
    main.moveTo(42, 44);
    main.cubicTo(36, 32, 36, 20, 41, 12);
    main.lineTo(44, 14);
    main.cubicTo(40, 22, 41, 32, 46, 44);
    main.close();
    // rebbio destro (speculare)
    main.moveTo(58, 44);
    main.cubicTo(64, 32, 64, 20, 59, 12);
    main.lineTo(56, 14);
    main.cubicTo(60, 22, 59, 32, 54, 44);
    main.close();
    // Dettaglio: gemma sulla traversa + fasce sull'asta.
    final accent = Path();
    accent.moveTo(50, 37);
    accent.lineTo(53, 41);
    accent.lineTo(50, 45);
    accent.lineTo(47, 41);
    accent.close();
    accent.addRect(const Rect.fromLTRB(45, 56, 55, 59));
    accent.addRect(const Rect.fromLTRB(45, 66, 55, 69));
    accent.addRect(const Rect.fromLTRB(45, 76, 55, 79));
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _cavaliere() {
    // Grande elmo del cavaliere (great helm) frontale con visiera a croce.
    final main = Path();
    main.moveTo(34, 26);
    main.quadraticBezierTo(50, 20, 66, 26);
    main.lineTo(68, 64);
    main.quadraticBezierTo(66, 79, 50, 83);
    main.quadraticBezierTo(34, 79, 32, 64);
    main.close();
    // Dettaglio: feritoia degli occhi + barra verticale (croce).
    final accent = Path();
    accent.addRect(const Rect.fromLTRB(36, 43, 64, 48));
    accent.addRect(const Rect.fromLTRB(47, 30, 53, 72));
    // fori di aerazione
    for (final x in [42.0, 50.0, 58.0]) {
      accent.addOval(Rect.fromCircle(center: Offset(x, 64), radius: 1.4));
    }
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _cerberus() {
    // Cerbero: tre teste di lupo con occhi ardenti.
    final main = Path();
    final accent = Path();
    void head(double cx, double cy, double s) {
      // muso (verso il basso)
      main.moveTo(cx - 0.6 * s, cy - 0.5 * s);
      main.lineTo(cx + 0.6 * s, cy - 0.5 * s);
      main.lineTo(cx + 0.45 * s, cy + 0.4 * s);
      main.lineTo(cx, cy + 0.95 * s);
      main.lineTo(cx - 0.45 * s, cy + 0.4 * s);
      main.close();
      // orecchie
      main.moveTo(cx - 0.55 * s, cy - 0.45 * s);
      main.lineTo(cx - 0.72 * s, cy - 1.05 * s);
      main.lineTo(cx - 0.18 * s, cy - 0.55 * s);
      main.close();
      main.moveTo(cx + 0.55 * s, cy - 0.45 * s);
      main.lineTo(cx + 0.72 * s, cy - 1.05 * s);
      main.lineTo(cx + 0.18 * s, cy - 0.55 * s);
      main.close();
      // occhi ardenti
      accent.addOval(Rect.fromCircle(
          center: Offset(cx - 0.24 * s, cy - 0.12 * s), radius: 0.12 * s));
      accent.addOval(Rect.fromCircle(
          center: Offset(cx + 0.24 * s, cy - 0.12 * s), radius: 0.12 * s));
    }

    // teste laterali (dietro) + testa centrale (davanti)
    head(27, 54, 17);
    head(73, 54, 17);
    head(50, 40, 22);
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _igris() {
    // Elmo del cavaliere comandante con cimiero fluente.
    final main = Path();
    main.moveTo(36, 36);
    main.quadraticBezierTo(36, 26, 50, 26);
    main.quadraticBezierTo(62, 26, 62, 38);
    main.lineTo(60, 56);
    main.quadraticBezierTo(52, 70, 44, 66);
    main.lineTo(40, 54);
    main.close();
    // cresta a punta sulla sommita'
    main.moveTo(47, 27);
    main.lineTo(50, 14);
    main.lineTo(56, 27);
    main.close();
    // Dettaglio: feritoia luminosa + cimiero all'indietro.
    final accent = Path();
    accent.moveTo(41, 43);
    accent.lineTo(56, 41);
    accent.lineTo(55, 47);
    accent.lineTo(41, 48);
    accent.close();
    accent.moveTo(56, 30);
    accent.cubicTo(64, 14, 82, 12, 92, 20);
    accent.cubicTo(78, 16, 63, 22, 58, 36);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _sukuna() {
    // Volto maledetto del Re: quattro occhi, tatuaggi e ghigno.
    final main = Path();
    main.moveTo(50, 20);
    main.quadraticBezierTo(72, 30, 72, 50);
    main.quadraticBezierTo(72, 72, 50, 82);
    main.quadraticBezierTo(28, 72, 28, 50);
    main.quadraticBezierTo(28, 30, 50, 20);
    main.close();
    // Dettaglio (cremisi): quattro occhi, tatuaggi, ghigno.
    final accent = Path();
    // occhi superiori
    accent.moveTo(34, 40);
    accent.lineTo(45, 43);
    accent.lineTo(44, 47);
    accent.lineTo(34, 44);
    accent.close();
    accent.moveTo(66, 40);
    accent.lineTo(55, 43);
    accent.lineTo(56, 47);
    accent.lineTo(66, 44);
    accent.close();
    // occhi inferiori
    accent.moveTo(35, 52);
    accent.lineTo(45, 54);
    accent.lineTo(44, 58);
    accent.lineTo(35, 56);
    accent.close();
    accent.moveTo(65, 52);
    accent.lineTo(55, 54);
    accent.lineTo(56, 58);
    accent.lineTo(65, 56);
    accent.close();
    // tatuaggi sulla fronte
    accent.addRect(const Rect.fromLTRB(46, 26, 48, 36));
    accent.addRect(const Rect.fromLTRB(52, 26, 54, 36));
    // ghigno
    accent.moveTo(38, 66);
    accent.quadraticBezierTo(50, 74, 62, 66);
    accent.lineTo(60, 69);
    accent.quadraticBezierTo(50, 75, 40, 69);
    accent.close();
    return _EmblemArt(main, accent: accent);
  }

  _EmblemArt _toji() {
    // Lancia Inversa del Cielo: lama a doppio taglio con catena.
    final main = Path();
    // lama (punta verso il basso)
    main.moveTo(50, 20);
    main.lineTo(56, 30);
    main.lineTo(53, 78);
    main.lineTo(50, 90);
    main.lineTo(47, 78);
    main.lineTo(44, 30);
    main.close();
    // guardia
    main.addRect(const Rect.fromLTRB(38, 26, 62, 31));
    // impugnatura
    main.addRect(const Rect.fromLTRB(47, 9, 53, 26));
    main.addOval(Rect.fromCircle(center: const Offset(50, 8), radius: 3));
    // Dettaglio: scanalatura + catena.
    final accent = Path();
    accent.addRect(const Rect.fromLTRB(49, 34, 51, 74));
    for (final p in [
      const Offset(64, 34),
      const Offset(70, 40),
      const Offset(76, 46),
    ]) {
      accent.addOval(Rect.fromCenter(center: p, width: 5, height: 3.6));
    }
    return _EmblemArt(main, accent: accent);
  }
}
