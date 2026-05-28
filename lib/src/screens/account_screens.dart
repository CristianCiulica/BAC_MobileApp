import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/countdown/services/countdown_service.dart';
import '../../features/gamification/widgets/badge_grid.dart';
import '../../features/gamification/widgets/xp_progress_card.dart';
import '../models/app_data.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/common.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Profil'),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<UserProfileData>(
                    stream: FirestoreService.watchProfile(user),
                    builder: (context, snapshot) {
                      final profile =
                          snapshot.data ?? UserProfileData.defaults(user);
                      return Column(
                        children: [
                          const SizedBox(height: AppSpacing.x6),
                          Center(
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: AppColors.tint(AppColors.blue),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.person_fill,
                                color: AppColors.blue,
                                size: 44,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x4),
                          Text(profile.name, style: AppText.titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            profile.school,
                            style: AppText.subheadStyle,
                            textAlign: TextAlign.center,
                          ),
                          CardGroup(
                            header: 'Informații personale',
                            children: [
                              _EditableCell(
                                label: 'Nume',
                                value: profile.name,
                                onTap: () => _editProfileField(
                                  context,
                                  user: user,
                                  title: 'Nume',
                                  initialValue: profile.name,
                                  onSave: (value) async {
                                    await AuthService.updateDisplayName(value);
                                  },
                                ),
                              ),
                              _EditableCell(
                                label: 'Școală',
                                value: profile.school,
                                onTap: () => _editProfileField(
                                  context,
                                  user: user,
                                  title: 'Școală',
                                  initialValue: profile.school,
                                  onSave: (value) =>
                                      FirestoreService.updateProfile(
                                        user: user,
                                        school: value,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          CardGroup(
                            header: 'Profil BAC',
                            children: [
                              for (final bacProfile in appProfiles)
                                CardRow(
                                  leading: TintedIcon(
                                    icon: bacProfile.icon,
                                    color: bacProfile.accentColor,
                                  ),
                                  title: bacProfile.name,
                                  showChevron: false,
                                  trailing:
                                      profile.selectedProfile ==
                                          bacProfile.name
                                      ? const Icon(
                                          CupertinoIcons
                                              .checkmark_circle_fill,
                                          color: AppColors.blue,
                                          size: 22,
                                        )
                                      : null,
                                  onTap: () => FirestoreService.updateProfile(
                                    user: user,
                                    selectedProfile: bacProfile.name,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfileField(
    BuildContext context, {
    required dynamic user,
    required String title,
    required String initialValue,
    required Future<void> Function(String value) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await showCupertinoDialog<String>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(controller: controller),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value == null || value.isEmpty) return;
    await onSave(value);
  }
}

class _EditableCell extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableCell({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: AppText.subheadStyle),
            ),
            Expanded(
              child: Text(
                value,
                style: AppText.bodyStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(CupertinoIcons.pencil, color: AppColors.blue, size: 17),
          ],
        ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Progres'),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<List<StudySession>>(
                    stream: FirestoreService.watchSessions(user),
                    builder: (context, snapshot) {
                      final sessions = snapshot.data ?? const [];
                      final progress = UserProgress.fromSessions(sessions);
                      final stats = [
                        (
                          'Subiecte rezolvate',
                          '${progress.solvedCount}',
                          AppColors.blue,
                          CupertinoIcons.doc_checkmark,
                        ),
                        (
                          'Timp total studiu',
                          _formatDuration(progress.totalStudySeconds),
                          AppColors.indigo,
                          CupertinoIcons.clock,
                        ),
                        (
                          'Medie generală',
                          progress.averageGrade == 0
                              ? '-'
                              : progress.averageGrade.toStringAsFixed(2),
                          AppColors.green,
                          CupertinoIcons.chart_bar,
                        ),
                        (
                          'Streak curent',
                          '${progress.streakDays} zile',
                          AppColors.orange,
                          CupertinoIcons.flame,
                        ),
                      ];
                      final subjectEntries =
                          progress.subjectProgress.entries.toList()
                            ..sort((a, b) => a.key.compareTo(b.key));

                      return Column(
                        children: [
                          const SizedBox(height: AppSpacing.x5),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.page,
                            ),
                            child: XPProgressCard(),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.page,
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.x3,
                              mainAxisSpacing: AppSpacing.x3,
                              childAspectRatio: 1.18,
                              children: [
                                for (final stat in stats)
                                  StatTile(
                                    label: stat.$1,
                                    value: stat.$2,
                                    accent: stat.$3,
                                    icon: stat.$4,
                                  ),
                              ],
                            ),
                          ),
                          CardGroup(
                            header: 'Progres pe materii',
                            footer: sessions.isEmpty
                                ? 'Rezolvă un subiect ca să apară progresul real.'
                                : null,
                            children: [
                              if (subjectEntries.isEmpty)
                                const EmptyState(
                                  icon: CupertinoIcons.chart_bar_square,
                                  title: 'Nicio sesiune încă',
                                  message:
                                      'Progresul pe materii apare după prima sesiune salvată.',
                                )
                              else
                                for (final entry in subjectEntries)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.x4,
                                      vertical: 14,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: AppText.bodyStyle
                                                  .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                            ),
                                            Text(
                                              '${(entry.value * 100).toInt()}%',
                                              style: const TextStyle(
                                                fontFamily: '.SF Pro Text',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.x2),
                                        SoftProgressBar(
                                          value: entry.value,
                                          height: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.page,
                              AppSpacing.x5,
                              AppSpacing.page,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.x2,
                                    bottom: AppSpacing.x2,
                                  ),
                                  child: Text(
                                    'BADGE-URI',
                                    style: AppText.footnoteSectionStyle,
                                  ),
                                ),
                                const BadgeGrid(),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Istoric'),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<List<StudySession>>(
                    stream: FirestoreService.watchSessions(user),
                    builder: (context, snapshot) {
                      final history = snapshot.data ?? const [];
                      return Column(
                        children: [
                          CardGroup(
                            header: 'Sesiuni recente',
                            footer: history.isEmpty
                                ? 'Istoricul se completează când marchezi subiecte ca rezolvate.'
                                : null,
                            children: [
                              if (history.isEmpty)
                                const EmptyState(
                                  icon: CupertinoIcons.clock,
                                  title: 'Nicio sesiune încă',
                                  message:
                                      'Sesiunile finalizate vor apărea aici.',
                                )
                              else
                                for (final h in history)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.x4,
                                      vertical: 13,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.accent(
                                              _gradeColor(h.estimatedGrade),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  AppRadius.pill,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.x3),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                h.subjectName,
                                                style: AppText.bodyStyle
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${h.year} · ${h.sessionName}',
                                                style: AppText.subheadStyle,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Durata: ${_formatDuration(h.durationSeconds)}',
                                                style: AppText.captionStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.tint(
                                              _gradeColor(h.estimatedGrade),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  AppRadius.sm,
                                                ),
                                          ),
                                          child: Text(
                                            h.estimatedGrade.toStringAsFixed(
                                              1,
                                            ),
                                            style: AppText.statStyle.copyWith(
                                              fontSize: 17,
                                              color: _gradeColor(
                                                h.estimatedGrade,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  Color _gradeColor(double g) {
    if (g >= 8.5) return AppColors.green;
    if (g >= 5.0) return AppColors.orange;
    return AppColors.red;
  }
}

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
  }

  Future<void> _syncNotifications({
    required bool dailyReminder,
    required bool streakReminder,
    required bool examAlerts,
  }) async {
    await NotificationService.instance.syncFromSettings(
      dailyReminder: dailyReminder,
      streakReminder: streakReminder,
      examAlerts: examAlerts,
      examDate: CountdownService.instance.notifier.value.examDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Notificări'),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<UserProfileData>(
                    stream: FirestoreService.watchProfile(user),
                    builder: (context, snapshot) {
                      final profile =
                          snapshot.data ?? UserProfileData.defaults(user);
                      return Column(
                        children: [
                          CardGroup(
                            header: 'Alerte studiu',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.bell,
                                color: AppColors.red,
                                label: 'Reamintire zilnică',
                                value: profile.dailyReminder,
                                onChanged: (v) async {
                                  await FirestoreService.updateSettings(
                                    user,
                                    dailyReminder: v,
                                  );
                                  await _syncNotifications(
                                    dailyReminder: v,
                                    streakReminder: profile.streakReminder,
                                    examAlerts: profile.examAlerts,
                                  );
                                },
                              ),
                              _SwitchCell(
                                icon: CupertinoIcons.flame,
                                color: AppColors.orange,
                                label: 'Streak zilnic',
                                value: profile.streakReminder,
                                onChanged: (v) async {
                                  await FirestoreService.updateSettings(
                                    user,
                                    streakReminder: v,
                                  );
                                  await _syncNotifications(
                                    dailyReminder: profile.dailyReminder,
                                    streakReminder: v,
                                    examAlerts: profile.examAlerts,
                                  );
                                },
                              ),
                            ],
                          ),
                          CardGroup(
                            header: 'Examen',
                            footer:
                                'Vei fi notificat cu 7 zile înainte de sesiune.',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.calendar_badge_plus,
                                color: AppColors.blue,
                                label: 'Date sesiuni BAC',
                                value: profile.examAlerts,
                                onChanged: (v) async {
                                  await FirestoreService.updateSettings(
                                    user,
                                    examAlerts: v,
                                  );
                                  await _syncNotifications(
                                    dailyReminder: profile.dailyReminder,
                                    streakReminder: profile.streakReminder,
                                    examAlerts: v,
                                  );
                                },
                              ),
                              _SwitchCell(
                                icon: CupertinoIcons.chart_bar,
                                color: AppColors.green,
                                label: 'Actualizări note',
                                value: profile.gradeUpdates,
                                onChanged: (v) =>
                                    FirestoreService.updateSettings(
                                      user,
                                      gradeUpdates: v,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SwitchCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCell({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: 10,
      ),
      child: Row(
        children: [
          TintedIcon(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: (v) {
              AppHaptics.selection();
              onChanged(v);
            },
            activeTrackColor: AppColors.blue,
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Setări'),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<UserProfileData>(
                    stream: FirestoreService.watchProfile(user),
                    builder: (context, snapshot) {
                      final profile =
                          snapshot.data ?? UserProfileData.defaults(user);
                      return Column(
                        children: [
                          CardGroup(
                            header: 'Aspect',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.circle_grid_hex,
                                color: AppColors.orange,
                                label: 'Feedback haptic',
                                value: profile.haptics,
                                onChanged: (v) {
                                  AppSettings.setHaptics(v);
                                  FirestoreService.updateSettings(
                                    user,
                                    haptics: v,
                                  );
                                },
                              ),
                            ],
                          ),
                          CardGroup(
                            header: 'Date',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.cloud,
                                color: AppColors.teal,
                                label: 'Salvare automată',
                                value: profile.autoSave,
                                onChanged: (v) =>
                                    FirestoreService.updateSettings(
                                      user,
                                      autoSave: v,
                                    ),
                              ),
                              CardRow(
                                leading: const TintedIcon(
                                  icon: CupertinoIcons.arrow_down_circle,
                                  color: AppColors.blue,
                                ),
                                title: 'Exportă datele mele',
                                subtitle: 'Generează raport PDF',
                                onTap: () =>
                                    _exportUserData(context, profile, user),
                              ),
                              CardRow(
                                leading: const TintedIcon(
                                  icon: CupertinoIcons.trash,
                                  color: AppColors.red,
                                ),
                                title: 'Șterge tot istoricul',
                                subtitle: 'Acțiune ireversibilă',
                                onTap: () =>
                                    _confirmDeleteHistory(context, user),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportUserData(
    BuildContext context,
    UserProfileData profile,
    dynamic user,
  ) async {
    final sessions = await FirestoreService.watchSessions(user).first;
    final file = await PdfExportService.exportUserData(
      profile: profile,
      sessions: sessions,
    );
    if (!context.mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('PDF exportat'),
        content: Text('Raportul a fost salvat aici:\n${file.path}'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteHistory(BuildContext context, dynamic user) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Șterge istoricul?'),
        content: const Text(
          'Toate sesiunile și notele vor fi șterse permanent.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await FirestoreService.deleteAllSessions(user);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Despre'),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.x8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.floating,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.asset(
                      'assets/images/login_hero.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x4),
                Text(
                  'BacPro',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Versiunea 1.0.0', style: AppText.subheadStyle),
                const SizedBox(height: AppSpacing.x3),
                CardGroup(
                  header: 'Aplicație',
                  children: [
                    CardRow(
                      leading: const TintedIcon(
                        icon: CupertinoIcons.doc_text,
                        color: AppColors.blue,
                      ),
                      title: 'Termeni și condiții',
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const TermsAndConditionsScreen(),
                        ),
                      ),
                    ),
                    CardRow(
                      leading: const TintedIcon(
                        icon: CupertinoIcons.lock_shield,
                        color: AppColors.green,
                      ),
                      title: 'Politica de confidențialitate',
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    CardRow(
                      leading: const TintedIcon(
                        icon: CupertinoIcons.star,
                        color: AppColors.orange,
                      ),
                      title: 'Evaluează pe App Store',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x10),
                Text(
                  'Creat cu drag pentru elevii din România.',
                  style: AppText.captionStyle.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  '© 2025 BacPro',
                  style: AppText.captionStyle.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.x10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PolicyTemplateScreen(
      title: 'Termeni și condiții',
      sections: const [
        _PolicySection(
          heading: '1. Despre aplicație',
          body:
              'BacPro este o aplicație educațională pentru organizarea pregătirii la Bacalaureat. Conținutul are rol orientativ și nu înlocuiește materialele oficiale ale Ministerului Educației.',
        ),
        _PolicySection(
          heading: '2. Cont utilizator',
          body:
              'Ești responsabil pentru datele contului tău și pentru activitatea desfășurată în aplicație. Recomandăm folosirea unei adrese de email valide pentru recuperarea accesului.',
        ),
        _PolicySection(
          heading: '3. Utilizarea materialelor',
          body:
              'Subiectele, baremele și notițele sunt folosite strict pentru studiu personal. Nu este permisă redistribuirea materialelor în mod care încalcă drepturile autorilor sau sursele oficiale.',
        ),
        _PolicySection(
          heading: '4. Limitarea răspunderii',
          body:
              'BacPro nu garantează obținerea unei note sau promovarea examenului. Rezultatele depind de pregătirea individuală, iar utilizatorul își asumă deciziile luate pe baza informațiilor din aplicație.',
        ),
        _PolicySection(
          heading: '5. Actualizări',
          body:
              'Putem actualiza funcțiile, interfața și regulile aplicației pentru îmbunătățire continuă. Continuarea utilizării după update reprezintă acceptarea noilor condiții.',
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PolicyTemplateScreen(
      title: 'Politica de confidențialitate',
      sections: const [
        _PolicySection(
          heading: '1. Date colectate',
          body:
              'Aplicația poate salva local și în Firebase date de profil (nume, email), setări (temă, haptic), sesiuni de studiu, notițe și feedback trimis către dezvoltator.',
        ),
        _PolicySection(
          heading: '2. Scopul prelucrării',
          body:
              'Datele sunt folosite pentru funcționarea aplicației: sincronizare progres, personalizare experiență și îmbunătățirea produsului.',
        ),
        _PolicySection(
          heading: '3. Stocare și securitate',
          body:
              'Datele sunt stocate prin servicii Firebase și pe dispozitivul tău (acolo unde este cazul). Aplicăm măsuri tehnice rezonabile pentru protecția informațiilor.',
        ),
        _PolicySection(
          heading: '4. Drepturile tale',
          body:
              'Poți solicita actualizarea datelor din profil, poți dezactiva anumite funcții (ex. notificări/haptic) și poți șterge istoricul direct din ecranul de setări.',
        ),
        _PolicySection(
          heading: '5. Contact',
          body:
              'Pentru întrebări legate de confidențialitate, folosește secțiunea „Mesaje dezvoltator" din aplicație.',
        ),
      ],
    );
  }
}

class _PolicyTemplateScreen extends StatelessWidget {
  final String title;
  final List<_PolicySection> sections;

  const _PolicyTemplateScreen({required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: title, titleSize: 24),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.x5,
                AppSpacing.page,
                AppSpacing.x6,
              ),
              child: FloatingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < sections.length; i++) ...[
                      Text(sections[i].heading, style: AppText.headlineStyle),
                      const SizedBox(height: 6),
                      Text(sections[i].body, style: AppText.subheadStyle),
                      if (i != sections.length - 1) ...[
                        const SizedBox(height: AppSpacing.x4),
                        Divider(color: AppColors.separator, height: 1),
                        const SizedBox(height: AppSpacing.x4),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String heading;
  final String body;

  const _PolicySection({required this.heading, required this.body});
}
