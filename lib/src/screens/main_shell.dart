import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../features/countdown/screens/set_exam_date_screen.dart';
import '../../features/countdown/widgets/countdown_card.dart';
import '../../features/gamification/services/gamification_service.dart';
import '../models/app_data.dart';
import '../navigation.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_exam_pdf_service.dart';
import '../widgets/common.dart';
import 'account_screens.dart';
import 'login_screen.dart';

/// Bottom inset that keeps scrollable content clear of the floating tab bar.
const double kTabBarClearance = 118;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<UserProfileData>? _profileSubscription;
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
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _selectedTabIndex, children: tabs),
          if (_selectedTabIndex == 0) _buildSideMenuOverlay(context),
        ],
      ),
      bottomNavigationBar: _GlassTabBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          AppHaptics.selection();
          setState(() {
            _selectedTabIndex = index;
            _isMenuOpen = false;
          });
        },
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
    final menuWidth = MediaQuery.sizeOf(context).width * 0.84;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !_isMenuOpen,
          child: AnimatedOpacity(
            duration: AppDurations.base,
            curve: AppDurations.ease,
            opacity: _isMenuOpen ? 1 : 0,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.32)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSlide(
            duration: AppDurations.base,
            curve: AppDurations.ease,
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

/// Floating Liquid Glass tab bar.
class _GlassTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassTabBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (CupertinoIcons.house_fill, CupertinoIcons.house, 'Acasă'),
    (CupertinoIcons.shuffle, CupertinoIcons.shuffle, 'Random'),
    (
      CupertinoIcons.person_crop_circle_fill,
      CupertinoIcons.person_crop_circle,
      'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sit the floating bar low, dipping slightly into the home-indicator zone
    // so it reads as anchored to the bottom edge on both themes.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomGap = bottomInset > 0 ? (bottomInset - 16).clamp(4.0, 24.0) : 8.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.x6, 0, AppSpacing.x6, bottomGap),
      child: GlassPanel(
        radius: AppRadius.xl,
        shadows: AppShadows.floating,
        showSheen: false,
        color: AppColors.surface.withValues(
          alpha: AppColors.isDark ? 0.55 : 0.75,
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            for (int i = 0; i < _items.length; i++)
              Expanded(
                child: _TabItem(
                  activeIcon: _items[i].$1,
                  icon: _items[i].$2,
                  label: _items[i].$3,
                  selected: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.base,
        curve: AppDurations.ease,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.tint(AppColors.blue) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 23,
              color: selected ? AppColors.blue : AppColors.secondLabel,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.blue : AppColors.secondLabel,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
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

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(AppRadius.xl),
        bottomRight: Radius.circular(AppRadius.xl),
      ),
      child: Material(
        color: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x6,
                  AppSpacing.x5,
                  AppSpacing.x5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.tint(AppColors.blue),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: AppColors.blue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppText.titleStyle.copyWith(fontSize: 19),
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
                                      ? (user.email ?? 'Profil BacPro')
                                      : '${profile.school} · ${profile.selectedProfile}',
                                  style: AppText.subheadStyle,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          const SizedBox(height: 6),
                          const PillBadge('Activ', color: AppColors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x4,
                  0,
                  AppSpacing.x4,
                  AppSpacing.x2,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3,
                    vertical: AppSpacing.x4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
                                          : progress.averageGrade
                                                .toStringAsFixed(1),
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
              const SizedBox(height: AppSpacing.x2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                  ),
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
                          icon: CupertinoIcons.chart_bar_square,
                          label: 'Progres & Statistici',
                          color: AppColors.indigo,
                          onTap: () => _push(context, const ProgressScreen()),
                        ),
                        _DrawerItem(
                          icon: CupertinoIcons.clock,
                          label: 'Istoric sesiuni',
                          color: AppColors.teal,
                          onTap: () => _push(context, const HistoryScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    _DrawerSection(
                      children: [
                        _DrawerItem(
                          icon: CupertinoIcons.bell,
                          label: 'Notificări',
                          color: AppColors.red,
                          onTap: () => _push(
                            context,
                            const NotificationsSettingsScreen(),
                          ),
                        ),
                        _DrawerItem(
                          icon: CupertinoIcons.chat_bubble_2,
                          label: 'Mesaje dezvoltator',
                          color: AppColors.purple,
                          onTap: () =>
                              _push(context, const DeveloperMessagesScreen()),
                        ),
                        _DrawerItem(
                          icon: CupertinoIcons.gear,
                          label: 'Setări',
                          color: AppColors.secondLabel,
                          onTap: () => _push(context, const SettingsScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    _DrawerSection(
                      children: [
                        _DrawerItem(
                          icon: CupertinoIcons.star,
                          label: 'Evaluează aplicația',
                          color: AppColors.orange,
                          onTap: () => _push(context, const AppRatingScreen()),
                        ),
                        _DrawerItem(
                          icon: CupertinoIcons.info_circle,
                          label: 'Despre BacPro',
                          color: AppColors.blue,
                          onTap: () => _push(context, const AboutScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
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
                    const SizedBox(height: AppSpacing.x5),
                  ],
                ),
              ),
            ],
          ),
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
      height: 38,
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
        Text(value, style: AppText.statStyle.copyWith(fontSize: 21)),
        const SizedBox(height: 2),
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
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 0.5,
                  indent: 56,
                  color: AppColors.separator,
                  thickness: 0.5,
                ),
            ],
          ],
        ),
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
        duration: AppDurations.fast,
        color: _pressed
            ? AppColors.separator.withValues(alpha: 0.5)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            TintedIcon(icon: widget.icon, color: widget.color, size: 34),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                widget.label,
                style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
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
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          glassSliverBar(context, title: 'Evaluează aplicația', titleSize: 26),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    0,
                  ),
                  child: FloatingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cât de utilă este BacPro?',
                          style: AppText.headlineStyle,
                        ),
                        const SizedBox(height: AppSpacing.x4),
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
                                padding: const EdgeInsets.only(right: 10),
                                child: AnimatedScale(
                                  duration: AppDurations.base,
                                  curve: AppDurations.spring,
                                  scale: selected ? 1.0 : 0.88,
                                  child: Icon(
                                    selected
                                        ? CupertinoIcons.star_fill
                                        : CupertinoIcons.star,
                                    color: selected
                                        ? AppColors.orange
                                        : AppColors.tertiaryLabel,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.x5),
                        AppInput(
                          controller: _notesController,
                          hint: 'Ce ți-ar plăcea să îmbunătățim în continuare?',
                          maxLines: 4,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AppButton(
                          label: 'Trimite feedback',
                          onPressed: _submitFeedback,
                        ),
                      ],
                    ),
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
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          glassSliverBar(context, title: 'Mesaje dezvoltator', titleSize: 26),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    0,
                  ),
                  child: FloatingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trimite o sugestie', style: AppText.headlineStyle),
                        const SizedBox(height: 4),
                        Text(
                          'Scrie ce ai vrea să îmbunătățim în BacPro.',
                          style: AppText.subheadStyle,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AppInput(
                          controller: _messageController,
                          hint: 'Ex: aș vrea filtre pe ani, profil...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AppButton(
                          label: 'Trimite mesaj',
                          loading: _sending,
                          onPressed: _sending ? null : _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
                CardGroup(
                  header: 'Istoric mesaje',
                  children: [
                    if (user == null)
                      const EmptyState(
                        icon: CupertinoIcons.chat_bubble_2,
                        title: 'Neconectat',
                        message:
                            'Conectează-te pentru a vedea istoricul de mesaje.',
                      )
                    else
                      StreamBuilder<List<DeveloperMessage>>(
                        stream: FirestoreService.watchDeveloperMessages(user),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(AppSpacing.x5),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }

                          final messages = snapshot.data ?? const [];
                          if (messages.isEmpty) {
                            return const EmptyState(
                              icon: CupertinoIcons.paperplane,
                              title: 'Niciun mesaj încă',
                              message:
                                  'Sugestiile trimise vor apărea aici.',
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.x4),
                            child: Column(
                              children: messages.map((message) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.x3,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.x4),
                                  decoration: BoxDecoration(
                                    color: AppColors.fill,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
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
                const SizedBox(height: AppSpacing.x10),
              ],
            ),
          ),
        ],
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
        glassSliverBar(
          context,
          title: 'BacPro',
          showBack: false,
          leading: Center(
            child: Pressable(
              onTap: () {
                AppHaptics.medium();
                onMenuTap();
              },
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(left: AppSpacing.x3),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.separator, width: 0.5),
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(
                  CupertinoIcons.line_horizontal_3,
                  color: AppColors.blue,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.x5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: _HomeOverviewPanel(),
              ),
              const SizedBox(height: AppSpacing.x4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Pressable(
                  onTap: () => Navigator.push(
                    context,
                    cupertinoRoute(const SetExamDateScreen()),
                  ),
                  child: const CountdownCard(),
                ),
              ),
              const _NextLevelSection(),
              const _SelectedProfileSubjects(),
              const SizedBox(height: kTabBarClearance),
            ],
          ),
        ),
      ],
    );
  }
}

/// Home section listing only the subjects that belong to the user's selected
/// BAC profile — nothing outside the programme shows up here.
class _SelectedProfileSubjects extends StatelessWidget {
  const _SelectedProfileSubjects();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<UserProfileData>(
      stream: FirestoreService.watchProfile(user),
      builder: (context, snapshot) {
        final profile = profileByName(snapshot.data?.selectedProfile);
        return CardGroup(
          header: 'Materiile tale · ${profile.name}',
          footer:
              'Vezi doar materiile din profilul tău. Îl poți schimba oricând.',
          children: [
            for (final subject in profile.subjects)
              CardRow(
                leading: TintedIcon(
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
            CardRow(
              leading: TintedIcon(
                icon: CupertinoIcons.arrow_2_squarepath,
                color: AppColors.secondLabel,
              ),
              title: 'Schimbă profilul',
              onTap: () => Navigator.push(
                context,
                cupertinoRoute(const UserProfileScreen()),
              ),
            ),
          ],
        );
      },
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
  Profile _profile = appProfiles.first;

  @override
  void initState() {
    super.initState();
    _generateRandomPick();
  }

  /// Keeps the random pool locked to the user's chosen profile so only
  /// subjects from their programme can appear.
  void _syncProfile(String? selectedProfileName) {
    final resolved = profileByName(selectedProfileName);
    if (resolved.name == _profile.name) return;
    _profile = resolved;
    // Re-roll within the new profile after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _generateRandomPick();
    });
  }

  void _generateRandomPick() {
    if (_profile.subjects.isEmpty ||
        examYears.isEmpty ||
        examSessions.isEmpty) {
      return;
    }

    final subject =
        _profile.subjects[_random.nextInt(_profile.subjects.length)];
    final year = examYears[_random.nextInt(examYears.length)];
    final session = examSessions[_random.nextInt(examSessions.length)];

    setState(() {
      _pick = _RandomSubjectPick(
        profileName: _profile.name,
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
    final user = AuthService.currentUser;
    if (user != null) {
      return StreamBuilder<UserProfileData>(
        stream: FirestoreService.watchProfile(user),
        builder: (context, snapshot) {
          _syncProfile(snapshot.data?.selectedProfile);
          return _buildContent(context);
        },
      );
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final pick = _pick;

    return CustomScrollView(
      slivers: [
        glassSliverBar(context, title: 'Subiect Random', showBack: false),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.x5,
              AppSpacing.page,
              AppSpacing.x5,
            ),
            child: Column(
              children: [
                FloatingCard(
                  radius: AppRadius.xl,
                  child: pick == null
                      ? const Center(child: CupertinoActivityIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TintedIcon(
                                  icon: pick.subjectIcon,
                                  color: pick.subjectColor,
                                  size: 54,
                                ),
                                const SizedBox(width: AppSpacing.x4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pick.subjectName,
                                        style: AppText.titleStyle,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${pick.profileName} · ${pick.year}',
                                        style: AppText.subheadStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.x4),
                            PillBadge(
                              pick.sessionName,
                              color: pick.sessionColor,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.x5),
                AppButton(
                  label: 'Generează alt subiect',
                  icon: CupertinoIcons.shuffle,
                  style: AppButtonStyle.secondary,
                  onPressed: () {
                    AppHaptics.selection();
                    _generateRandomPick();
                  },
                ),
                const SizedBox(height: AppSpacing.x3),
                AppButton(
                  label: 'Începe subiectul',
                  icon: CupertinoIcons.play_fill,
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
        glassSliverBar(context, title: 'Profil', showBack: false),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.x5,
                  AppSpacing.page,
                  0,
                ),
                child: FloatingCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.asset(
                          'assets/images/login_hero.png',
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x4),
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
                              user?.email ?? 'Cont BacPro',
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
              CardGroup(
                header: 'Cont',
                children: [
                  CardRow(
                    leading: const TintedIcon(
                      icon: CupertinoIcons.person_crop_circle,
                      color: AppColors.blue,
                    ),
                    title: 'Profil utilizator',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const UserProfileScreen()),
                    ),
                  ),
                  CardRow(
                    leading: const TintedIcon(
                      icon: CupertinoIcons.gear,
                      color: AppColors.indigo,
                    ),
                    title: 'Setări',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const SettingsScreen()),
                    ),
                  ),
                  CardRow(
                    leading: const TintedIcon(
                      icon: CupertinoIcons.info_circle,
                      color: AppColors.teal,
                    ),
                    title: 'Despre BacPro',
                    onTap: () => Navigator.push(
                      context,
                      cupertinoRoute(const AboutScreen()),
                    ),
                  ),
                  CardRow(
                    leading: const TintedIcon(
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
              const SizedBox(height: kTabBarClearance),
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

/// Dashboard overview — quiet white card with a greeting and tinted metrics.
class _HomeOverviewPanel extends StatelessWidget {
  const _HomeOverviewPanel();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final firstName = AuthService.displayName.split(' ').first;

    return StreamBuilder<List<StudySession>>(
      stream: FirestoreService.watchSessions(user),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <StudySession>[];
        final progress = UserProgress.fromSessions(sessions);
        final latestGrade = sessions.isEmpty
            ? '–'
            : sessions.first.estimatedGrade.toStringAsFixed(1);

        // Liquid Glass hero: frosted metric chips floating over a soft
        // gradient, blurring the colour behind them.
        return Container(
          padding: const EdgeInsets.all(AppSpacing.x5),
          decoration: BoxDecoration(
            gradient: AppGradients.hero,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salut, $firstName',
                style: const TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sessions.isEmpty
                    ? 'Începe primul subiect și îți construim progresul automat.'
                    : 'Ultima sesiune: ${sessions.first.subjectName} · ${sessions.first.year}',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                children: [
                  Expanded(
                    child: _GlassMetric(
                      icon: CupertinoIcons.doc_checkmark,
                      label: 'Subiecte',
                      value: '${progress.solvedCount}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: _GlassMetric(
                      icon: CupertinoIcons.chart_bar,
                      label: 'Ultima notă',
                      value: latestGrade,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: _GlassMetric(
                      icon: CupertinoIcons.flame,
                      label: 'Streak',
                      value: '${progress.streakDays}z',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Frosted metric chip used on the dashboard hero — a Liquid Glass surface.
class _GlassMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GlassMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x3,
            vertical: AppSpacing.x3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: '.SF Pro Display',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daily study section — planner shortcuts with live task progress.
class _NextLevelSection extends StatelessWidget {
  const _NextLevelSection();

  @override
  Widget build(BuildContext context) {
    return CardGroup(
      header: 'Bac NextLevel',
      footer:
          'Resurse recomandate pentru progres rapid: PDF-uri, cărți și video-uri utile.',
      children: [
        CardRow(
          leading: const TintedIcon(
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
        CardRow(
          leading: const TintedIcon(
            icon: CupertinoIcons.book,
            color: AppColors.orange,
          ),
          title: 'Cărți recomandate',
          subtitle: 'Ce merită cumpărat pentru pregătire',
          onTap: () => Navigator.push(
            context,
            cupertinoRoute(
              const ResourceCategoryScreen(
                title: 'Cărți recomandate',
                icon: CupertinoIcons.book,
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
        CardRow(
          leading: const TintedIcon(
            icon: CupertinoIcons.play_rectangle,
            color: AppColors.teal,
          ),
          title: 'Video-uri explicative',
          subtitle: 'Playlist-uri și recapitulări pe capitole',
          onTap: () => Navigator.push(
            context,
            cupertinoRoute(
              const ResourceCategoryScreen(
                title: 'Video-uri explicative',
                icon: CupertinoIcons.play_rectangle,
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
          glassSliverBar(context, title: title, titleSize: 26),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    0,
                  ),
                  child: FloatingCard(
                    child: Row(
                      children: [
                        TintedIcon(icon: icon, color: color, size: 46),
                        const SizedBox(width: AppSpacing.x4),
                        Expanded(
                          child: Text(
                            'Poți adăuga materiale local în assets/resources/ și le centralizăm aici.',
                            style: AppText.subheadStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CardGroup(
                  header: 'Recomandări',
                  children: [
                    for (final item in items)
                      CardRow(
                        leading: TintedIcon(
                          icon: CupertinoIcons.checkmark_seal,
                          color: color,
                        ),
                        title: item.title,
                        subtitle: item.description,
                        onTap: () {},
                      ),
                  ],
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
          glassSliverBar(context, title: profile.name, titleSize: 26),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.x5),
                    decoration: BoxDecoration(
                      gradient: AppGradients.accent(profile.accentColor),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            profile.icon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x4),
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
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CardGroup(
                  header: 'Materii',
                  children: [
                    for (final subject in profile.subjects)
                      CardRow(
                        leading: TintedIcon(
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
                const SizedBox(height: AppSpacing.x10),
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
          glassSliverBar(context, title: '', largeTitle: false),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.x3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: SubjectTitleCard(
                    title: subjectName,
                    accentColor: subjectColor,
                  ),
                ),
                CardGroup(
                  header: 'Alege anul',
                  footer: 'Subiectele sunt disponibile din 2020.',
                  children: [
                    for (final year in examYears)
                      CardRow(
                        leading: const TintedIcon(
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
                const SizedBox(height: AppSpacing.x10),
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
          glassSliverBar(context, title: '', largeTitle: false),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.x3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: SubjectTitleCard(
                    title: subjectName,
                    subtitle: 'Anul $year',
                    accentColor: subjectColor,
                  ),
                ),
                CardGroup(
                  header: 'Alege sesiunea',
                  children: [
                    for (final session in examSessions)
                      CardRow(
                        leading: TintedIcon(
                          icon: session.icon,
                          color: session.color,
                        ),
                        title: session.name,
                        subtitle: session.desc,
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
                const SizedBox(height: AppSpacing.x10),
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
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Subiect indisponibil'),
          content: const Text(
            'Nu am găsit acest subiect pentru selecția curentă. Încearcă alt an sau altă materie.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Închide'),
            ),
          ],
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
          glassSliverBar(context, title: '', largeTitle: false),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.x3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: SubjectTitleCard(
                    title: widget.subjectName,
                    subtitle: '${widget.year} · ${widget.sessionName}',
                    accentColor: widget.subjectColor,
                  ),
                ),
                // Timer examen
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x4,
                    AppSpacing.page,
                    0,
                  ),
                  child: FloatingCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            TintedIcon(
                              icon: CupertinoIcons.timer,
                              color: _timerColor,
                              size: 36,
                            ),
                            const SizedBox(width: AppSpacing.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Timer examen',
                                    style: AppText.captionStyle,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    _formattedTime,
                                    style: TextStyle(
                                      fontFamily: '.SF Pro Display',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                      fontFeatures: const [
                                        ui.FontFeature.tabularFigures(),
                                      ],
                                      color: _timerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PillBadge(_timerStatusLabel(), color: _timerColor),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        SoftProgressBar(
                          value: _timerProgress,
                          color: _timerColor,
                        ),
                        const SizedBox(height: AppSpacing.x2),
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
                        const SizedBox(height: AppSpacing.x4),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: _secondsLeft == _bacDuration
                                    ? 'Start 3h'
                                    : 'Continuă fullscreen',
                                icon: CupertinoIcons.play_fill,
                                accent: AppColors.green,
                                height: 48,
                                onPressed: _startTimer,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x3),
                            AppButton(
                              label: 'Oprește',
                              style: AppButtonStyle.destructive,
                              expanded: false,
                              height: 48,
                              onPressed: _examStarted ? _confirmStopExam : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Documente oficiale
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x4,
                    AppSpacing.page,
                    0,
                  ),
                  child: FloatingCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.x4,
                            AppSpacing.x4,
                            AppSpacing.x4,
                            AppSpacing.x3,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Documente oficiale',
                                      style: AppText.headlineStyle,
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
                                backgroundColor: AppColors.fill,
                                thumbColor: AppColors.surface,
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
                        Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.separator,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.x4),
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
                              return AppButton(
                                label: 'Previzualizare',
                                icon: CupertinoIcons.doc_text_viewfinder,
                                style: AppButtonStyle.secondary,
                                height: 48,
                                onPressed: () async {
                                  AppHaptics.selection();
                                  await _openPdfFullscreen(assetPath);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nota estimată
                CardGroup(
                  header: 'Nota estimată',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Autoevaluare', style: AppText.bodyStyle),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tint(
                                    _gradeColor(_estimatedGrade),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  _estimatedGrade.toStringAsFixed(1),
                                  style: AppText.statStyle.copyWith(
                                    fontSize: 20,
                                    color: _gradeColor(_estimatedGrade),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 5,
                              activeTrackColor: _gradeColor(_estimatedGrade),
                              inactiveTrackColor: AppColors.fill,
                              thumbColor: Colors.white,
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
                // Note personale
                CardGroup(
                  header: 'Note personale',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _editingNotes = true),
                            child: AppInput(
                              controller: _notesController,
                              hint:
                                  'Adaugă observații, formule de reținut, puncte slabe...',
                              maxLines: 5,
                              scrollPadding: const EdgeInsets.only(
                                bottom: 170,
                              ),
                            ),
                          ),
                          if (_editingNotes) ...[
                            const SizedBox(height: AppSpacing.x3),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppButton(
                                label: 'Salvează',
                                style: AppButtonStyle.secondary,
                                expanded: false,
                                height: 40,
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
                  ],
                ),
                const SizedBox(height: AppSpacing.x6),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.x3,
                  ),
                  child: AppButton(
                    label: 'Marchează ca rezolvat',
                    icon: CupertinoIcons.checkmark_alt,
                    height: 56,
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
                      await GamificationService.instance
                          .recordStudySessionCompleted(
                            completedAt: DateTime.now(),
                            isSimulation: widget.sessionName
                                .toLowerCase()
                                .contains('simulare'),
                          );
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
            'Pagina $_currentPage${_pageCount > 0 ? ' din $_pageCount' : ''}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white),
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
                  left: AppSpacing.x4,
                  right: AppSpacing.x4,
                  top: AppSpacing.x3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x4,
                          vertical: AppSpacing.x3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
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
                                    fontFeatures: const [
                                      ui.FontFeature.tabularFigures(),
                                    ],
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
                            const SizedBox(height: AppSpacing.x2),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
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
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(
                color: Colors.white,
                radius: 14,
              ),
              const SizedBox(height: AppSpacing.x3),
              Text(
                totalBytes != null && totalBytes > 0
                    ? 'Se încarcă ${(bytesDownloaded / totalBytes * 100).clamp(0, 100).toStringAsFixed(0)}%'
                    : 'Se încarcă subiectul...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      },
      errorBannerBuilder: (context, error, stackTrace, documentRef) {
        return _PdfErrorView(onBack: _onWillPop);
      },
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

/// Shown inside the fullscreen viewer when a PDF can't be loaded (offline,
/// missing document, etc.) — always offers a clear way back.
class _PdfErrorView extends StatelessWidget {
  final VoidCallback onBack;

  const _PdfErrorView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                CupertinoIcons.wifi_slash,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            const Text(
              'Subiectul nu a putut fi încărcat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            const Text(
              'Verifică conexiunea la internet și încearcă din nou. '
              'Documentul poate fi indisponibil momentan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: AppSpacing.x6),
            CupertinoButton(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              onPressed: onBack,
              child: const Text(
                'Înapoi',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
