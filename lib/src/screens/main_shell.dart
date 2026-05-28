import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../features/countdown/widgets/countdown_card.dart';
import '../models/app_data.dart';
import '../navigation.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_exam_pdf_service.dart';
import '../widgets/common.dart';
import 'account_screens.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<UserProfileData>? _profileSubscription;
  bool _themeHydratedFromProfile = false;
  int _selectedTabIndex = 0;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      FirestoreService.ensureUserDocument(user);
      _profileSubscription = FirestoreService.watchProfile(user).listen((
        profile,
      ) {
        if (!_themeHydratedFromProfile) {
          _themeHydratedFromProfile = true;
          AppSettings.setDarkMode(profile.darkMode);
        }
        AppSettings.setHaptics(profile.haptics);
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
    final tabs = <Widget>[
      ProfileSelectionScreen(onMenuTap: _openMenu),
      const RandomSubjectScreen(),
      const ProfileTabScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(index: _selectedTabIndex, children: tabs),
          if (_selectedTabIndex == 0) _buildSideMenuOverlay(context),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.separator, width: 0.4),
          ),
        ),
        child: CupertinoTabBar(
          currentIndex: _selectedTabIndex,
          activeColor: AppColors.blue,
          inactiveColor: AppColors.secondLabel,
          border: null,
          backgroundColor: AppColors.surface.withAlpha(252),
          onTap: (index) {
            AppHaptics.selection();
            setState(() {
              _selectedTabIndex = index;
              _isMenuOpen = false;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shuffle),
              label: 'Subiect Random',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_crop_circle),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu() {
    if (_isMenuOpen) return;
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;
    setState(() => _isMenuOpen = false);
  }

  Widget _buildSideMenuOverlay(BuildContext context) {
    final menuWidth = MediaQuery.sizeOf(context).width * 0.82;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !_isMenuOpen,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            opacity: _isMenuOpen ? 1 : 0,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.black.withAlpha(70)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: _isMenuOpen ? Offset.zero : const Offset(-1.05, 0),
            child: SizedBox(
              width: menuWidth,
              child: AppDrawer(onClose: _closeMenu),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const AppDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.displayName;
    final user = AuthService.currentUser;

    return Material(
      color: AppColors.surface,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user == null) ...[
                      const Expanded(
                        child: _StatItem(value: '0', label: 'Subiecte'),
                      ),
                      const _VerticalDivider(),
                      const Expanded(
                        child: _StatItem(value: '0h', label: 'Timp total'),
                      ),
                      const _VerticalDivider(),
                      const Expanded(
                        child: _StatItem(value: '-', label: 'Medie'),
                      ),
                    ] else
                      Expanded(
                        child: StreamBuilder<List<StudySession>>(
                          stream: FirestoreService.watchSessions(user),
                          builder: (context, snapshot) {
                            final progress = UserProgress.fromSessions(
                              snapshot.data ?? const [],
                            );
                            return Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    value: '${progress.solvedCount}',
                                    label: 'Subiecte',
                                  ),
                                ),
                                const _VerticalDivider(),
                                Expanded(
                                  child: _StatItem(
                                    value: _formatHours(
                                      progress.totalStudySeconds,
                                    ),
                                    label: 'Timp total',
                                  ),
                                ),
                                const _VerticalDivider(),
                                Expanded(
                                  child: _StatItem(
                                    value: progress.averageGrade == 0
                                        ? '-'
                                        : progress.averageGrade.toStringAsFixed(
                                            1,
                                          ),
                                    label: 'Medie',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
                          onClose?.call();
                          await AuthService.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (_) => false,
                          );
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
    onClose?.call();
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
    return Container(
      width: 0.5,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.separator,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.captionStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
        AppHaptics.selection();
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
    AppHaptics.medium();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  AppHaptics.selection();
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
                              scrollPadding: const EdgeInsets.only(bottom: 140),
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
      AppHaptics.medium();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  'Mesaje dezvoltator',
                  style: AppText.largeTitleStyle,
                ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: TextField(
                                controller: _messageController,
                                maxLines: 4,
                                scrollPadding: const EdgeInsets.only(
                                  bottom: 140,
                                ),
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
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
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
      ),
    );
  }
}

class ProfileSelectionScreen extends StatelessWidget {
  final VoidCallback onMenuTap;

  const ProfileSelectionScreen({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 64,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.separator,
          leadingWidth: 54,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.line_horizontal_3,
              color: AppColors.blue,
            ),
            onPressed: () {
              AppHaptics.medium();
              onMenuTap();
            },
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Bac Pro',
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _HomeOverviewPanel(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CountdownCard(),
              ),
              const SizedBox(height: 12),
              const _NextLevelSection(),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class RandomSubjectScreen extends StatefulWidget {
  const RandomSubjectScreen({super.key});

  @override
  State<RandomSubjectScreen> createState() => _RandomSubjectScreenState();
}

class _RandomSubjectScreenState extends State<RandomSubjectScreen> {
  final Random _random = Random();
  _RandomSubjectPick? _pick;

  @override
  void initState() {
    super.initState();
    _generateRandomPick();
  }

  void _generateRandomPick() {
    if (appProfiles.isEmpty || examYears.isEmpty || examSessions.isEmpty) {
      return;
    }

    final profile = appProfiles[_random.nextInt(appProfiles.length)];
    final subject = profile.subjects[_random.nextInt(profile.subjects.length)];
    final year = examYears[_random.nextInt(examYears.length)];
    final session = examSessions[_random.nextInt(examSessions.length)];

    setState(() {
      _pick = _RandomSubjectPick(
        profileName: profile.name,
        subjectName: subject.title,
        year: year,
        sessionName: session.name,
        subjectIcon: subject.icon,
        subjectColor: subject.accentColor,
        sessionColor: session.color,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pick = _pick;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 64,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.separator,
          titleSpacing: 16,
          title: Text(
            'Subiect Random',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
              letterSpacing: -0.4,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.separator),
                  ),
                  child: pick == null
                      ? const CupertinoActivityIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppIconBadge(
                                  icon: pick.subjectIcon,
                                  color: pick.subjectColor,
                                  size: 48,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pick.subjectName,
                                        style: AppText.titleStyle,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${pick.profileName} · ${pick.year}',
                                        style: AppText.subheadStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: pick.sessionColor.withAlpha(36),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                pick.sessionName,
                                style: TextStyle(
                                  color: pick.sessionColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      AppHaptics.selection();
                      _generateRandomPick();
                    },
                    child: const Text(
                      'Generează alt subiect',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.indigo,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: pick == null
                        ? null
                        : () {
                            AppHaptics.medium();
                            Navigator.push(
                              context,
                              cupertinoRoute(
                                SubjectDetailScreen(
                                  profileName: pick.profileName,
                                  subjectName: pick.subjectName,
                                  year: pick.year,
                                  sessionName: pick.sessionName,
                                  subjectIcon: pick.subjectIcon,
                                  subjectColor: pick.subjectColor,
                                  sessionColor: pick.sessionColor,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      'Începe subiectul',
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
      ],
    );
  }
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 64,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.separator,
          titleSpacing: 16,
          title: Text(
            'Profil',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
              letterSpacing: -0.4,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.separator),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/login_hero.png',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthService.displayName,
                              style: AppText.titleStyle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'Cont Bac Pro',
                              style: AppText.subheadStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IOSSection(
                header: 'Cont',
                children: [
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.person_crop_circle,
                      color: AppColors.blue,
                    ),
                    title: 'Profil utilizator',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const UserProfileScreen()),
                    ),
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.gear_alt_fill,
                      color: AppColors.indigo,
                    ),
                    title: 'Setări',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const SettingsScreen()),
                    ),
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.info_circle_fill,
                      color: AppColors.teal,
                    ),
                    title: 'Despre Bac Pro',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const AboutScreen()),
                    ),
                  ),
                  IOSCell(
                    leading: const AppIconBadge(
                      icon: CupertinoIcons.square_arrow_right,
                      color: AppColors.red,
                    ),
                    title: 'Deconectează-te',
                    onTap: () async {
                      await AuthService.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}

class _RandomSubjectPick {
  final String profileName;
  final String subjectName;
  final String year;
  final String sessionName;
  final IconData subjectIcon;
  final Color subjectColor;
  final Color sessionColor;

  const _RandomSubjectPick({
    required this.profileName,
    required this.subjectName,
    required this.year,
    required this.sessionName,
    required this.subjectIcon,
    required this.subjectColor,
    required this.sessionColor,
  });
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

class _NextLevelSection extends StatelessWidget {
  const _NextLevelSection();

  @override
  Widget build(BuildContext context) {
    return IOSSection(
      header: 'Bac NextLevel',
      footer:
          'Resurse recomandate pentru progres rapid: PDF-uri, cărți și video-uri utile.',
      children: [
        IOSCell(
          leading: const AppIconBadge(
            icon: CupertinoIcons.doc_richtext,
            color: AppColors.indigo,
          ),
          title: 'PDF-uri utile',
          subtitle: 'Fișe, sinteze, variante și recapitulări',
          onTap: () => Navigator.push(
            context,
            cupertinoRoute(
              const ResourceCategoryScreen(
                title: 'PDF-uri utile',
                icon: CupertinoIcons.doc_richtext,
                color: AppColors.indigo,
                items: [
                  ResourceItem(
                    title: 'Fișe pe capitole',
                    description:
                        'Adaugă PDF-uri în assets/resources/pdfs/fise-capitole/',
                  ),
                  ResourceItem(
                    title: 'Sinteze rapide',
                    description:
                        'Păstrează rezumatele scurte pentru recapitularea finală.',
                  ),
                  ResourceItem(
                    title: 'Variante bac + bareme',
                    description:
                        'Centralizează variantele în același folder pentru acces rapid.',
                  ),
                ],
              ),
            ),
          ),
        ),
        IOSCell(
          leading: const AppIconBadge(
            icon: CupertinoIcons.book_fill,
            color: AppColors.orange,
          ),
          title: 'Cărți recomandate',
          subtitle: 'Ce merită cumpărat pentru pregătire',
          onTap: () => Navigator.push(
            context,
            cupertinoRoute(
              const ResourceCategoryScreen(
                title: 'Cărți recomandate',
                icon: CupertinoIcons.book_fill,
                color: AppColors.orange,
                items: [
                  ResourceItem(
                    title: 'Mate M1/M2 pe barem',
                    description:
                        'Selectează cărți cu structură pe punctaje 2p/3p/5p.',
                  ),
                  ResourceItem(
                    title: 'Română pe eseuri + argumentare',
                    description:
                        'Alege materiale cu modele de redactare și scheme clare.',
                  ),
                  ResourceItem(
                    title: 'Info/istorie/biologie dedicate profilului',
                    description:
                        'Păstrează recomandări separate pentru fiecare profil.',
                  ),
                ],
              ),
            ),
          ),
        ),
        IOSCell(
          leading: const AppIconBadge(
            icon: CupertinoIcons.play_rectangle_fill,
            color: AppColors.teal,
          ),
          title: 'Video-uri explicative',
          subtitle: 'Playlist-uri și recapitulări pe capitole',
          onTap: () => Navigator.push(
            context,
            cupertinoRoute(
              const ResourceCategoryScreen(
                title: 'Video-uri explicative',
                icon: CupertinoIcons.play_rectangle_fill,
                color: AppColors.teal,
                items: [
                  ResourceItem(
                    title: 'Recapitulări scurte',
                    description:
                        'Conținut de 10-20 min pentru noțiunile esențiale.',
                  ),
                  ResourceItem(
                    title: 'Rezolvări complete pe variante',
                    description:
                        'Video-uri care explică pașii de notare după barem.',
                  ),
                  ResourceItem(
                    title: 'Simulări cronometrate',
                    description:
                        'Urmărește o rezolvare în timp real pentru ritm de examen.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResourceCategoryScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<ResourceItem> items;

  const ResourceCategoryScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              title: Text(title, style: AppText.largeTitleStyle),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.separator),
                    ),
                    child: Row(
                      children: [
                        AppIconBadge(icon: icon, color: color, size: 46),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Poți adăuga materiale local în `assets/resources/` și le centralizăm aici.',
                            style: AppText.subheadStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IOSSection(
                  header: 'Recomandări',
                  children: [
                    for (final item in items)
                      IOSCell(
                        leading: AppIconBadge(
                          icon: CupertinoIcons.checkmark_seal_fill,
                          color: color,
                        ),
                        title: item.title,
                        subtitle: item.description,
                        onTap: () {},
                      ),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResourceItem {
  final String title;
  final String description;

  const ResourceItem({required this.title, required this.description});
}

class SubjectListScreen extends StatelessWidget {
  final Profile profile;

  const SubjectListScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
  bool _timerFinished = false;

  final TextEditingController _notesController = TextEditingController();
  bool _editingNotes = false;

  double _estimatedGrade = 7.0;
  ExamPdfAssets? _pdfAssets;
  bool _pdfLoading = true;
  String? _pdfError;
  bool _showAnswerKey = false;
  bool _examStarted = false;

  @override
  void initState() {
    super.initState();
    _loadPdfAssets();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _startTimer() async {
    final assets = _pdfAssets;
    final pdfPath = assets?.subjectPdfAsset;
    if (pdfPath == null || pdfPath.isEmpty) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('PDF indisponibil'),
          content: Text('Nu există subiect local pentru această selecție.'),
        ),
      );
      return;
    }

    AppHaptics.medium();
    setState(() => _examStarted = true);
    final result = await Navigator.push<ExamFullscreenResult>(
      context,
      cupertinoRoute(
        PdfFullscreenScreen(
          assetPath: pdfPath,
          isRemote: _isRemotePdfPath(pdfPath),
          title: widget.subjectName,
          initialPage: 1,
          examMode: true,
          initialSecondsLeft: _secondsLeft,
          totalDurationSeconds: _bacDuration,
        ),
      ),
    );

    if (!mounted) return;
    if (result == null) {
      setState(() {
        _examStarted = _secondsLeft < _bacDuration;
      });
      return;
    }
    setState(() {
      _secondsLeft = result.secondsLeft;
      _timerFinished = result.isFinished;
    });
  }

  void _resetTimer() {
    setState(() {
      _secondsLeft = _bacDuration;
      _timerFinished = false;
      _examStarted = false;
    });
  }

  Future<void> _confirmStopExam() async {
    AppHaptics.selection();
    final shouldStop = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Oprești rezolvarea?'),
        content: const Text(
          'Vrei să oprești acum rezolvarea subiectului? Progresul timerului va fi resetat.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuă'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oprește'),
          ),
        ],
      ),
    );

    if (shouldStop != true || !mounted) return;
    _resetTimer();
    Navigator.pop(context);
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

  Future<void> _loadPdfAssets() async {
    setState(() {
      _pdfLoading = true;
      _pdfError = null;
    });
    ExamPdfAssets? localAssets;
    try {
      localAssets = await LocalExamPdfService.resolve(
        profile: widget.profileName,
        subject: widget.subjectName,
        year: widget.year,
        session: widget.sessionName,
      );
    } catch (_) {
      localAssets = null;
    }

    final assets = localAssets;
    if (!mounted) return;
    setState(() {
      _pdfAssets = assets;
      _pdfLoading = false;
      _pdfError = assets == null
          ? 'Nu am găsit document asociat pentru această selecție.'
          : null;
    });
  }

  String? get _activePdfAssetPath {
    final assets = _pdfAssets;
    if (assets == null) return null;
    return _showAnswerKey ? assets.answerPdfAsset : assets.subjectPdfAsset;
  }

  String _timerStatusLabel() {
    if (_timerFinished) return 'Finalizat';
    if (_secondsLeft < _bacDuration) return 'În desfășurare';
    return 'Pregătit';
  }

  Future<void> _openPdfFullscreen(String assetPath) async {
    await Navigator.push(
      context,
      cupertinoRoute(
        PdfFullscreenScreen(
          assetPath: assetPath,
          isRemote: _isRemotePdfPath(assetPath),
          title: widget.subjectName,
          initialPage: 1,
        ),
      ),
    );
  }

  bool _isRemotePdfPath(String path) {
    final trimmed = path.trim().toLowerCase();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              titlePadding: const EdgeInsets.fromLTRB(86, 0, 16, 14),
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
                                color: AppColors.green,
                                onPressed: _startTimer,
                                child: Text(
                                  _secondsLeft == _bacDuration
                                      ? 'Start 3h'
                                      : 'Continuă fullscreen',
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
                              color: _examStarted
                                  ? AppColors.red
                                  : AppColors.background,
                              onPressed: _examStarted ? _confirmStopExam : null,
                              child: Text(
                                'Oprește',
                                style: TextStyle(
                                  color: _examStarted
                                      ? Colors.white
                                      : AppColors.tertiaryLabel,
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
                                  setState(() {
                                    _showAnswerKey = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Builder(
                            builder: (context) {
                              if (_pdfLoading) {
                                return const SizedBox(
                                  height: 44,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }
                              if (_pdfError != null) {
                                return Text(
                                  _pdfError!,
                                  style: AppText.subheadStyle,
                                  textAlign: TextAlign.center,
                                );
                              }
                              final assetPath = _activePdfAssetPath;
                              if (assetPath == null ||
                                  assetPath.trim().isEmpty) {
                                return Text(
                                  'Nu există document disponibil pentru această selecție.',
                                  style: AppText.subheadStyle,
                                  textAlign: TextAlign.center,
                                );
                              }
                              return SizedBox(
                                width: double.infinity,
                                child: CupertinoButton(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                  onPressed: () async {
                                    AppHaptics.selection();
                                    await _openPdfFullscreen(assetPath);
                                  },
                                  child: const Text(
                                    'Previzualizare',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                                AppHaptics.selection();
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
                          scrollPadding: const EdgeInsets.only(bottom: 170),
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
                                AppHaptics.selection();
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
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () async {
                        AppHaptics.heavy();
                        final user = AuthService.currentUser;
                        final cleanNotes = _notesController.text.trim();
                        if (user != null) {
                          await FirestoreService.addSession(
                            user,
                            StudySession(
                              subjectName: widget.subjectName,
                              year: widget.year,
                              sessionName: widget.sessionName,
                              durationSeconds: _bacDuration - _secondsLeft,
                              estimatedGrade: _estimatedGrade,
                              notes: cleanNotes,
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
                SizedBox(
                  height:
                      MediaQuery.paddingOf(context).bottom + keyboardInset + 20,
                ),
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

class PdfFullscreenScreen extends StatefulWidget {
  final String assetPath;
  final bool isRemote;
  final String title;
  final int initialPage;
  final bool examMode;
  final int initialSecondsLeft;
  final int totalDurationSeconds;

  const PdfFullscreenScreen({
    super.key,
    required this.assetPath,
    this.isRemote = false,
    required this.title,
    required this.initialPage,
    this.examMode = false,
    this.initialSecondsLeft = 10800,
    this.totalDurationSeconds = 10800,
  });

  @override
  State<PdfFullscreenScreen> createState() => _PdfFullscreenScreenState();
}

class _PdfFullscreenScreenState extends State<PdfFullscreenScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _pageCount = 0;
  Timer? _timer;
  late int _secondsLeft = widget.initialSecondsLeft;

  @override
  void initState() {
    super.initState();
    if (widget.examMode) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress =>
      (widget.totalDurationSeconds - _secondsLeft) /
      widget.totalDurationSeconds;

  Color get _timerColor {
    if (_secondsLeft > 3600) return AppColors.green;
    if (_secondsLeft > 900) return AppColors.orange;
    return AppColors.red;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
          AppHaptics.heavy();
        }
      });
    });
  }

  Future<void> _goToNextPage() async {
    if (!_controller.isReady) return;
    final current = _controller.pageNumber ?? _currentPage;
    final maxPage = _pageCount > 0 ? _pageCount : _controller.pageCount;
    if (current >= maxPage) return;
    await _controller.goToPage(pageNumber: current + 1);
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(
      context,
      ExamFullscreenResult(
        secondsLeft: _secondsLeft,
        isFinished: _secondsLeft == 0,
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'PDF · Pagina $_currentPage${_pageCount > 0 ? '/$_pageCount' : ''}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () {
              _onWillPop();
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Pagina următoare',
              onPressed: _goToNextPage,
              icon: const Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildPdfViewer()),
              if (widget.examMode)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              _formattedTime,
                              style: TextStyle(
                                color: _timerColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(_secondsLeft / 60).ceil()} min',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: _timerProgress.clamp(0, 1),
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _timerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    final params = PdfViewerParams(
      backgroundColor: Colors.black,
      panEnabled: true,
      scaleEnabled: true,
      onViewerReady: (document, controller) {
        if (!mounted) return;
        setState(() {
          _pageCount = controller.pageCount;
          _currentPage = controller.pageNumber ?? widget.initialPage;
        });
      },
      onPageChanged: (pageNumber) {
        if (!mounted || pageNumber == null) return;
        setState(() => _currentPage = pageNumber);
      },
    );

    if (widget.isRemote) {
      return PdfViewer.uri(
        Uri.parse(widget.assetPath),
        controller: _controller,
        initialPageNumber: widget.initialPage,
        params: params,
      );
    }

    return PdfViewer.asset(
      widget.assetPath,
      controller: _controller,
      initialPageNumber: widget.initialPage,
      params: params,
    );
  }
}

class ExamFullscreenResult {
  final int secondsLeft;
  final bool isFinished;

  const ExamFullscreenResult({
    required this.secondsLeft,
    required this.isFinished,
  });
}
