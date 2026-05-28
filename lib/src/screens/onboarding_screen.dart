import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/countdown/services/countdown_service.dart';
import '../design/ui.dart';
import '../models/app_data.dart';
import '../services/app_settings.dart';
import '../services/firestore_service.dart';

/// First-launch welcome: pick a profile, self-evaluate, see a grade-gain
/// estimate, then enter the app.
class OnboardingScreen extends StatefulWidget {
  final User user;

  const OnboardingScreen({super.key, required this.user});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  static const int _pageCount = 4;

  int _page = 0;
  String? _selectedProfile;
  double _currentGrade = 6.0;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 1 && _selectedProfile == null) return;
    if (_page >= _pageCount - 1) {
      _finish();
      return;
    }
    AppHaptics.selection();
    _controller.nextPage(
      duration: AppDurations.base,
      curve: AppDurations.ease,
    );
  }

  void _back() {
    if (_page == 0) return;
    AppHaptics.selection();
    _controller.previousPage(
      duration: AppDurations.base,
      curve: AppDurations.ease,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    AppHaptics.heavy();
    try {
      await FirestoreService.completeOnboarding(
        user: widget.user,
        selectedProfile: _selectedProfile ?? appProfiles.first.name,
        currentGrade: _currentGrade,
      );
      // The auth/profile stream in app.dart routes to MainShell once
      // onboardingCompleted flips to true.
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Points we'd aim for at this level, before capping to what's left to 10.
  double get _desiredGain =>
      _currentGrade >= 8 ? 2.0 : (_currentGrade >= 6 ? 2.5 : 3.0);

  // Never promise more than the headroom to a perfect 10.
  double get _gain {
    final headroom = 10.0 - _currentGrade;
    final capped = headroom < _desiredGain ? headroom : _desiredGain;
    return capped < 0 ? 0 : capped;
  }

  double get _targetGrade => (_currentGrade + _gain).clamp(1.0, 10.0);
  int get _weeksNeeded =>
      _currentGrade < 5 ? 12 : (_currentGrade < 7 ? 9 : 6);

  bool get _canAdvance => !(_page == 1 && _selectedProfile == null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(page: _page, total: _pageCount, onBack: _back),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _WelcomePage(),
                  _ProfilePage(
                    selected: _selectedProfile,
                    onSelect: (name) {
                      AppHaptics.selection();
                      setState(() => _selectedProfile = name);
                    },
                  ),
                  _GradePage(
                    grade: _currentGrade,
                    onChanged: (v) => setState(() => _currentGrade = v),
                  ),
                  _EstimatePage(
                    currentGrade: _currentGrade,
                    targetGrade: _targetGrade,
                    gain: _gain,
                    weeksNeeded: _weeksNeeded,
                    profileName: _selectedProfile ?? appProfiles.first.name,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.x3,
                AppSpacing.page,
                AppSpacing.x5,
              ),
              child: AppButton(
                label: _page == _pageCount - 1
                    ? 'Intră în BacPro'
                    : 'Continuă',
                icon: _page == _pageCount - 1
                    ? CupertinoIcons.checkmark_alt
                    : null,
                loading: _saving,
                onPressed: _canAdvance && !_saving ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int page;
  final int total;
  final VoidCallback onBack;

  const _Header({required this.page, required this.total, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x3,
        AppSpacing.x4,
        AppSpacing.x2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: page > 0
                ? GlassBackButton(onTap: onBack)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < total; i++)
                  AnimatedContainer(
                    duration: AppDurations.base,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i <= page
                          ? AppColors.blue
                          : AppColors.fillSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.floating,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Image.asset(
                'assets/images/login_hero.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
          Text(
            'Bine ai venit în BacPro',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Îți pregătim în câțiva pași un parcurs pe măsura profilului și '
            'nivelului tău. Durează mai puțin de un minut.',
            textAlign: TextAlign.center,
            style: AppText.subheadStyle.copyWith(fontSize: 15, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _ProfilePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.x3,
        AppSpacing.page,
        AppSpacing.x5,
      ),
      children: [
        Text(
          'Ce profil ai?',
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Îți arătăm doar materiile din programa ta.',
          style: AppText.subheadStyle,
        ),
        const SizedBox(height: AppSpacing.x4),
        for (final profile in appProfiles) ...[
          _ProfileOption(
            profile: profile,
            selected: selected == profile.name,
            onTap: () => onSelect(profile.name),
          ),
          const SizedBox(height: AppSpacing.x3),
        ],
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final Profile profile;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.x4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.separator,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            TintedIcon(icon: profile.icon, color: profile.accentColor),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: AppText.headlineStyle),
                  const SizedBox(height: 2),
                  Text(
                    profile.description,
                    style: AppText.subheadStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Icon(
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: selected ? AppColors.blue : AppColors.tertiaryLabel,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradePage extends StatelessWidget {
  final double grade;
  final ValueChanged<double> onChanged;

  const _GradePage({required this.grade, required this.onChanged});

  Color get _color =>
      grade >= 8.5 ? AppColors.green : (grade >= 5 ? AppColors.orange : AppColors.red);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.x3,
        AppSpacing.page,
        AppSpacing.x5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce notă ai lua dacă ai da bacul mâine?',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimează media pe care ai obține-o la Bacalaureat acum. O folosim pentru un plan realist.',
            style: AppText.subheadStyle,
          ),
          const SizedBox(height: AppSpacing.x6),
          Center(
            child: Text(
              grade.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 72,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
                color: _color,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: _color,
              inactiveTrackColor: AppColors.fill,
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: grade,
              min: 1,
              max: 10,
              divisions: 18,
              onChanged: (v) {
                AppHaptics.selection();
                onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: AppText.captionStyle),
              Text('10', style: AppText.captionStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstimatePage extends StatelessWidget {
  final double currentGrade;
  final double targetGrade;
  final double gain;
  final int weeksNeeded;
  final String profileName;

  const _EstimatePage({
    required this.currentGrade,
    required this.targetGrade,
    required this.gain,
    required this.weeksNeeded,
    required this.profileName,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = CountdownService.instance.notifier.value.daysRemaining;
    final weeksLeft = (daysLeft / 7).ceil();
    final enoughTime = weeksLeft >= weeksNeeded;
    final nearMax = gain < 0.75;
    final gainLabel = gain.toStringAsFixed(gain % 1 == 0 ? 0 : 1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.x3,
        AppSpacing.page,
        AppSpacing.x5,
      ),
      children: [
        Text(
          'Planul tău',
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 4),
        Text('Profil $profileName', style: AppText.subheadStyle),
        const SizedBox(height: AppSpacing.x5),
        FloatingCard(
          radius: AppRadius.xl,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _GradePill(
                    label: 'Acum',
                    value: currentGrade.toStringAsFixed(1),
                    color: AppColors.secondLabel,
                  ),
                  Icon(
                    CupertinoIcons.arrow_right,
                    color: AppColors.tertiaryLabel,
                    size: 24,
                  ),
                  _GradePill(
                    label: 'Țintă',
                    value: targetGrade.toStringAsFixed(1),
                    color: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.x4),
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.green),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_up_right_circle_fill,
                          color: AppColors.green,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.x2),
                        Text(
                          nearMax
                              ? 'Aproape de maxim'
                              : '+$gainLabel puncte posibile',
                          style: AppText.headlineStyle.copyWith(
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      nearMax
                          ? 'Ești deja aproape de nota maximă. Cu recapitulări '
                                'constante îți poți menține și consolida media.'
                          : 'Dacă lucrezi constant ~30–45 min pe zi, îți poți '
                                'crește media cu $gainLabel puncte în aproximativ '
                                '$weeksNeeded săptămâni.',
                      style: AppText.subheadStyle.copyWith(
                        color: AppColors.label,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        FloatingCard(
          padding: const EdgeInsets.all(AppSpacing.x4),
          radius: AppRadius.md,
          child: Row(
            children: [
              TintedIcon(
                icon: enoughTime
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.bolt_fill,
                color: enoughTime ? AppColors.blue : AppColors.orange,
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  enoughTime
                      ? 'Ai destul timp până la examen ($weeksLeft săptămâni). Începem?'
                      : 'Mai sunt $weeksLeft săptămâni. Cu un ritm intensiv, tot poți crește semnificativ nota.',
                  style: AppText.subheadStyle.copyWith(color: AppColors.label),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GradePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _GradePill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.captionStyle),
        const SizedBox(height: AppSpacing.x2),
        Text(
          value,
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: color,
          ),
        ),
      ],
    );
  }
}
