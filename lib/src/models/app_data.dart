import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// BacPro Design System · Color tokens
/// Bright, luxurious, Apple-inspired. Light mode is the hero; dark mode is a
/// deep, desaturated companion.
/// ---------------------------------------------------------------------------
class AppColors {
  static bool isDark = false;

  // Canvas
  static Color get background =>
      isDark ? const Color(0xFF0A0C12) : const Color(0xFFF5F7FA);
  static Color get backgroundSecondary =>
      isDark ? const Color(0xFF11141C) : const Color(0xFFEEF2F7);
  static Color get surface =>
      isDark ? const Color(0xFF161A24) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated =>
      isDark ? const Color(0xFF1C2130) : const Color(0xFFFFFFFF);

  // Liquid Glass surfaces
  static Color get glass => isDark
      ? const Color(0xFF1A1F2C).withValues(alpha: 0.72)
      : Colors.white.withValues(alpha: 0.72);
  static Color get glassStroke => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.65);
  static Color get glassHighlight => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.9);

  // Lines & fills
  static Color get separator =>
      isDark ? const Color(0xFF252B3A) : const Color(0xFFE4EAF2);
  static Color get fill =>
      isDark ? const Color(0xFF202634) : const Color(0xFFEEF2F7);
  static Color get fillSecondary =>
      isDark ? const Color(0xFF1A1F2C) : const Color(0xFFD8E2F0);

  // Text
  static Color get label =>
      isDark ? const Color(0xFFF5F6FA) : const Color(0xFF0E1220);
  static Color get secondLabel =>
      isDark ? const Color(0xFF9AA3B5) : const Color(0xFF5B6577);
  static Color get tertiaryLabel =>
      isDark ? const Color(0xFF767E92) : const Color(0xFFA6B0C2);

  // Brand & semantic accents
  static const blue = Color(0xFF0A84FF);
  static const blueDeep = Color(0xFF0060DF);
  static const cyan = Color(0xFF3FC8E4);
  static const indigo = Color(0xFF5E5CE6);
  static const teal = Color(0xFF30B0C7);
  static const green = Color(0xFF30C960);
  static const orange = Color(0xFFFF9F0A);
  static const red = Color(0xFFFF453A);
  static const purple = Color(0xFFBF5AF2);

  static Color get navy =>
      isDark ? const Color(0xFFEEF2FF) : const Color(0xFF0E1B3A);
  static Color get loginBackground =>
      isDark ? const Color(0xFF0A0C12) : const Color(0xFFF5F7FA);

  /// Soft tint used behind icon badges and chips.
  static Color tint(Color color) =>
      color.withValues(alpha: isDark ? 0.20 : 0.13);
}

/// Gradient tokens — subtle, never loud.
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E9BFF), Color(0xFF0A6BFF)],
  );

  static LinearGradient hero = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF4B47E8)],
  );

  static LinearGradient accent(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [color, Color.lerp(color, const Color(0xFF0A84FF), 0.45)!],
  );

  /// Very subtle sheen over glass surfaces.
  static LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: AppColors.isDark ? 0.07 : 0.55),
      Colors.white.withValues(alpha: 0.0),
    ],
    stops: const [0.0, 0.55],
  );
}

/// Spacing scale — 8pt system.
class AppSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;

  /// Default horizontal screen inset.
  static const double page = 20;
}

/// Corner radius scale (18–28 for surfaces).
class AppRadius {
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 100;
}

/// Elevation — soft, diffuse, never harsh.
class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.isDark
          ? Colors.black.withValues(alpha: 0.35)
          : const Color(0xFF1A2C4D).withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: AppColors.isDark
          ? Colors.black.withValues(alpha: 0.5)
          : const Color(0xFF1A2C4D).withValues(alpha: 0.10),
      blurRadius: 32,
      offset: const Offset(0, 14),
    ),
  ];
}

/// Blur levels for Liquid Glass.
class AppBlur {
  static const double glass = 26;
  static const double heavy = 40;
}

/// Motion tokens.
class AppDurations {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);
  static const spring = Curves.easeOutBack;
  static const ease = Curves.easeOutCubic;
}

