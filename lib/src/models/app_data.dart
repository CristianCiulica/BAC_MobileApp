import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF2F2F7);
  static const surface = Colors.white;
  static const separator = Color(0xFFD1D1D6);
  static const label = Color(0xFF1C1C1E);
  static const secondLabel = Color(0xFF8E8E93);
  static const tertiaryLabel = Color(0xFFC7C7CC);
  static const blue = Color(0xFF007AFF);
  static const indigo = Color(0xFF5856D6);
  static const teal = Color(0xFF32ADE6);
  static const green = Color(0xFF34C759);
  static const orange = Color(0xFFFF9F0A);
  static const red = Color(0xFFFF3B30);
  static const purple = Color(0xFFAF52DE);
  static const navy = Color(0xFF101B37);
  static const loginBackground = Color(0xFFF8F9FA);
}

class AppText {
  static const largeTitleStyle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.label,
    letterSpacing: -0.5,
  );

  static const titleStyle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.label,
    letterSpacing: -0.3,
  );

  static const bodyStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.label,
    letterSpacing: -0.2,
  );

  static const subheadStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.secondLabel,
    letterSpacing: -0.1,
  );

  static const captionStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondLabel,
    letterSpacing: 0.1,
  );

  static const footnoteSectionStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.secondLabel,
    letterSpacing: 0.3,
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

const List<Profile> appProfiles = [
  Profile(
    name: 'Mate-Info',
    description: 'Profil Real · Matematică M1',
    icon: CupertinoIcons.desktopcomputer,
    accentColor: AppColors.blue,
    subjects: [
      Subject(title: 'Limba Română', icon: CupertinoIcons.book_fill, accentColor: AppColors.blue),
      Subject(title: 'Matematică (M1)', icon: CupertinoIcons.function, accentColor: AppColors.indigo),
      Subject(title: 'Informatică', icon: CupertinoIcons.chevron_left_slash_chevron_right, accentColor: AppColors.teal),
      Subject(title: 'Fizică', icon: CupertinoIcons.bolt_fill, accentColor: AppColors.orange),
    ],
  ),
  Profile(
    name: 'Filologie',
    description: 'Profil Uman · Proba E.c) Istorie',
    icon: CupertinoIcons.book,
    accentColor: AppColors.orange,
    subjects: [
      Subject(title: 'Limba Română', icon: CupertinoIcons.book_fill, accentColor: AppColors.blue),
      Subject(title: 'Istorie', icon: CupertinoIcons.building_2_fill, accentColor: AppColors.orange),
      Subject(title: 'Geografie', icon: CupertinoIcons.globe, accentColor: AppColors.green),
    ],
  ),
];

const List<ExamSession> examSessions = [
  ExamSession(name: 'Sesiunea Iunie', desc: 'Examenul oficial principal', icon: CupertinoIcons.sun_max_fill, color: AppColors.orange),
  ExamSession(name: 'Sesiunea Aug / Sept', desc: 'A doua sesiune oficială', icon: CupertinoIcons.moon_fill, color: AppColors.indigo),
  ExamSession(name: 'Simulare Națională', desc: 'Testarea din primăvară', icon: CupertinoIcons.chart_bar_fill, color: AppColors.teal),
  ExamSession(name: 'Modele oficiale', desc: 'Variante orientative de la minister', icon: CupertinoIcons.doc_text_fill, color: AppColors.green),
];

const List<String> examYears = ['2025', '2024', '2023', '2022', '2021', '2020'];

