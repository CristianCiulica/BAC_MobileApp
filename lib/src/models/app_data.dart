import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  static Color get background =>
      isDark ? const Color(0xFF0B0D12) : const Color(0xFFF2F2F7);
  static Color get surface => isDark ? const Color(0xFF171A22) : Colors.white;
  static Color get separator =>
      isDark ? const Color(0xFF2C2F38) : const Color(0xFFD1D1D6);
  static Color get label =>
      isDark ? const Color(0xFFF4F4F6) : const Color(0xFF1C1C1E);
  static Color get secondLabel =>
      isDark ? const Color(0xFFA9ADB8) : const Color(0xFF8E8E93);
  static Color get tertiaryLabel =>
      isDark ? const Color(0xFF6F7480) : const Color(0xFFC7C7CC);
  static const blue = Color(0xFF007AFF);
  static const indigo = Color(0xFF5856D6);
  static const teal = Color(0xFF32ADE6);
  static const green = Color(0xFF34C759);
  static const orange = Color(0xFFFF9F0A);
  static const red = Color(0xFFFF3B30);
  static const purple = Color(0xFFAF52DE);
  static Color get navy =>
      isDark ? const Color(0xFFEEF2FF) : const Color(0xFF101B37);
  static Color get loginBackground =>
      isDark ? const Color(0xFF0B0D12) : const Color(0xFFF8F9FA);
}

class AppText {
  static TextStyle get largeTitleStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.label,
    letterSpacing: -0.5,
    decoration: TextDecoration.none,
  );

  static TextStyle get titleStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.label,
    letterSpacing: -0.3,
    decoration: TextDecoration.none,
  );

  static TextStyle get bodyStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.label,
    letterSpacing: -0.2,
    decoration: TextDecoration.none,
  );

  static TextStyle get subheadStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.secondLabel,
    letterSpacing: -0.1,
    decoration: TextDecoration.none,
  );

  static TextStyle get captionStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondLabel,
    letterSpacing: 0.1,
    decoration: TextDecoration.none,
  );

  static TextStyle get footnoteSectionStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.secondLabel,
    letterSpacing: 0.3,
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
];

const List<String> examYears = ['2025', '2024', '2023', '2022', '2021', '2020'];
