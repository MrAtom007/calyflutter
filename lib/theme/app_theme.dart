import 'package:flutter/material.dart';

/// Spacing costanti (come nel tema Expo originale).
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Raggi costanti.
class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

Color _hex(String h) {
  h = h.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

/// Palette colori di uno skin.
class AppColors {
  final Color bg;
  final Color card;
  final Color cardAlt;
  final Color text;
  final Color textMuted;
  final Color primary;
  final Color primaryDark;
  final Color border;
  final Color danger;

  const AppColors({
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.primaryDark,
    required this.border,
    required this.danger,
  });

  AppColors copyWith({Color? primary, Color? primaryDark}) => AppColors(
        bg: bg,
        card: card,
        cardAlt: cardAlt,
        text: text,
        textMuted: textMuted,
        primary: primary ?? this.primary,
        primaryDark: primaryDark ?? this.primaryDark,
        border: border,
        danger: danger,
      );

  factory AppColors.hex({
    required String bg,
    required String card,
    required String cardAlt,
    required String text,
    required String textMuted,
    required String primary,
    required String primaryDark,
    required String border,
    required String danger,
  }) =>
      AppColors(
        bg: _hex(bg),
        card: _hex(card),
        cardAlt: _hex(cardAlt),
        text: _hex(text),
        textMuted: _hex(textMuted),
        primary: _hex(primary),
        primaryDark: _hex(primaryDark),
        border: _hex(border),
        danger: _hex(danger),
      );
}

/// Un tema/skin completo.
class AppSkin {
  final String id;
  final String name;
  final String description;
  final Brightness mode;
  final bool neon;
  final bool premium;
  final Color? glow;
  final AppColors colors;

  const AppSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.mode,
    this.neon = false,
    this.premium = false,
    this.glow,
    required this.colors,
  });

  bool get isDark => mode == Brightness.dark;
}