/// Typography scale — SF Pro, strong hierarchy, comfortable spacing.
class AppText {
  static TextStyle get largeTitleStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.label,
    letterSpacing: -0.7,
    height: 1.15,
    decoration: TextDecoration.none,
  );

  static TextStyle get titleStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.label,
    letterSpacing: -0.4,
    decoration: TextDecoration.none,
  );

  static TextStyle get headlineStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.label,
    letterSpacing: -0.3,
    decoration: TextDecoration.none,
  );

  static TextStyle get bodyStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.label,
    letterSpacing: -0.2,
    height: 1.3,
    decoration: TextDecoration.none,
  );

  static TextStyle get subheadStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondLabel,
    letterSpacing: -0.1,
    height: 1.35,
    decoration: TextDecoration.none,
  );

  static TextStyle get captionStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondLabel,
    letterSpacing: 0.05,
    decoration: TextDecoration.none,
  );

  static TextStyle get footnoteSectionStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.secondLabel,
    letterSpacing: 0.4,
    decoration: TextDecoration.none,
  );

  /// Big display numbers (stats, timers).
  static TextStyle get statStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.label,
    letterSpacing: -0.6,
    decoration: TextDecoration.none,
  );
}

class Profile {
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Subject> subjects;

  const Profile({
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.subjects,
  });
}

class Subject {
  final String title;
  final IconData icon;
  final Color accentColor;

  const Subject({
    required this.title,
    required this.icon,
    required this.accentColor,
  });
}

class ExamSession {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;

  const ExamSession({
    required this.name,
    required this.desc,
    required this.icon,
    required this.color,
  });
}

