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
  'obsidian': AppSkin(
    id: 'obsidian',
    name: 'Obsidian',
    description: 'Nero ossidiana con blu elettrico',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#05060a', card: '#0d0f16', cardAlt: '#151824', text: '#eef2ff',
      textMuted: '#8a90a6', primary: '#4d7cff', primaryDark: '#2f5de0',
      border: '#1c2030', danger: '#ff5470',
    ),
  ),
  'dracula': AppSkin(
    id: 'dracula',
    name: 'Dracula',
    description: 'Viola e rosa su fondo notturno, cult dev',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#282a36', card: '#343746', cardAlt: '#414458', text: '#f8f8f2',
      textMuted: '#a6accd', primary: '#bd93f9', primaryDark: '#9d6ef0',
      border: '#4a4d63', danger: '#ff5555',
    ),
  ),
  'nord': AppSkin(
    id: 'nord',
    name: 'Nord',
    description: 'Palette nordica blu-ghiaccio, sobria',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#2e3440', card: '#3b4252', cardAlt: '#434c5e', text: '#eceff4',
      textMuted: '#a9b1c2', primary: '#88c0d0', primaryDark: '#5e81ac',
      border: '#4c566a', danger: '#bf616a',
    ),
  ),
  'mocha': AppSkin(
    id: 'mocha',
    name: 'Mocha',
    description: 'Caldo caffè e caramello, avvolgente',
    mode: Brightness.dark,
    colors: AppColors.hex(
      bg: '#120e0b', card: '#1d1712', cardAlt: '#29211a', text: '#f4ece2',
      textMuted: '#b39d88', primary: '#c9925e', primaryDark: '#a5713f',
      border: '#33291f', danger: '#ef4444',
    ),
  ),
  'sakura': AppSkin(
    id: 'sakura',
    name: 'Sakura',
    description: 'Chiaro delicato sui toni del ciliegio',
    mode: Brightness.light,
    colors: AppColors.hex(
      bg: '#fdf3f6', card: '#ffffff', cardAlt: '#fbe6ec', text: '#2a1e24',
      textMuted: '#8a6f79', primary: '#ec4899', primaryDark: '#db2777',
      border: '#f3d9e2', danger: '#dc2626',
    ),
  ),
  'matcha': AppSkin(
    id: 'matcha',
    name: 'Matcha',
    description: 'Chiaro verde tè, fresco e naturale',
    mode: Brightness.light,
    colors: AppColors.hex(
      bg: '#f3f7ee', card: '#ffffff', cardAlt: '#e7f0dd', text: '#1e2a17',
      textMuted: '#6b7d5c', primary: '#6a9a3a', primaryDark: '#52792c',
      border: '#dde8cf', danger: '#dc2626',
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
  'neonMint': AppSkin(
    id: 'neonMint',
    name: 'Neon Mint',
    description: 'Verde menta luminoso, fresco e vivo',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#5cffb0'),
    colors: AppColors.hex(
      bg: '#04100b', card: '#0a1a13', cardAlt: '#10261c', text: '#e6fff2',
      textMuted: '#6f9a86', primary: '#5cffb0', primaryDark: '#22c47e',
      border: '#123020', danger: '#ff4d6d',
    ),
  ),
  'neonGold': AppSkin(
    id: 'neonGold',
    name: 'Neon Gold',
    description: 'Oro elettrico, lusso ad alta tensione',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ffd24d'),
    colors: AppColors.hex(
      bg: '#0a0803', card: '#161005', cardAlt: '#22190a', text: '#fff6e0',
      textMuted: '#9a8b6b', primary: '#ffd24d', primaryDark: '#d4a92f',
      border: '#332813', danger: '#ff4d4d',
    ),
  ),
  'neonSynthwave': AppSkin(
    id: 'neonSynthwave',
    name: 'Synthwave \'84',
    description: 'Viola scuro con magenta neon e ciano retrò',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ff2ec4'),
    colors: AppColors.hex(
      bg: '#0d0221', card: '#160a2e', cardAlt: '#20103f', text: '#ffe6fb',
      textMuted: '#9a7fc4', primary: '#ff2ec4', primaryDark: '#00e0ff',
      border: '#2a1650', danger: '#ff3b6b',
    ),
  ),
  'neonToxic': AppSkin(
    id: 'neonToxic',
    name: 'Toxic Green',
    description: 'Nero profondo con verde acido fluorescente',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#7cff00'),
    colors: AppColors.hex(
      bg: '#020402', card: '#08120a', cardAlt: '#0e1e10', text: '#eaffdf',
      textMuted: '#7f9a6f', primary: '#7cff00', primaryDark: '#57c400',
      border: '#183018', danger: '#ff3b6b',
    ),
  ),
  'neonElectricIce': AppSkin(
    id: 'neonElectricIce',
    name: 'Electric Ice',
    description: 'Blu notte con azzurro brillante elettrico',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#3ad9ff'),
    colors: AppColors.hex(
      bg: '#030a18', card: '#08152a', cardAlt: '#0e2140', text: '#e6f6ff',
      textMuted: '#6f90b5', primary: '#3ad9ff', primaryDark: '#12a8e0',
      border: '#123050', danger: '#ff4d6d',
    ),
  ),
  'neonSolarFlare': AppSkin(
    id: 'neonSolarFlare',
    name: 'Solar Flare',
    description: 'Antracite scuro con arancio neon incandescente',
    mode: Brightness.dark,
    neon: true,
    premium: true,
    glow: _hex('#ff7a18'),
    colors: AppColors.hex(
      bg: '#0a0806', card: '#16110c', cardAlt: '#221a12', text: '#fff1e0',
      textMuted: '#9a8770', primary: '#ff7a18', primaryDark: '#d45700',
      border: '#332417', danger: '#ff3b4d',
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
  'valkyrie': AppSkin(
    id: 'valkyrie',
    name: 'Valkyrie',
    description: 'Argento brunito e oro siderale, mito norreno',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#e9d8a6'),
    colors: AppColors.hex(
      bg: '#0b0e12', card: '#151a21', cardAlt: '#20272f', text: '#f2f5f8',
      textMuted: '#9fadb8', primary: '#cdd6df', primaryDark: '#c9a94e',
      border: '#2a323b', danger: '#ff6b6b',
    ),
  ),
  'ronin': AppSkin(
    id: 'ronin',
    name: 'Ronin',
    description: 'Nero, rosso sangue e dettagli rame, Giappone feudale',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#b91c1c'),
    colors: AppColors.hex(
      bg: '#0b0808', card: '#161010', cardAlt: '#211717', text: '#f6ece8',
      textMuted: '#b08f86', primary: '#c0392b', primaryDark: '#b87333',
      border: '#2e1f1c', danger: '#ff5240',
    ),
  ),
  'anubis': AppSkin(
    id: 'anubis',
    name: 'Anubis',
    description: 'Cobalto scuro opaco con oro e turchese, Antico Egitto',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#f2c14e'),
    colors: AppColors.hex(
      bg: '#070a12', card: '#0e1424', cardAlt: '#161f33', text: '#eef3fb',
      textMuted: '#8b9bb5', primary: '#f2c14e', primaryDark: '#2ec4b6',
      border: '#1c2942', danger: '#ff5b6b',
    ),
  ),
  'achille': AppSkin(
    id: 'achille',
    name: 'Achille',
    description: 'Bronzo acceso e nero di Troia, furia dell\u2019eroe',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#cf9b3c'),
    colors: AppColors.hex(
      bg: '#0c0a08', card: '#17130d', cardAlt: '#221a10', text: '#f6ecd8',
      textMuted: '#b39b78', primary: '#cf9b3c', primaryDark: '#a6791f',
      border: '#2e2416', danger: '#ff5240',
    ),
  ),
  'leonida': AppSkin(
    id: 'leonida',
    name: 'Leonida',
    description: 'Rosso spartano e oro, spirito delle Termopili',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#e0b34a'),
    colors: AppColors.hex(
      bg: '#120707', card: '#1f0d0b', cardAlt: '#2d1512', text: '#f7e6da',
      textMuted: '#c39688', primary: '#d13b2f', primaryDark: '#9e2419',
      border: '#3a1c18', danger: '#ff5240',
    ),
  ),
  'poseidon': AppSkin(
    id: 'poseidon',
    name: 'Poseidone',
    description: 'Turchese abissale e oro, dominio dei mari',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#2ee6d6'),
    colors: AppColors.hex(
      bg: '#04121a', card: '#0a2230', cardAlt: '#103243', text: '#e6fbff',
      textMuted: '#85b3bb', primary: '#2ec4b6', primaryDark: '#1a9c90',
      border: '#12414f', danger: '#ff6b6b',
    ),
  ),
  'ercole': AppSkin(
    id: 'ercole',
    name: 'Ercole',
    description: 'Bronzo e pelle di leone, forza delle 12 fatiche',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#c9a24b'),
    colors: AppColors.hex(
      bg: '#0d1109', card: '#17200f', cardAlt: '#212e16', text: '#f0f5e6',
      textMuted: '#a3b389', primary: '#c9a24b', primaryDark: '#9e7c2c',
      border: '#2a361c', danger: '#ff5240',
    ),
  ),
  'odino': AppSkin(
    id: 'odino',
    name: 'Odino',
    description: 'Acciaio norreno e oro, il Padre di tutti',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#e0b34a'),
    colors: AppColors.hex(
      bg: '#0b0f16', card: '#151b28', cardAlt: '#202838', text: '#eaf1fb',
      textMuted: '#97a6bd', primary: '#e0b34a', primaryDark: '#b78d1f',
      border: '#28324a', danger: '#7aa2ff',
    ),
  ),
  'ra': AppSkin(
    id: 'ra',
    name: 'Ra',
    description: 'Oro solare e cielo del deserto, dio del sole',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ffcf4d'),
    colors: AppColors.hex(
      bg: '#120c04', card: '#1f1508', cardAlt: '#2c1f0c', text: '#fff4dd',
      textMuted: '#c2a878', primary: '#f2b418', primaryDark: '#c98f0a',
      border: '#38290f', danger: '#ff5b3b',
    ),
  ),
  'ade': AppSkin(
    id: 'ade',
    name: 'Ade',
    description: 'Fiamma viola degli inferi, signore dell\u2019oltretomba',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#9d6bff'),
    colors: AppColors.hex(
      bg: '#08060c', card: '#110b18', cardAlt: '#1a1226', text: '#ece6f5',
      textMuted: '#9a8fb0', primary: '#7c4dff', primaryDark: '#5a26e0',
      border: '#241a38', danger: '#ff4d8d',
    ),
  ),
  // ---- Nuovi temi leggendari ----
  'cavaliere': AppSkin(
    id: 'cavaliere',
    name: 'Cavaliere',
    description: 'Acciaio e onore, l\u2019elmo del cavaliere',
    mode: Brightness.dark,
    premium: true,
    glow: _hex('#9db8db'),
    colors: AppColors.hex(
      bg: '#0c0f14', card: '#141922', cardAlt: '#1e2530', text: '#eef2f7',
      textMuted: '#9aa6b6', primary: '#7f9bc0', primaryDark: '#536b8f',
      border: '#29323f', danger: '#ff5b6a',
    ),
  ),
  'cerberus': AppSkin(
    id: 'cerberus',
    name: 'Cerberus',
    description: 'Tre teste di fuoco, guardiano degli inferi',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ff6a24'),
    colors: AppColors.hex(
      bg: '#0e0805', card: '#1a0f08', cardAlt: '#26150c', text: '#ffece0',
      textMuted: '#c79a80', primary: '#ff5a1f', primaryDark: '#c23c0c',
      border: '#3a2113', danger: '#ff4030',
    ),
  ),
  'igris': AppSkin(
    id: 'igris',
    name: 'Igris',
    description: 'Cavaliere comandante, lama cremisi',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ff2a44'),
    colors: AppColors.hex(
      bg: '#0a0709', card: '#150b10', cardAlt: '#201017', text: '#f3e9ee',
      textMuted: '#b58f9d', primary: '#e0263f', primaryDark: '#a10f26',
      border: '#301620', danger: '#ff3b4e',
    ),
  ),
  'sukuna': AppSkin(
    id: 'sukuna',
    name: 'Sukuna',
    description: 'Re delle maledizioni, bianco e cremisi',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ff2038'),
    colors: AppColors.hex(
      bg: '#0c0709', card: '#170a0d', cardAlt: '#241014', text: '#f6eef0',
      textMuted: '#c39aa2', primary: '#d81f36', primaryDark: '#9c0f22',
      border: '#341920', danger: '#ff4055',
    ),
  ),
  'toji': AppSkin(
    id: 'toji',
    name: 'Toji',
    description: 'Lo stregone che uccide, lama incatenata',
    mode: Brightness.dark,
    premium: true,
    neon: true,
    glow: _hex('#ff2436'),
    colors: AppColors.hex(
      bg: '#08080a', card: '#121216', cardAlt: '#1b1c22', text: '#eceef2',
      textMuted: '#9498a2', primary: '#d21f2e', primaryDark: '#931019',
      border: '#262830', danger: '#ff4436',
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
  // Nuovi accenti coordinati ai temi Neon e Leggendari.
  AppAccent('toxic', 'Toxic', Color(0xff7cff00), Color(0xff57c400)),
  AppAccent('ice', 'Ice', Color(0xff3ad9ff), Color(0xff12a8e0)),
  AppAccent('solar', 'Solar', Color(0xffff7a18), Color(0xffd45700)),
  AppAccent('gold', 'Gold', Color(0xfff2c14e), Color(0xffc9a94e)),
  AppAccent('copper', 'Copper', Color(0xffb87333), Color(0xff8c5626)),
  AppAccent('teal', 'Teal', Color(0xff2ec4b6), Color(0xff1a9c90)),
  AppAccent('mint', 'Mint', Color(0xff5cffb0), Color(0xff22c47e)),
  AppAccent('indigo', 'Indigo', Color(0xff7c4dff), Color(0xff5a26e0)),
  AppAccent('crimson', 'Crimson', Color(0xffd13b2f), Color(0xff9e2419)),
  AppAccent('steel', 'Steel', Color(0xff9aa7bd), Color(0xff6b7b94)),
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
        UiDensity.compact => 'Piccolo',
        UiDensity.comfortable => 'Normale',
        UiDensity.spacious => 'Grande',
      };

  /// Etichetta secondaria descrittiva mostrata sotto il nome.
  String get hint => switch (this) {
        UiDensity.compact => 'Compatto',
        UiDensity.comfortable => 'Comodo',
        UiDensity.spacious => 'Ampio',
      };
}

/// Stile delle card dell'app.
enum CardStyle { solid, glass, outline }

final List<AppSkin> themeList = appThemes.values.toList();
// Solo i temi classici sono gratuiti. Tutti i temi Neon e Leggendari sono
// contenuti premium sbloccabili dallo Store.
const List<String> freeThemeIds = [
  'midnight', 'ocean', 'sunset', 'grape', 'paper', 'carbon',
  'forest', 'crimson', 'amber', 'slate', 'arctic', 'rose',
  'obsidian', 'dracula', 'nord', 'mocha', 'sakura', 'matcha',
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