/// Tutti gli skin disponibili.
final Map<String, AppSkin> appThemes = {
  'midnight': AppSkin(
    id: 'midnight',
    name: 'Midnight',
    description: 'Scuro classico con verde energico',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#0f1115', card: '#1a1d24', cardAlt: '#232732', text: '#f5f6fa',
      textMuted: '#9aa0ad', primary: '#4cd964', primaryDark: '#37a94b',
      border: '#2c313c', danger: '#ff5252',
    ),
  ),
  'ocean': AppSkin(
    id: 'ocean',
    name: 'Ocean',
    description: 'Blu profondo, calmo e concentrato',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#0b1622', card: '#132434', cardAlt: '#1b3247', text: '#eaf2fb',
      textMuted: '#8ba3ba', primary: '#38bdf8', primaryDark: '#0ea5e9',
      border: '#22384c', danger: '#f87171',
    ),
  ),
  'sunset': AppSkin(
    id: 'sunset',
    name: 'Sunset',
    description: 'Toni caldi arancio/rosa per chi ama l\u2019energia',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#1a1013', card: '#2a1a1f', cardAlt: '#3a2329', text: '#fdeef0',
      textMuted: '#c4a2a8', primary: '#ff6b6b', primaryDark: '#e14f6b',
      border: '#43292f', danger: '#ff3b6b',
    ),
  ),
  'grape': AppSkin(
    id: 'grape',
    name: 'Grape',
    description: 'Viola deciso, look moderno e premium',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#12101c', card: '#1e1a2e', cardAlt: '#2a2440', text: '#f2effb',
      textMuted: '#a99fc4', primary: '#a78bfa', primaryDark: '#8b5cf6',
      border: '#312a47', danger: '#fb7185',
    ),
  ),
  'paper': AppSkin(
    id: 'paper',
    name: 'Paper',
    description: 'Chiaro e pulito, ideale di giorno',
    mode: Brightness.light,
    colors: AppColors.hex(
      bg: '#f5f6f8', card: '#ffffff', cardAlt: '#eef0f4', text: '#1a1d24',
      textMuted: '#6b7280', primary: '#16a34a', primaryDark: '#15803d',
      border: '#e2e5ea', danger: '#dc2626',
    ),
  ),
  'carbon': AppSkin(
    id: 'carbon',
    name: 'Carbon',
    description: 'Monocromatico AMOLED, massimo contrasto',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#000000', card: '#0d0d0d', cardAlt: '#171717', text: '#ffffff',
      textMuted: '#8a8a8a', primary: '#e5e5e5', primaryDark: '#bdbdbd',
      border: '#262626', danger: '#ef4444',
    ),
  ),
  'forest': AppSkin(
    id: 'forest',
    name: 'Forest',
    description: 'Verde bosco rilassante e naturale',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#0c140f', card: '#14201a', cardAlt: '#1d2e25', text: '#eaf5ee',
      textMuted: '#8fae9c', primary: '#34d399', primaryDark: '#10b981',
      border: '#223a2e', danger: '#f87171',
    ),
  ),
  'crimson': AppSkin(
    id: 'crimson',
    name: 'Crimson',
    description: 'Rosso passione su fondo scuro',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#160b0d', card: '#241315', cardAlt: '#331a1d', text: '#fdeaec',
      textMuted: '#c39aa0', primary: '#f43f5e', primaryDark: '#e11d48',
      border: '#3a2226', danger: '#ff5252',
    ),
  ),
  'amber': AppSkin(
    id: 'amber',
    name: 'Amber',
    description: 'Ambra calda ed energica',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#14100a', card: '#201a10', cardAlt: '#2e2617', text: '#fdf3e0',
      textMuted: '#c4b090', primary: '#f59e0b', primaryDark: '#d97706',
      border: '#3a2f1a', danger: '#ef4444',
    ),
  ),
  'slate': AppSkin(
    id: 'slate',
    name: 'Slate',
    description: 'Grigio-blu in stile GitHub dark',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#0d1117', card: '#161b22', cardAlt: '#21262d', text: '#e6edf3',
      textMuted: '#8b949e', primary: '#58a6ff', primaryDark: '#388bfd',
      border: '#30363d', danger: '#f85149',
    ),
  ),
  'arctic': AppSkin(
    id: 'arctic',
    name: 'Arctic',
    description: 'Chiaro e ghiacciato, azzurro nordico',
    mode: Brightness.light,
    colors: AppColors.hex(
      bg: '#eef4fb', card: '#ffffff', cardAlt: '#e2ecf7', text: '#0f2033',
      textMuted: '#5b7590', primary: '#0ea5e9', primaryDark: '#0284c7',
      border: '#d3e0ee', danger: '#dc2626',
    ),
  ),
  'rose': AppSkin(
    id: 'rose',
    name: 'Rose',
    description: 'Chiaro elegante sui toni del rosa',
    mode: Brightness.light,
    colors: AppColors.hex(
      bg: '#fdf2f6', card: '#ffffff', cardAlt: '#fbe4ec', text: '#2a1720',
      textMuted: '#8a6b76', primary: '#e11d78', primaryDark: '#be185d',
      border: '#f2d5e0', danger: '#dc2626',
    ),
  ),
  'neonGreen': AppSkin(
    id: 'neonGreen',
    name: 'Neon Toxic',
    description: 'Verde neon acido su nero, effetto glow',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#39ff14'),
    colors: AppColors.hex(
      bg: '#05070a', card: '#0b1016', cardAlt: '#111a22', text: '#eafff0',
      textMuted: '#6f8a79', primary: '#39ff14', primaryDark: '#22c40a',
      border: '#123018', danger: '#ff3b6b',
    ),
  ),
  'neonCyan': AppSkin(
    id: 'neonCyan',
    name: 'Neon Ice',
    description: 'Ciano elettrico, look cyberpunk',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#00f0ff'),
    colors: AppColors.hex(
      bg: '#04070b', card: '#0a121a', cardAlt: '#0f1d29', text: '#e6feff',
      textMuted: '#6b8b99', primary: '#00f0ff', primaryDark: '#00b8cc',
      border: '#0e2b36', danger: '#ff4d6d',
    ),
  ),
  'neonPink': AppSkin(
    id: 'neonPink',
    name: 'Neon Blaze',
    description: 'Rosa/magenta neon, energia pura',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ff2ec4'),
    colors: AppColors.hex(
      bg: '#0a040a', card: '#160a14', cardAlt: '#22101f', text: '#ffeafa',
      textMuted: '#9a6f8f', primary: '#ff2ec4', primaryDark: '#d40e9f',
      border: '#331030', danger: '#ff5252',
    ),
  ),
  'neonPurple': AppSkin(
    id: 'neonPurple',
    name: 'Neon Void',
    description: 'Viola/indaco luminoso, futuristico',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#9d4bff'),
    colors: AppColors.hex(
      bg: '#070510', card: '#0f0b1c', cardAlt: '#171029', text: '#f0eaff',
      textMuted: '#8577a3', primary: '#9d4bff', primaryDark: '#7a26e0',
      border: '#241a3d', danger: '#ff4d8d',
    ),
  ),
  'neonOrange': AppSkin(
    id: 'neonOrange',
    name: 'Neon Ember',
    description: 'Arancio incandescente, calore neon',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ff6a00'),
    colors: AppColors.hex(
      bg: '#0a0603', card: '#150c05', cardAlt: '#22140a', text: '#fff0e6',
      textMuted: '#9a7d6b', primary: '#ff6a00', primaryDark: '#cc5200',
      border: '#331d0e', danger: '#ff3b6b',
    ),
  ),
  'neonYellow': AppSkin(
    id: 'neonYellow',
    name: 'Neon Volt',
    description: 'Giallo elettrico ad alta tensione',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#eaff00'),
    colors: AppColors.hex(
      bg: '#0a0a04', card: '#14140a', cardAlt: '#1f1f10', text: '#fbffe6',
      textMuted: '#8a8b6f', primary: '#eaff00', primaryDark: '#b8c400',
      border: '#30310e', danger: '#ff4d6d',
    ),
  ),
  'neonRed': AppSkin(
    id: 'neonRed',
    name: 'Neon Inferno',
    description: 'Rosso lava, aggressivo e vivo',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ff1e3c'),
    colors: AppColors.hex(
      bg: '#0a0405', card: '#16090c', cardAlt: '#220f14', text: '#ffe6ea',
      textMuted: '#9a6f78', primary: '#ff1e3c', primaryDark: '#cc1730',
      border: '#33101a', danger: '#ff5252',
    ),
  ),
  'neonBlue': AppSkin(
    id: 'neonBlue',
    name: 'Neon Pulse',
    description: 'Blu elettrico profondo, pulsante',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#2e7bff'),
    colors: AppColors.hex(
      bg: '#050810', card: '#0a1020', cardAlt: '#0f1a33', text: '#e6eeff',
      textMuted: '#6f82a3', primary: '#2e7bff', primaryDark: '#1a5ae0',
      border: '#1a2340', danger: '#ff4d8d',
    ),
  ),
  // ---- Temi epici "forza" ----
  'spartacus': AppSkin(
    id: 'spartacus',
    name: 'Spartacus',
    description: 'Sangue e bronzo, forza da gladiatore',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#c0392b'),
    colors: AppColors.hex(
      bg: '#140807', card: '#20100d', cardAlt: '#2e1813',
      text: '#f7e6d8', textMuted: '#b58e78', primary: '#c0392b',
      primaryDark: '#8e211a', border: '#3a1f18', danger: '#ff5240',
    ),
  ),
  'kratos': AppSkin(
    id: 'kratos',
    name: 'Kratos',
    description: 'Cenere spartana e rosso caos',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#e63329'),
    colors: AppColors.hex(
      bg: '#0c0d0f', card: '#16181c', cardAlt: '#20242a', text: '#eceff3',
      textMuted: '#9aa3ad', primary: '#e63329', primaryDark: '#a5221b',
      border: '#2a2f36', danger: '#ff4736',
    ),
  ),
  'ulisse': AppSkin(
    id: 'ulisse',
    name: 'Ulisse',
    description: 'Mare Egeo e oro, astuzia e forza',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#e2b53f'),
    colors: AppColors.hex(
      bg: '#07131c', card: '#0e2130', cardAlt: '#153043', text: '#eaf6ff',
      textMuted: '#89a7bb', primary: '#e2b53f', primaryDark: '#b78d1f',
      border: '#1c3a4f', danger: '#ff6b6b',
    ),
  ),
  'zeus': AppSkin(
    id: 'zeus',
    name: 'Zeus',
    description: 'Tempesta e fulmini dorati dell\u2019Olimpo',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ffd85a'),
    colors: AppColors.hex(
      bg: '#0a0c12', card: '#12151f', cardAlt: '#1b2030', text: '#f4f1ff',
      textMuted: '#9aa0c0', primary: '#ffd85a', primaryDark: '#d4a92f',
      border: '#262b40', danger: '#7aa2ff',
    ),
  ),
  'cyberpunk': AppSkin(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    description: 'Neon magenta e ciano, città del futuro',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ff2ec4'),
    colors: AppColors.hex(
      bg: '#05020a', card: '#0e0518', cardAlt: '#170a26', text: '#eafcff',
      textMuted: '#8f7aa8', primary: '#ff2ec4', primaryDark: '#00e5ff',
      border: '#241038', danger: '#ff3860',
    ),
  ),
};