final List<Profile> appProfiles = [
  Profile(
    name: 'Mate-Info',
    description: 'Profil Real · Matematică M1',
    icon: CupertinoIcons.desktopcomputer,
    accentColor: AppColors.blue,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Matematică (M1)',
        icon: CupertinoIcons.function,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Informatică',
        icon: CupertinoIcons.chevron_left_slash_chevron_right,
        accentColor: AppColors.teal,
      ),
      Subject(
        title: 'Biologie',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        accentColor: AppColors.green,
      ),
      Subject(
        title: 'Chimie',
        icon: CupertinoIcons.lab_flask_solid,
        accentColor: AppColors.purple,
      ),
      Subject(
        title: 'Fizică',
        icon: CupertinoIcons.bolt_fill,
        accentColor: AppColors.orange,
      ),
    ],
  ),
  Profile(
    name: 'Științele Naturii',
    description: 'Profil Real · Matematică M2',
    icon: CupertinoIcons.leaf_arrow_circlepath,
    accentColor: AppColors.green,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Matematică (M2)',
        icon: CupertinoIcons.function,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Informatică (M2)',
        icon: CupertinoIcons.chevron_left_slash_chevron_right,
        accentColor: AppColors.teal,
      ),
      Subject(
        title: 'Biologie',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        accentColor: AppColors.green,
      ),
      Subject(
        title: 'Chimie',
        icon: CupertinoIcons.lab_flask_solid,
        accentColor: AppColors.purple,
      ),
      Subject(
        title: 'Fizică',
        icon: CupertinoIcons.bolt_fill,
        accentColor: AppColors.orange,
      ),
    ],
  ),
  Profile(
    name: 'Filologie',
    description: 'Profil Uman · Istorie + discipline socio-umane',
    icon: CupertinoIcons.book,
    accentColor: AppColors.orange,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Istorie',
        icon: CupertinoIcons.building_2_fill,
        accentColor: AppColors.orange,
      ),
      Subject(
        title: 'Geografie',
        icon: CupertinoIcons.globe,
        accentColor: AppColors.green,
      ),
      Subject(
        title: 'Logică',
        icon: CupertinoIcons.lightbulb_fill,
        accentColor: AppColors.purple,
      ),
      Subject(
        title: 'Psihologie',
        icon: CupertinoIcons.person_crop_circle_fill,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Economie',
        icon: CupertinoIcons.chart_pie_fill,
        accentColor: AppColors.orange,
      ),
      Subject(
        title: 'Sociologie',
        icon: CupertinoIcons.person_2_fill,
        accentColor: AppColors.teal,
      ),
      Subject(
        title: 'Filosofie',
        icon: CupertinoIcons.book_circle_fill,
        accentColor: AppColors.blue,
      ),
    ],
  ),
  Profile(
    name: 'Științe Sociale',
    description: 'Profil Uman · Istorie și Geografie/Logică',
    icon: CupertinoIcons.person_2_fill,
    accentColor: AppColors.purple,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Istorie',
        icon: CupertinoIcons.building_2_fill,
        accentColor: AppColors.orange,
      ),
      Subject(
        title: 'Geografie',
        icon: CupertinoIcons.globe,
        accentColor: AppColors.green,
      ),
      Subject(
        title: 'Logică',
        icon: CupertinoIcons.lightbulb_fill,
        accentColor: AppColors.purple,
      ),
      Subject(
        title: 'Psihologie',
        icon: CupertinoIcons.person_crop_circle_fill,
        accentColor: AppColors.indigo,
      ),
    ],
  ),
  Profile(
    name: 'Tehnologic',
    description: 'Profil Tehnologic · Matematică M2',
    icon: CupertinoIcons.gear_alt_fill,
    accentColor: AppColors.teal,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Matematică (M2)',
        icon: CupertinoIcons.function,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Biologie',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        accentColor: AppColors.green,
      ),
      Subject(
        title: 'Geografie',
        icon: CupertinoIcons.globe,
        accentColor: AppColors.teal,
      ),
      Subject(
        title: 'Economie',
        icon: CupertinoIcons.chart_pie_fill,
        accentColor: AppColors.orange,
      ),
    ],
  ),
  Profile(
    name: 'Pedagogic',
    description: 'Profil Vocațional · Pedagogie',
    icon: CupertinoIcons.person_3_fill,
    accentColor: AppColors.red,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Matematică (M3)',
        icon: CupertinoIcons.function,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Istorie',
        icon: CupertinoIcons.building_2_fill,
        accentColor: AppColors.orange,
      ),
      Subject(
        title: 'Pedagogie',
        icon: CupertinoIcons.person_2_square_stack_fill,
        accentColor: AppColors.red,
      ),
      Subject(
        title: 'Psihologie',
        icon: CupertinoIcons.person_crop_circle_fill,
        accentColor: AppColors.indigo,
      ),
    ],
  ),
  Profile(
    name: 'Economic',
    description: 'Profil Servicii · Matematică M2',
    icon: CupertinoIcons.money_dollar_circle_fill,
    accentColor: AppColors.orange,
    subjects: [
      Subject(
        title: 'Limba Română',
        icon: CupertinoIcons.book_fill,
        accentColor: AppColors.blue,
      ),
      Subject(
        title: 'Matematică (M2)',
        icon: CupertinoIcons.function,
        accentColor: AppColors.indigo,
      ),
      Subject(
        title: 'Economie',
        icon: CupertinoIcons.chart_pie_fill,
        accentColor: AppColors.orange,
      ),
      Subject(
        title: 'Geografie',
        icon: CupertinoIcons.globe,
        accentColor: AppColors.green,
      ),
    ],
  ),
];

const List<ExamSession> examSessions = [
  ExamSession(
    name: 'Sesiunea Iunie',
    desc: 'Examenul oficial principal',
    icon: CupertinoIcons.sun_max_fill,
    color: AppColors.orange,
  ),
  ExamSession(
    name: 'Sesiunea Aug / Sept',
    desc: 'A doua sesiune oficială',
    icon: CupertinoIcons.moon_fill,
    color: AppColors.indigo,
  ),
  ExamSession(
    name: 'Simulare Națională',
    desc: 'Testarea din primăvară',
    icon: CupertinoIcons.chart_bar_fill,
    color: AppColors.teal,
  ),
  ExamSession(
    name: 'Sesiunea Specială',
    desc: 'Calendar separat pentru candidați eligibili',
    icon: CupertinoIcons.doc_text_fill,
    color: AppColors.green,
  ),
  ExamSession(
    name: 'Model Oficial',
    desc: 'Modelul de subiect publicat de minister',
    icon: CupertinoIcons.doc_on_doc_fill,
    color: AppColors.purple,
  ),
];

const List<String> examYears = ['2025', '2024', '2023', '2022', '2021', '2020'];

/// Returns the profile matching [name], falling back to the first profile.
Profile profileByName(String? name) {
  if (name == null) return appProfiles.first;
  return appProfiles.firstWhere(
    (p) => p.name == name,
    orElse: () => appProfiles.first,
  );
}
