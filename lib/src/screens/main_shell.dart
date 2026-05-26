import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_data.dart';
import '../navigation.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/common.dart';
import 'account_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<UserProfileData>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      FirestoreService.ensureUserDocument(user);
      _profileSubscription = FirestoreService.watchProfile(user).listen((
        profile,
      ) {
        if (AppSettings.darkMode.value != profile.darkMode) {
          AppSettings.setDarkMode(profile.darkMode);
        }
      });
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: ProfileSelectionScreen(scaffoldKey: _scaffoldKey),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.displayName;
    final user = AuthService.currentUser;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.blue, AppColors.indigo],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (user == null)
                          Text(
                            'Profil nesincronizat',
                            style: AppText.subheadStyle,
                          )
                        else
                          StreamBuilder<UserProfileData>(
                            stream: FirestoreService.watchProfile(user),
                            builder: (context, snapshot) {
                              final profile = snapshot.data;
                              return Text(
                                profile == null
                                    ? (user.email ?? 'Profil Bac Pro')
                                    : '${profile.school} · ${profile.selectedProfile}',
                                style: AppText.subheadStyle,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Activ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (user == null) ...[
                      const _StatItem(value: '0', label: 'Subiecte'),
                      const _VerticalDivider(),
                      const _StatItem(value: '0h', label: 'Timp total'),
                      const _VerticalDivider(),
                      const _StatItem(value: '-', label: 'Medie'),
                    ] else
                      StreamBuilder<List<StudySession>>(
                        stream: FirestoreService.watchSessions(user),
                        builder: (context, snapshot) {
                          final progress = UserProgress.fromSessions(
                            snapshot.data ?? const [],
                          );
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                value: '${progress.solvedCount}',
                                label: 'Subiecte',
                              ),
                              const _VerticalDivider(),
                              _StatItem(
                                value: _formatHours(progress.totalStudySeconds),
                                label: 'Timp total',
                              ),
                              const _VerticalDivider(),
                              _StatItem(
                                value: progress.averageGrade == 0
                                    ? '-'
                                    : progress.averageGrade.toStringAsFixed(1),
                                label: 'Medie',
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: AppColors.separator),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerSection(
                    children: [
                      _DrawerItem(
                        icon: CupertinoIcons.person_crop_circle,
                        label: 'Profil utilizator',
                        color: AppColors.blue,
                        onTap: () => _push(context, const UserProfileScreen()),
                      ),
                      _DrawerItem(
                        icon: CupertinoIcons.chart_bar_square_fill,
                        label: 'Progres & Statistici',
                        color: AppColors.indigo,
                        onTap: () => _push(context, const ProgressScreen()),
                      ),
                      _DrawerItem(
                        icon: CupertinoIcons.clock_fill,
                        label: 'Istoric sesiuni',
                        color: AppColors.teal,
                        onTap: () => _push(context, const HistoryScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DrawerSection(
                    children: [
                      _DrawerItem(
                        icon: CupertinoIcons.bell_fill,
                        label: 'Notificări',
                        color: AppColors.red,
                        onTap: () =>
                            _push(context, const NotificationsSettingsScreen()),
                      ),
                      _DrawerItem(
                        icon: CupertinoIcons.moon_fill,
                        label: 'Mod Examen',
                        color: AppColors.purple,
                        badge: 'NOU',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: CupertinoIcons.gear_solid,
                        label: 'Setări',
                        color: AppColors.secondLabel,
                        onTap: () => _push(context, const SettingsScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DrawerSection(
                    children: [
                      _DrawerItem(
                        icon: CupertinoIcons.star_fill,
                        label: 'Evaluează aplicația',
                        color: AppColors.orange,
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: CupertinoIcons.info_circle_fill,
                        label: 'Despre Bac Pro',
                        color: AppColors.blue,
                        onTap: () => _push(context, const AboutScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DrawerSection(
                    children: [
                      _DrawerItem(
                        icon: CupertinoIcons.square_arrow_right,
                        label: 'Deconectează-te',
                        color: AppColors.red,
                        onTap: () async {
                          Navigator.pop(context);
                          await AuthService.signOut();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, cupertinoRoute(page));
  }

  String _formatHours(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h';
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 36, color: AppColors.separator);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.captionStyle),
      ],
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final List<Widget> children;

  const _DrawerSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 0,
                indent: 52,
                color: AppColors.separator,
                thickness: 0.5,
              ),
          ],
        ],
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? AppColors.separator.withAlpha(128)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            AppIconBadge(icon: widget.icon, color: widget.color, size: 36),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.label, style: AppText.bodyStyle)),
            if (widget.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (widget.badge == null)
              Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.tertiaryLabel,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileSelectionScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileSelectionScreen({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 100,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.separator,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.line_horizontal_3,
              color: AppColors.blue,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
            title: Text('Bac Pro', style: AppText.largeTitleStyle),
            expandedTitleScale: 1.0,
            collapseMode: CollapseMode.none,
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IOSSection(
                header: 'Profilul tău',
                children: [
                  for (final profile in appProfiles)
                    IOSCell(
                      leading: AppIconBadge(
                        icon: profile.icon,
                        color: profile.accentColor,
                      ),
                      title: profile.name,
                      subtitle: profile.description,
                      trailing: CountBadge(profile.subjects.length),
                      onTap: () => Navigator.push(
                        context,
                        cupertinoRoute(SubjectListScreen(profile: profile)),
                      ),
                    ),
                ],
              ),
              IOSSection(
                header: 'Acces rapid',
                children: [
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.calendar_today,
                      color: AppColors.red,
                    ),
                    title: '2025',
                    subtitle: 'Cele mai recente subiecte',
                    onTap: () {},
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.flame_fill,
                      color: AppColors.orange,
                    ),
                    title: 'Simulare Națională',
                    subtitle: 'Testare din primăvară',
                    onTap: () {},
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.star_fill,
                      color: AppColors.purple,
                    ),
                    title: 'Sesiunea Iunie',
                    subtitle: 'Examenul oficial principal',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class SubjectListScreen extends StatelessWidget {
  final Profile profile;

  const SubjectListScreen({super.key, required this.profile});

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
              title: Text(profile.name, style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: profile.accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        AppIconBadge(
                          icon: profile.icon,
                          color: Colors.white.withAlpha(64),
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontFamily: '.SF Pro Display',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profile.description,
                                style: TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                IOSSection(
                  header: 'Materii',
                  children: [
                    for (final subject in profile.subjects)
                      IOSCell(
                        leading: AppIconBadge(
                          icon: subject.icon,
                          color: subject.accentColor,
                        ),
                        title: subject.title,
                        onTap: () => Navigator.push(
                          context,
                          cupertinoRoute(
                            YearSelectionScreen(
                              profileName: profile.name,
                              subjectName: subject.title,
                              subjectIcon: subject.icon,
                              subjectColor: subject.accentColor,
                            ),
                          ),
                        ),
                      ),
                  ],
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

class YearSelectionScreen extends StatelessWidget {
  final String profileName;
  final String subjectName;
  final IconData subjectIcon;
  final Color subjectColor;

  const YearSelectionScreen({
    super.key,
    required this.profileName,
    required this.subjectName,
    required this.subjectIcon,
    required this.subjectColor,
  });

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
              title: Text(subjectName, style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                IOSSection(
                  header: 'Alege anul',
                  footer: 'Subiectele sunt disponibile din 2020.',
                  children: [
                    for (final year in examYears)
                      IOSCell(
                        leading: const AppIconBadge(
                          icon: CupertinoIcons.calendar,
                          color: AppColors.indigo,
                        ),
                        title: year,
                        onTap: () => Navigator.push(
                          context,
                          cupertinoRoute(
                            SessionSelectionScreen(
                              profileName: profileName,
                              subjectName: subjectName,
                              year: year,
                              subjectIcon: subjectIcon,
                              subjectColor: subjectColor,
                            ),
                          ),
                        ),
                      ),
                  ],
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

class SessionSelectionScreen extends StatelessWidget {
  final String profileName;
  final String subjectName;
  final String year;
  final IconData subjectIcon;
  final Color subjectColor;

  const SessionSelectionScreen({
    super.key,
    required this.profileName,
    required this.subjectName,
    required this.year,
    required this.subjectIcon,
    required this.subjectColor,
  });

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
              title: Text(year, style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    '$subjectName · $year',
                    style: AppText.subheadStyle,
                  ),
                ),
                IOSSection(
                  header: 'Alege sesiunea',
                  children: [
                    for (final session in examSessions)
                      IOSCell(
                        leading: AppIconBadge(
                          icon: session.icon,
                          color: session.color,
                        ),
                        title: session.name,
                        subtitle: session.desc,
                        trailing: const Icon(
                          CupertinoIcons.play_fill,
                          color: AppColors.blue,
                          size: 16,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          cupertinoRoute(
                            SubjectDetailScreen(
                              subjectName: subjectName,
                              year: year,
                              sessionName: session.name,
                              subjectIcon: subjectIcon,
                              subjectColor: subjectColor,
                              sessionColor: session.color,
                            ),
                          ),
                        ),
                      ),
                  ],
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

class SubjectDetailScreen extends StatefulWidget {
  final String subjectName;
  final String year;
  final String sessionName;
  final IconData subjectIcon;
  final Color subjectColor;
  final Color sessionColor;

  const SubjectDetailScreen({
    super.key,
    required this.subjectName,
    required this.year,
    required this.sessionName,
    required this.subjectIcon,
    required this.subjectColor,
    required this.sessionColor,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  static const int _bacDuration = 10800;
  int _secondsLeft = _bacDuration;
  bool _timerRunning = false;
  bool _timerFinished = false;
  Timer? _timer;

  final TextEditingController _notesController = TextEditingController();
  bool _editingNotes = false;

  double _estimatedGrade = 7.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timerRunning = false;
          _timerFinished = true;
          t.cancel();
          HapticFeedback.heavyImpact();
          _showTimerFinishedDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    HapticFeedback.selectionClick();
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _bacDuration;
      _timerRunning = false;
      _timerFinished = false;
    });
  }

  void _showTimerFinishedDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Timp expirat'),
        content: const Text(
          'Cele 3 ore de examen s-au încheiat. Predă lucrarea.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress => (_bacDuration - _secondsLeft) / _bacDuration;

  Color get _timerColor {
    if (_secondsLeft > 3600) return AppColors.green;
    if (_secondsLeft > 900) return AppColors.orange;
    return AppColors.red;
  }

  Future<void> _openSubjectPdf({required bool answerKey}) async {
    HapticFeedback.selectionClick();
    final file = await PdfExportService.exportSubjectPdf(
      subjectName: widget.subjectName,
      year: widget.year,
      sessionName: widget.sessionName,
      answerKey: answerKey,
    );
    if (!mounted) return;
    _showPdfReadyDialog(file.path);
  }

  Future<void> _shareSubjectPdf() async {
    HapticFeedback.selectionClick();
    final file = await PdfExportService.exportSubjectPdf(
      subjectName: widget.subjectName,
      year: widget.year,
      sessionName: widget.sessionName,
      answerKey: false,
    );
    if (!mounted) return;
    _showPdfReadyDialog(file.path);
  }

  void _showPdfReadyDialog(String path) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('PDF generat'),
        content: Text('Fișierul a fost salvat aici:\n$path'),
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
              onPressed: () {
                if (_timerRunning) {
                  _pauseTimer();
                  showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: const Text('Ieși din subiect?'),
                      content: const Text(
                        'Timerul va fi oprit. Progresul tău se va salva.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Rămâi'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Ieși'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text(widget.subjectName, style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.subjectColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        AppIconBadge(
                          icon: widget.subjectIcon,
                          color: Colors.white.withAlpha(64),
                          size: 46,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sessionName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.year,
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CRONOMETRU EXAMEN',
                      style: AppText.footnoteSectionStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: _timerProgress,
                                strokeWidth: 8,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _timerColor,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _timerRunning ? _pulseAnim.value : 1.0,
                                child: child,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formattedTime,
                                    style: TextStyle(
                                      fontFamily: '.SF Pro Display',
                                      fontSize: 38,
                                      fontWeight: FontWeight.w700,
                                      color: _timerColor,
                                      letterSpacing: -1.5,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _timerRunning
                                        ? 'În desfășurare'
                                        : (_timerFinished
                                              ? 'Finalizat'
                                              : 'Pregătit'),
                                    style: AppText.captionStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_timerFinished) ...[
                              if (_timerRunning)
                                _TimerButton(
                                  label: 'Pauză',
                                  icon: CupertinoIcons.pause_fill,
                                  color: AppColors.orange,
                                  onTap: _pauseTimer,
                                )
                              else
                                _TimerButton(
                                  label: 'Start 3h',
                                  icon: CupertinoIcons.play_fill,
                                  color: AppColors.green,
                                  onTap: _startTimer,
                                ),
                              const SizedBox(width: 12),
                              _TimerButton(
                                label: 'Reset',
                                icon: CupertinoIcons.arrow_counterclockwise,
                                color: AppColors.secondLabel,
                                onTap: _resetTimer,
                              ),
                            ] else
                              _TimerButton(
                                label: 'Resetează',
                                icon: CupertinoIcons.arrow_counterclockwise,
                                color: AppColors.blue,
                                onTap: _resetTimer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_timerProgress * 100).toStringAsFixed(0)}% din timp consumat · ${(_secondsLeft / 60).ceil()} min rămase',
                          style: AppText.captionStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                IOSSection(
                  header: 'Nota estimată',
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Autoevaluare', style: AppText.bodyStyle),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _gradeColor(
                                    _estimatedGrade,
                                  ).withAlpha(38),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _estimatedGrade.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontFamily: '.SF Pro Display',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _gradeColor(_estimatedGrade),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              activeTrackColor: _gradeColor(_estimatedGrade),
                              inactiveTrackColor: AppColors.background,
                              thumbColor: _gradeColor(_estimatedGrade),
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: _estimatedGrade,
                              min: 1.0,
                              max: 10.0,
                              divisions: 18,
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                setState(() => _estimatedGrade = v);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1', style: AppText.captionStyle),
                              Text('5', style: AppText.captionStyle),
                              Text('10', style: AppText.captionStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IOSSection(
                  header: 'Subiect',
                  children: [
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.doc_text,
                        color: AppColors.blue,
                      ),
                      title: 'Vizualizează subiectul',
                      subtitle: 'Generează și deschide PDF',
                      onTap: () => _openSubjectPdf(answerKey: false),
                    ),
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.checkmark_circle_fill,
                        color: AppColors.green,
                      ),
                      title: 'Barem de corectare',
                      subtitle: 'Generează PDF pentru barem',
                      onTap: () => _openSubjectPdf(answerKey: true),
                    ),
                    IOSCell(
                      leading: const AppIconBadge(
                        icon: CupertinoIcons.share,
                        color: AppColors.teal,
                      ),
                      title: 'Distribuie subiectul',
                      subtitle: 'Trimite PDF unui coleg',
                      onTap: _shareSubjectPdf,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NOTE PERSONALE',
                      style: AppText.footnoteSectionStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _notesController,
                          maxLines: 5,
                          onTap: () => setState(() => _editingNotes = true),
                          style: AppText.bodyStyle,
                          decoration: InputDecoration(
                            hintText:
                                'Adaugă observații, formule de reținut, puncte slabe...',
                            hintStyle: AppText.subheadStyle,
                            border: InputBorder.none,
                          ),
                        ),
                        if (_editingNotes) ...[
                          Divider(
                            color: AppColors.separator,
                            height: 16,
                            thickness: 0.5,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text(
                                'Salvează',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() => _editingNotes = false);
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        final user = AuthService.currentUser;
                        if (user != null) {
                          await FirestoreService.addSession(
                            user,
                            StudySession(
                              subjectName: widget.subjectName,
                              year: widget.year,
                              sessionName: widget.sessionName,
                              durationSeconds: _bacDuration - _secondsLeft,
                              estimatedGrade: _estimatedGrade,
                              notes: _notesController.text.trim(),
                              completedAt: DateTime.now(),
                            ),
                          );
                        }
                        if (!context.mounted) return;
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('Subiect finalizat'),
                            content: const Text(
                              'Subiectul a fost marcat ca rezolvat și salvat în istoricul tău.',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Gata'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Marchează ca rezolvat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

  Color _gradeColor(double grade) {
    if (grade >= 8.5) return AppColors.green;
    if (grade >= 5.0) return AppColors.orange;
    return AppColors.red;
  }
}

class _TimerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<_TimerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(31),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withAlpha(77)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 16),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
