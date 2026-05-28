import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/pdf_export_service.dart';
import '../../features/countdown/services/countdown_service.dart';
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Profil', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
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
                          const SizedBox(height: 20),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.blue,
                                        AppColors.indigo,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.person_fill,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(profile.name, style: AppText.titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            profile.school,
                            style: AppText.subheadStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          IOSSection(
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
                          IOSSection(
                            header: 'Profil BAC',
                            children: [
                              for (final bacProfile in appProfiles)
                                GestureDetector(
                                  onTap: () => FirestoreService.updateProfile(
                                    user: user,
                                    selectedProfile: bacProfile.name,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        AppIconBadge(
                                          icon: bacProfile.icon,
                                          color: bacProfile.accentColor,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            bacProfile.name,
                                            style: AppText.bodyStyle,
                                          ),
                                        ),
                                        if (profile.selectedProfile ==
                                            bacProfile.name)
                                          const Icon(
                                            CupertinoIcons.checkmark_alt,
                                            color: AppColors.blue,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
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
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const Icon(CupertinoIcons.pencil, color: AppColors.blue, size: 16),
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Progres', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
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
                        ),
                        (
                          'Timp total studiu',
                          _formatDuration(progress.totalStudySeconds),
                          AppColors.indigo,
                        ),
                        (
                          'Medie generală',
                          progress.averageGrade == 0
                              ? '-'
                              : progress.averageGrade.toStringAsFixed(2),
                          AppColors.green,
                        ),
                        (
                          'Streak curent',
                          '${progress.streakDays} zile',
                          AppColors.orange,
                        ),
                      ];
                      final subjectEntries =
                          progress.subjectProgress.entries.toList()
                            ..sort((a, b) => a.key.compareTo(b.key));

                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.6,
                              children: [
                                for (final stat in stats)
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          stat.$1,
                                          style: AppText.captionStyle,
                                        ),
                                        Text(
                                          stat.$2,
                                          style: TextStyle(
                                            fontFamily: '.SF Pro Display',
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: stat.$3,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IOSSection(
                            header: 'Progres pe materii',
                            footer: sessions.isEmpty
                                ? 'Rezolvă un subiect ca să apară progresul real.'
                                : null,
                            children: [
                              if (subjectEntries.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    'Nu ai încă sesiuni salvate.',
                                    style: AppText.subheadStyle,
                                  ),
                                )
                              else
                                for (final entry in subjectEntries)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
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
                                              style: AppText.bodyStyle,
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
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: entry.value,
                                            minHeight: 6,
                                            backgroundColor:
                                                AppColors.background,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                          const SizedBox(height: 40),
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Istoric', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<List<StudySession>>(
                    stream: FirestoreService.watchSessions(user),
                    builder: (context, snapshot) {
                      final history = snapshot.data ?? const [];
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          IOSSection(
                            header: 'Sesiuni recente',
                            footer: history.isEmpty
                                ? 'Istoricul se completează când marchezi subiecte ca rezolvate.'
                                : null,
                            children: [
                              if (history.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    'Nu ai încă sesiuni salvate.',
                                    style: AppText.subheadStyle,
                                  ),
                                )
                              else
                                for (final h in history)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: _gradeColor(
                                              h.estimatedGrade,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                h.subjectName,
                                                style: AppText.bodyStyle,
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
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _gradeColor(
                                              h.estimatedGrade,
                                            ).withAlpha(31),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            h.estimatedGrade.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontFamily: '.SF Pro Display',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
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
                          const SizedBox(height: 40),
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Notificări', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
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
                          const SizedBox(height: 8),
                          IOSSection(
                            header: 'Alerte studiu',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.bell_fill,
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
                                icon: CupertinoIcons.flame_fill,
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
                          IOSSection(
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
                                icon: CupertinoIcons.chart_bar_fill,
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
                          const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AppIconBadge(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.bodyStyle)),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
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
  bool? _darkModeOverride;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Setări', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: user == null
                ? const Center(child: CupertinoActivityIndicator())
                : StreamBuilder<UserProfileData>(
                    stream: FirestoreService.watchProfile(user),
                    builder: (context, snapshot) {
                      final profile =
                          snapshot.data ?? UserProfileData.defaults(user);
                      final effectiveDarkMode =
                          _darkModeOverride ?? profile.darkMode;
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          IOSSection(
                            header: 'Aspect',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.moon_fill,
                                color: AppColors.indigo,
                                label: 'Mod întunecat',
                                value: effectiveDarkMode,
                                onChanged: (v) {
                                  setState(() => _darkModeOverride = v);
                                  AppSettings.setDarkMode(v);
                                  FirestoreService.updateSettings(
                                    user,
                                    darkMode: v,
                                  );
                                },
                              ),
                              _SwitchCell(
                                icon: CupertinoIcons.circle_grid_hex_fill,
                                color: AppColors.orange,
                                label: 'Feedback haptic',
                                value: profile.haptics,
                                onChanged: (v) =>
                                    FirestoreService.updateSettings(
                                      user,
                                      haptics: v,
                                    ),
                              ),
                            ],
                          ),
                          IOSSection(
                            header: 'Date',
                            children: [
                              _SwitchCell(
                                icon: CupertinoIcons.cloud_fill,
                                color: AppColors.teal,
                                label: 'Salvare automată',
                                value: profile.autoSave,
                                onChanged: (v) =>
                                    FirestoreService.updateSettings(
                                      user,
                                      autoSave: v,
                                    ),
                              ),
                              IOSCell(
                                leading: const AppIconBadge(
                                  icon: CupertinoIcons.arrow_down_circle_fill,
                                  color: AppColors.blue,
                                ),
                                title: 'Exportă datele mele',
                                subtitle: 'Generează raport PDF',
                                onTap: () =>
                                    _exportUserData(context, profile, user),
                              ),
                              IOSCell(
                                leading: const AppIconBadge(
                                  icon: CupertinoIcons.trash_fill,
                                  color: AppColors.red,
                                ),
                                title: 'Șterge tot istoricul',
                                subtitle: 'Acțiune ireversibilă',
                                onTap: () =>
                                    _confirmDeleteHistory(context, user),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Despre', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blue, AppColors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withAlpha(77),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.book_fill,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Bac Pro',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Versiunea 1.0.0', style: AppText.subheadStyle),
                const SizedBox(height: 32),
                IOSSection(
                  header: 'Aplicație',
                  children: [
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.doc_text,
                        color: AppColors.blue,
                      ),
                      title: 'Termeni și condiții',
                      onTap: () {},
                    ),
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.lock_shield_fill,
                        color: AppColors.green,
                      ),
                      title: 'Politica de confidențialitate',
                      onTap: () {},
                    ),
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.star_fill,
                        color: AppColors.orange,
                      ),
                      title: 'Evaluează pe App Store',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'Creat cu drag pentru elevii din România.',
                  style: AppText.captionStyle.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Bac Pro',
                  style: AppText.captionStyle.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