/// Pacchetto sonoro caratterizzante per un tema.
/// - neon* e cyberpunk -> 'neon'
/// - zeus -> 'storm'
/// - spartacus/kratos/ulisse -> 'epic'
/// - tutti gli altri (classici) -> 'clean'
String soundPackForTheme(String themeId) {
  const epic = {'spartacus', 'kratos', 'ulisse'};
  if (themeId == 'zeus') return 'storm';
  if (themeId == 'cyberpunk') return 'neon';
  if (epic.contains(themeId)) return 'epic';
  final skin = appThemes[themeId];
  if (skin != null && skin.neon) return 'neon';
  return 'clean';
}

/// Accento colore opzionale che sovrascrive il primary dello skin attivo.
class AppAccent {
  final String id;
  final String name;
  final Color color;
  final Color dark;
  const AppAccent(this.id, this.name, this.color, this.dark);
}

const List<AppAccent> accentOptions = [
  AppAccent('default', 'Tema', Color(0x00000000), Color(0x00000000)),
  AppAccent('emerald', 'Emerald', Color(0xff4cd964), Color(0xff37a94b)),
  AppAccent('sky', 'Sky', Color(0xff38bdf8), Color(0xff0ea5e9)),
  AppAccent('violet', 'Violet', Color(0xffa78bfa), Color(0xff8b5cf6)),
  AppAccent('rose', 'Rose', Color(0xfff43f5e), Color(0xffe11d48)),
  AppAccent('amber', 'Amber', Color(0xfff59e0b), Color(0xffd97706)),
  AppAccent('cyan', 'Cyan', Color(0xff2ee6d6), Color(0xff14b8a6)),
  AppAccent('magenta', 'Magenta', Color(0xffff2ec4), Color(0xffd40e9f)),
  AppAccent('lime', 'Lime', Color(0xffbef264), Color(0xff84cc16)),
  AppAccent('orange', 'Orange', Color(0xffff6a00), Color(0xffcc5200)),
];

