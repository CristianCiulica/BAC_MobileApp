import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/app_data.dart';
import '../navigation.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
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
                        icon: CupertinoIcons.chat_bubble_2_fill,
                        label: 'Mesaje dezvoltator',
                        color: AppColors.purple,
                        onTap: () =>
                            _push(context, const DeveloperMessagesScreen()),
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
                        onTap: () => _push(context, const AppRatingScreen()),
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
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
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

class AppRatingScreen extends StatefulWidget {
  const AppRatingScreen({super.key});

  @override
  State<AppRatingScreen> createState() => _AppRatingScreenState();
}

class _AppRatingScreenState extends State<AppRatingScreen> {
  int _rating = 5;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    final user = AuthService.currentUser;
    if (user == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Neautentificat'),
          content: const Text('Te rog conectează-te ca să trimiți feedback.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await FirestoreService.submitAppFeedback(
        user,
        rating: _rating,
        message: _notesController.text.trim(),
      );
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Mulțumim!'),
          content: Text(
            'Feedback înregistrat: $_rating/5\n${_notesController.text.trim().isEmpty ? 'Fără comentarii suplimentare.' : _notesController.text.trim()}',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _notesController.clear();
      if (mounted) setState(() => _rating = 5);
    } catch (_) {
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Eroare'),
          content: const Text('Nu am putut trimite feedback-ul acum.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 96,
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
              title: Text(
                'Evaluează aplicația',
                style: AppText.largeTitleStyle,
              ),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.separator),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cât de utilă este Bac Pro?',
                          style: AppText.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (index) {
                            final value = index + 1;
                            final selected = value <= _rating;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _rating = value);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  selected
                                      ? CupertinoIcons.star_fill
                                      : CupertinoIcons.star,
                                  color: selected
                                      ? AppColors.orange
                                      : AppColors.tertiaryLabel,
                                  size: 24,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 4,
                            style: AppText.bodyStyle,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Ce ți-ar plăcea să îmbunătățim în continuare?',
                              hintStyle: AppText.subheadStyle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(10),
                            onPressed: _submitFeedback,
                            child: const Text(
                              'Trimite feedback',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

class DeveloperMessagesScreen extends StatefulWidget {
  const DeveloperMessagesScreen({super.key});

  @override
  State<DeveloperMessagesScreen> createState() =>
      _DeveloperMessagesScreenState();
}

class _DeveloperMessagesScreenState extends State<DeveloperMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = AuthService.currentUser;
    if (user == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Neautentificat'),
          content: const Text('Conectează-te pentru a trimite mesajul.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await FirestoreService.sendDeveloperMessage(user, message: text);
      _messageController.clear();
      HapticFeedback.mediumImpact();
    } catch (_) {
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Eroare'),
          content: const Text('Nu am putut trimite mesajul acum.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatMessageTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
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
            expandedHeight: 96,
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
              title: Text('Mesaje dezvoltator', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                IOSSection(
                  header: 'Trimite sugestie',
                  footer:
                      'Mesajele apar în documentul tău din Firebase la câmpul developerMessages.',
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scrie ce ai vrea să îmbunătățim în Bac Pro.',
                            style: AppText.subheadStyle,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _messageController,
                              maxLines: 4,
                              style: AppText.bodyStyle,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Ex: aș vrea filtre pe ani, profil...',
                                hintStyle: AppText.subheadStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(10),
                              onPressed: _sending ? null : _sendMessage,
                              child: _sending
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Trimite mesaj',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IOSSection(
                  header: 'Istoric mesaje',
                  children: [
                    if (user == null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Conectează-te pentru a vedea istoricul de mesaje.',
                          style: AppText.subheadStyle,
                        ),
                      )
                    else
                      StreamBuilder<List<DeveloperMessage>>(
                        stream: FirestoreService.watchDeveloperMessages(user),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(18),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }

                          final messages = snapshot.data ?? const [];
                          if (messages.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Încă nu ai trimis mesaje.',
                                style: AppText.subheadStyle,
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              children: messages.map((message) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.text,
                                        style: AppText.bodyStyle,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatMessageTime(message.createdAt),
                                        style: AppText.captionStyle,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSelectionScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileSelectionScreen({super.key, required this.scaffoldKey});

  Profile _defaultProfile() {
    return appProfiles.firstWhere(
      (profile) => profile.name == 'Mate-Info',
      orElse: () => appProfiles.first,
    );
  }

  Subject _defaultSubject(Profile profile) {
    return profile.subjects.firstWhere(
      (subject) => subject.title.contains('Matematică'),
      orElse: () => profile.subjects.first,
    );
  }

  ExamSession _sessionByName(String name) {
    return examSessions.firstWhere(
      (session) => session.name == name,
      orElse: () => examSessions.first,
    );
  }

  void _openSessionShortcut(
    BuildContext context, {
    required String year,
    required String sessionName,
  }) {
    final profile = _defaultProfile();
    final subject = _defaultSubject(profile);
    final session = _sessionByName(sessionName);

    Navigator.push(
      context,
      cupertinoRoute(
        SubjectDetailScreen(
          profileName: profile.name,
          subjectName: subject.title,
          year: year,
          sessionName: session.name,
          subjectIcon: subject.icon,
          subjectColor: subject.accentColor,
          sessionColor: session.color,
        ),
      ),
    );
  }

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
              const _HomeOverviewPanel(),
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
                    onTap: () => _openSessionShortcut(
                      context,
                      year: '2025',
                      sessionName: 'Sesiunea Iunie',
                    ),
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.flame_fill,
                      color: AppColors.orange,
                    ),
                    title: 'Simulare Națională',
                    subtitle: 'Testare din primăvară',
                    onTap: () => _openSessionShortcut(
                      context,
                      year: '2025',
                      sessionName: 'Simulare Națională',
                    ),
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.star_fill,
                      color: AppColors.purple,
                    ),
                    title: 'Sesiunea Iunie',
                    subtitle: 'Examenul oficial principal',
                    onTap: () => _openSessionShortcut(
                      context,
                      year: '2025',
                      sessionName: 'Sesiunea Iunie',
                    ),
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

class _HomeOverviewPanel extends StatelessWidget {
  const _HomeOverviewPanel();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<StudySession>>(
      stream: FirestoreService.watchSessions(user),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <StudySession>[];
        final progress = UserProgress.fromSessions(sessions);
        final latestGrade = sessions.isEmpty
            ? '-'
            : sessions.first.estimatedGrade.toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1C3F), Color(0xFF1E3C79)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withAlpha(45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tablou de bord',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sessions.isEmpty
                      ? 'Începe primul subiect și îți construim progresul automat.'
                      : 'Ultima sesiune: ${sessions.first.subjectName} · ${sessions.first.year}',
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardMetric(
                        label: 'Subiecte',
                        value: '${progress.solvedCount}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DashboardMetric(
                        label: 'Ultima notă',
                        value: latestGrade,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DashboardMetric(
                        label: 'Streak',
                        value: '${progress.streakDays} zile',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
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
                              profileName: profileName,
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
  final String profileName;
  final String subjectName;
  final String year;
  final String sessionName;
  final IconData subjectIcon;
  final Color subjectColor;
  final Color sessionColor;

  const SubjectDetailScreen({
    super.key,
    required this.profileName,
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

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  static const int _bacDuration = 10800;
  int _secondsLeft = _bacDuration;
  bool _timerRunning = false;
  bool _timerFinished = false;
  Timer? _timer;

  final TextEditingController _notesController = TextEditingController();
  bool _editingNotes = false;

  double _estimatedGrade = 7.0;
  ExamRubric? _coachRubric;
  bool _coachLoading = true;
  final Map<int, int> _coachScores = {};
  ExamPdfAssets? _pdfAssets;
  bool _pdfLoading = true;
  String? _pdfError;
  bool _showAnswerKey = false;

  @override
  void initState() {
    super.initState();
    _loadCoachRubric();
    _loadPdfAssets();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
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

  Future<void> _loadCoachRubric() async {
    setState(() => _coachLoading = true);
    try {
      final fromFirestore = await FirestoreService.fetchExamRubric(
        profile: widget.profileName,
        subject: widget.subjectName,
        year: widget.year,
        session: widget.sessionName,
      );
      final rubric =
          fromFirestore ??
          ExamRubric.fallback(
            profile: widget.profileName,
            subject: widget.subjectName,
            year: widget.year,
            session: widget.sessionName,
          );

      _coachScores.clear();
      for (var i = 0; i < rubric.criteria.length; i++) {
        _coachScores[i] = _initialScoreForCriterion(rubric.criteria[i]);
      }

      if (!mounted) return;
      setState(() {
        _coachRubric = rubric;
        _coachLoading = false;
      });
    } catch (_) {
      final fallback = ExamRubric.fallback(
        profile: widget.profileName,
        subject: widget.subjectName,
        year: widget.year,
        session: widget.sessionName,
      );
      _coachScores.clear();
      for (var i = 0; i < fallback.criteria.length; i++) {
        _coachScores[i] = _initialScoreForCriterion(fallback.criteria[i]);
      }
      if (!mounted) return;
      setState(() {
        _coachRubric = fallback;
        _coachLoading = false;
      });
    }
  }

  int get _coachMaxScore {
    return _coachRubric?.maxScore ?? 0;
  }

  int get _coachTotalScore {
    var total = 0;
    _coachScores.forEach((_, value) {
      total += value;
    });
    return total;
  }

  bool _isFixedCriterion(RubricCriterion criterion) {
    final title = criterion.title.toLowerCase();
    return title.contains('oficiu') || title.contains('punctaj din oficiu');
  }

  int _initialScoreForCriterion(RubricCriterion criterion) {
    return _isFixedCriterion(criterion) ? criterion.maxPoints : 0;
  }

  double get _coachGrade {
    if (_coachMaxScore <= 0) return 1.0;
    final raw = (_coachTotalScore / _coachMaxScore) * 10.0;
    return raw.clamp(1.0, 10.0);
  }

  void _applyCoachGradeToEstimate() {
    HapticFeedback.mediumImpact();
    setState(() => _estimatedGrade = _coachGrade);
  }

  void _resetCoach() {
    HapticFeedback.selectionClick();
    setState(() {
      final rubric = _coachRubric;
      if (rubric == null) {
        _coachScores.updateAll((_, value) => 0);
        return;
      }
      for (var i = 0; i < rubric.criteria.length; i++) {
        _coachScores[i] = _initialScoreForCriterion(rubric.criteria[i]);
      }
    });
  }

  Future<void> _openCoachScoring() async {
    final rubric = _coachRubric;
    if (rubric == null) return;

    final updatedScores = await Navigator.push<Map<int, int>>(
      context,
      cupertinoRoute(
        CoachScoringScreen(
          rubric: rubric,
          initialScores: Map<int, int>.from(_coachScores),
        ),
      ),
    );

    if (!mounted || updatedScores == null) return;
    setState(() {
      _coachScores
        ..clear()
        ..addAll(updatedScores);
    });
  }

  String _coachSummaryLine() {
    return 'Coach BAC: $_coachTotalScore / $_coachMaxScore puncte (${_coachGrade.toStringAsFixed(1)})';
  }

  String _coachFocusLine() {
    final rubric = _coachRubric;
    if (rubric == null) {
      return 'Continuă antrenamentul pe subiecte complete.';
    }

    final weak = <MapEntry<RubricCriterion, int>>[];
    for (var i = 0; i < rubric.criteria.length; i++) {
      final criterion = rubric.criteria[i];
      final score = _coachScores[i] ?? 0;
      final missing = criterion.maxPoints - score;
      if (missing > 0) {
        weak.add(MapEntry(criterion, missing));
      }
    }

    if (weak.isEmpty) {
      return 'Foarte bine. Lucrează pe cronometru pentru consistență.';
    }

    weak.sort((a, b) => b.value.compareTo(a.value));

    final top = weak.take(2).toList();
    if (top.length == 1) {
      return 'Prioritate: ${top.first.key.title.toLowerCase()}.';
    }
    return 'Priorități: ${top[0].key.title.toLowerCase()} + ${top[1].key.title.toLowerCase()}.';
  }

  Future<void> _loadPdfAssets() async {
    setState(() {
      _pdfLoading = true;
      _pdfError = null;
    });
    try {
      final assets = await FirestoreService.fetchExamPdfAssets(
        profile: widget.profileName,
        subject: widget.subjectName,
        year: widget.year,
        session: widget.sessionName,
      );
      if (!mounted) return;
      setState(() {
        _pdfAssets = assets;
        _pdfLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pdfLoading = false;
        _pdfError = 'Nu am putut încărca documentele asociate subiectului.';
      });
    }
  }

  String? get _activePdfAssetPath {
    final assets = _pdfAssets;
    if (assets == null) return null;
    return _showAnswerKey ? assets.answerPdfAsset : assets.subjectPdfAsset;
  }

  String _timerStatusLabel() {
    if (_timerRunning) return 'În desfășurare';
    if (_timerFinished) return 'Finalizat';
    return 'Pregătit';
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.separator),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Timer examen · $_formattedTime',
                                style: TextStyle(
                                  fontFamily: '.SF Pro Display',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _timerColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _timerColor.withAlpha(31),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _timerStatusLabel(),
                                style: TextStyle(
                                  color: _timerColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: _timerProgress,
                            backgroundColor: AppColors.background,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _timerColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${(_timerProgress * 100).toStringAsFixed(0)}% consumat',
                                style: AppText.captionStyle,
                              ),
                            ),
                            Text(
                              '${(_secondsLeft / 60).ceil()} min rămase',
                              style: AppText.captionStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: _timerRunning
                                    ? AppColors.orange
                                    : AppColors.green,
                                onPressed: _timerRunning
                                    ? _pauseTimer
                                    : _startTimer,
                                child: Text(
                                  _timerRunning ? 'Pauză' : 'Start 3h',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.background,
                              onPressed: _resetTimer,
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppColors.secondLabel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.separator),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Documente oficiale',
                                      style: AppText.bodyStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.subjectName} · ${widget.year} · ${widget.sessionName}',
                                      style: AppText.captionStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSlidingSegmentedControl<bool>(
                                groupValue: _showAnswerKey,
                                children: const {
                                  false: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Text('Subiect'),
                                  ),
                                  true: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Text('Barem'),
                                  ),
                                },
                                onValueChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _showAnswerKey = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SizedBox(
                          height: 500,
                          child: Builder(
                            builder: (context) {
                              if (_pdfLoading) {
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              }
                              if (_pdfError != null) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      _pdfError!,
                                      style: AppText.subheadStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              final assetPath = _activePdfAssetPath;
                              if (assetPath == null ||
                                  assetPath.trim().isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Nu există PDF configurat pentru această selecție.\nAdaugă-l în `exam_pdfs`.',
                                      style: AppText.subheadStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(14),
                                ),
                                child: PdfViewer.asset(assetPath),
                              );
                            },
                          ),
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
                  header: 'Coach BAC (gratis)',
                  children: [
                    if (_coachLoading)
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    else if (_coachRubric == null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Nu am putut încărca baremul. Încearcă din nou.',
                          style: AppText.subheadStyle,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _coachRubric!.strategyTip,
                              style: AppText.subheadStyle,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _coachSummaryLine(),
                                      style: AppText.bodyStyle,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _gradeColor(
                                        _coachGrade,
                                      ).withAlpha(38),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _coachGrade.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: _gradeColor(_coachGrade),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _coachFocusLine(),
                              style: AppText.subheadStyle,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: _openCoachScoring,
                                    child: const Text(
                                      'Deschide Coach',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: _applyCoachGradeToEstimate,
                                    child: Text(
                                      'Aplică nota',
                                      style: TextStyle(
                                        color: AppColors.secondLabel,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                onPressed: _resetCoach,
                                child: Text(
                                  'Reset punctaj',
                                  style: TextStyle(
                                    color: AppColors.secondLabel,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        final coachSummary = _coachRubric == null
                            ? ''
                            : '${_coachSummaryLine()}\n${_coachFocusLine()}';
                        final cleanNotes = _notesController.text.trim();
                        final mergedNotes = [
                          if (cleanNotes.isNotEmpty) cleanNotes,
                          if (coachSummary.isNotEmpty) coachSummary,
                        ].join('\n\n');
                        if (user != null) {
                          await FirestoreService.addSession(
                            user,
                            StudySession(
                              subjectName: widget.subjectName,
                              year: widget.year,
                              sessionName: widget.sessionName,
                              durationSeconds: _bacDuration - _secondsLeft,
                              estimatedGrade: _estimatedGrade,
                              notes: mergedNotes,
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

class CoachScoringScreen extends StatefulWidget {
  final ExamRubric rubric;
  final Map<int, int> initialScores;

  const CoachScoringScreen({
    super.key,
    required this.rubric,
    required this.initialScores,
  });

  @override
  State<CoachScoringScreen> createState() => _CoachScoringScreenState();
}

class _CoachScoringScreenState extends State<CoachScoringScreen> {
  late final Map<int, int> _scores;

  @override
  void initState() {
    super.initState();
    _scores = Map<int, int>.from(widget.initialScores);
  }

  bool _isFixedCriterion(RubricCriterion criterion) {
    final title = criterion.title.toLowerCase();
    return title.contains('oficiu') || title.contains('punctaj din oficiu');
  }

  List<int> _allowedOptions(RubricCriterion criterion) {
    if (_isFixedCriterion(criterion)) {
      return [criterion.maxPoints];
    }

    final values = <int>{0};
    for (final candidate in const [2, 3, 5]) {
      if (candidate <= criterion.maxPoints) {
        values.add(candidate);
      }
    }

    if (values.length == 1 && criterion.maxPoints > 0) {
      values.add(criterion.maxPoints);
    }

    final result = values.toList()..sort();
    return result;
  }

  int _totalScore() {
    var total = 0;
    _scores.forEach((_, value) => total += value);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final maxScore = widget.rubric.maxScore;
    final total = _totalScore();
    final grade = maxScore == 0 ? 1.0 : ((total / maxScore) * 10).clamp(1, 10);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 96,
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
              title: Text('Coach BAC', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$total/$maxScore puncte',
                            style: AppText.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            grade.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IOSSection(
                  header: 'Punctaj pe barem',
                  footer:
                      'Punctarea este discretă: 2p, 3p, 5p (fără 1p sau 4p).',
                  children: [
                    ...List.generate(widget.rubric.criteria.length, (index) {
                      final criterion = widget.rubric.criteria[index];
                      final options = _allowedOptions(criterion);
                      final selected = _scores[index] ?? options.first;
                      final isFixed = _isFixedCriterion(criterion);

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    criterion.title,
                                    style: AppText.bodyStyle,
                                  ),
                                ),
                                Text(
                                  '$selected/${criterion.maxPoints}p',
                                  style: AppText.captionStyle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((value) {
                                final active = value == selected;
                                return GestureDetector(
                                  onTap: isFixed
                                      ? null
                                      : () {
                                          HapticFeedback.selectionClick();
                                          setState(
                                            () => _scores[index] = value,
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.blue
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                        color: active
                                            ? AppColors.blue
                                            : AppColors.separator,
                                      ),
                                    ),
                                    child: Text(
                                      '${value}p',
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : AppColors.secondLabel,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (criterion.guidance.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                criterion.guidance,
                                style: AppText.captionStyle,
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        Navigator.pop(context, Map<int, int>.from(_scores));
                      },
                      child: const Text(
                        'Salvează punctajul',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