AppAccent? accentById(String? id) {
  if (id == null || id == 'default') return null;
  for (final a in accentOptions) {
    if (a.id == id) return a;
  }
  return null;
}

/// Densità dell'interfaccia: influenza spaziature e raggi.
enum UiDensity { compact, comfortable, spacious }

extension UiDensityScale on UiDensity {
  double get scale => switch (this) {
        UiDensity.compact => 0.78,
        UiDensity.comfortable => 1.0,
        UiDensity.spacious => 1.2,
      };
  String get label => switch (this) {
        UiDensity.compact => 'Compatto',
        UiDensity.comfortable => 'Comodo',
        UiDensity.spacious => 'Ampio',
      };
}

/// Stile delle card dell'app.
enum CardStyle { solid, glass, outline }

final List<AppSkin> themeList = appThemes.values.toList();
const List<String> freeThemeIds = [
  'midnight', 'ocean', 'sunset', 'grape', 'paper', 'carbon',
  'forest', 'crimson', 'amber', 'slate', 'arctic', 'rose',
  'spartacus', 'kratos', 'ulisse', 'zeus', 'cyberpunk',
];
const String defaultThemeId = 'midnight';

/// Ombra glow riutilizzabile per i temi neon.
List<BoxShadow> glowShadow(Color color, {double blur = 12, double spread = 1}) {
  return [
    BoxShadow(
      color: color.withValues(alpha: 0.9),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];
}

/// Font display (titoli) e body coerenti in tutta l'app.
/// Usa i font inclusi come asset (Inter body, Sora titoli): nessun download.
TextTheme _appTextTheme(TextTheme base, Color text, Color muted) {
  final body = base.apply(fontFamily: 'Inter');
  TextStyle display(double size,
          {FontWeight weight = FontWeight.w800, double letterSpacing = 0}) =>
      TextStyle(
        fontFamily: 'Sora',
        color: text,
        fontWeight: weight,
        fontSize: size,
        letterSpacing: letterSpacing,
      );
  return body.copyWith(
    displayLarge: display(40, letterSpacing: -0.5),
    displayMedium: display(32, letterSpacing: -0.5),
    displaySmall: display(26),
    headlineMedium: display(22),
    headlineSmall: display(18),
    titleLarge: display(20, weight: FontWeight.w700),
  ).apply(bodyColor: text, displayColor: text);
}

/// Costruisce un ThemeData Material a partire da uno skin.
ThemeData buildThemeData(AppSkin skin) {
  final c = skin.colors;
  final base = skin.isDark ? ThemeData.dark() : ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    primaryColor: c.primary,
    dividerColor: c.border,
    colorScheme: (skin.isDark
            ? const ColorScheme.dark()
            : const ColorScheme.light())
        .copyWith(
      primary: c.primary,
      secondary: c.primary,
      surface: c.card,
      error: c.danger,
      onPrimary: skin.isDark ? Colors.black : Colors.white,
      onSurface: c.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.card,
      foregroundColor: c.text,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: c.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardColor: c.card,
    textTheme: _appTextTheme(base.textTheme, c.text, c.textMuted),
    iconTheme: IconThemeData(color: c.text),
    dialogTheme: DialogThemeData(backgroundColor: c.card),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.card,
      selectedItemColor: c.primary,
      unselectedItemColor: c.textMuted,
    ),
  );
}
