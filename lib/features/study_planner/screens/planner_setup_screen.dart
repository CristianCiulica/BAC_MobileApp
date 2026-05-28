import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../../../src/services/app_settings.dart';
import '../../countdown/screens/set_exam_date_screen.dart';
import '../../countdown/services/countdown_service.dart';
import '../models/study_plan_model.dart';
import '../models/subject_plan_model.dart';
import '../services/study_planner_service.dart';

class PlannerSetupScreen extends StatefulWidget {
  const PlannerSetupScreen({super.key});

  @override
  State<PlannerSetupScreen> createState() => _PlannerSetupScreenState();
}

class _PlannerSetupScreenState extends State<PlannerSetupScreen> {
  static const List<int> _minuteOptions = [30, 60, 90, 120];
  static const List<String> _weekdayLabels = [
    'Lu',
    'Ma',
    'Mi',
    'Jo',
    'Vi',
    'Sâ',
    'Du',
  ];

  late DateTime _examDate;
  int _dailyMinutes = 60;
  final Set<int> _availableDays = <int>{1, 2, 3, 4, 5, 6};
  SubjectLevel _mathLevel = SubjectLevel.medium;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existingPlan = StudyPlannerService.instance.planNotifier.value;
    if (existingPlan != null) {
      _examDate = existingPlan.examDate;
      _dailyMinutes = existingPlan.dailyMinutes;
      _availableDays
        ..clear()
        ..addAll(existingPlan.availableWeekdays);
      final math = existingPlan.subjects.where(
        (item) => item.subject == 'Matematică',
      );
      _mathLevel = math.isEmpty ? SubjectLevel.medium : math.first.level;
    } else {
      _examDate = CountdownService.instance.notifier.value.examDate;
    }
  }

  Future<void> _savePlan() async {
    if (_availableDays.isEmpty) return;
    setState(() => _saving = true);

    final plan = StudyPlanModel(
      examDate: DateTime(_examDate.year, _examDate.month, _examDate.day),
      dailyMinutes: _dailyMinutes,
      availableWeekdays: _availableDays.toList()..sort(),
      subjects: <SubjectPlanModel>[
        SubjectPlanModel(subject: 'Matematică', level: _mathLevel),
      ],
      generatedAt: DateTime.now(),
    );

    await StudyPlannerService.instance.savePlanAndGenerate(plan);
    AppHaptics.medium();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _pickExamDate() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const SetExamDateScreen()),
    );
    if (!mounted) return;
    setState(() {
      _examDate = CountdownService.instance.notifier.value.examDate;
    });
  }

  String _formatDateRo(DateTime date) {
    const months = <String>[
      'ianuarie',
      'februarie',
      'martie',
      'aprilie',
      'mai',
      'iunie',
      'iulie',
      'august',
      'septembrie',
      'octombrie',
      'noiembrie',
      'decembrie',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Configurează planner', titleSize: 25),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardGroup(
                  header: 'Data examenului',
                  children: [
                    CardRow(
                      leading: const TintedIcon(
                        icon: CupertinoIcons.calendar,
                        color: AppColors.indigo,
                      ),
                      title: _formatDateRo(_examDate),
                      subtitle: 'Planul se generează până la această dată',
                      onTap: _pickExamDate,
                    ),
                  ],
                ),
                CardGroup(
                  header: 'Nivel Matematică',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: Column(
                        children: [
                          _LevelOption(
                            title: 'Începător',
                            subtitle: 'Nota 1–5 · fundamentele pe barem',
                            selected: _mathLevel == SubjectLevel.weak,
                            onTap: () =>
                                setState(() => _mathLevel = SubjectLevel.weak),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          _LevelOption(
                            title: 'Mediu',
                            subtitle: 'Nota 5–8 · variante și exerciții',
                            selected: _mathLevel == SubjectLevel.medium,
                            onTap: () => setState(
                              () => _mathLevel = SubjectLevel.medium,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          _LevelOption(
                            title: 'Avansat',
                            subtitle: 'Nota 8–10 · simulări și finisaje',
                            selected: _mathLevel == SubjectLevel.good,
                            onTap: () =>
                                setState(() => _mathLevel = SubjectLevel.good),
                          ),
                          if (_mathLevel == SubjectLevel.weak) ...[
                            const SizedBox(height: AppSpacing.x3),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.x3),
                              decoration: BoxDecoration(
                                color: AppColors.tint(AppColors.blue),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                'Focus începător: matrici, legi de compoziție, polinoame (punctele a și b), primele 4 exerciții de la Subiectul I, derivata punctul a și integrala punctul a.',
                                style: AppText.subheadStyle.copyWith(
                                  color: AppColors.label,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                CardGroup(
                  header: 'Timp de studiu pe zi',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: Row(
                        children: [
                          for (final minutes in _minuteOptions) ...[
                            Expanded(
                              child: _MinuteChip(
                                minutes: minutes,
                                selected: _dailyMinutes == minutes,
                                onTap: () {
                                  AppHaptics.selection();
                                  setState(() => _dailyMinutes = minutes);
                                },
                              ),
                            ),
                            if (minutes != _minuteOptions.last)
                              const SizedBox(width: AppSpacing.x2),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                CardGroup(
                  header: 'Zile disponibile',
                  footer: _availableDays.isEmpty
                      ? 'Selectează cel puțin o zi de studiu.'
                      : 'Weekendul primește automat minute bonus.',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int day = 1; day <= 7; day++)
                            _DayChip(
                              label: _weekdayLabels[day - 1],
                              selected: _availableDays.contains(day),
                              onTap: () {
                                AppHaptics.selection();
                                setState(() {
                                  if (_availableDays.contains(day)) {
                                    _availableDays.remove(day);
                                  } else {
                                    _availableDays.add(day);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x6,
                    AppSpacing.page,
                    AppSpacing.x10,
                  ),
                  child: AppButton(
                    label: 'Generează planul',
                    icon: CupertinoIcons.sparkles,
                    loading: _saving,
                    onPressed: _saving || _availableDays.isEmpty
                        ? null
                        : _savePlan,
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

class _LevelOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LevelOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.tint(AppColors.blue) : AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.blue : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.headlineStyle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.subheadStyle),
                ],
              ),
            ),
            Icon(
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: selected ? AppColors.blue : AppColors.tertiaryLabel,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _MinuteChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  const _MinuteChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            '$minutes min',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? CupertinoColors.white : AppColors.secondLabel,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : AppColors.fill,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? CupertinoColors.white : AppColors.secondLabel,
            ),
          ),
        ),
      ),
    );
  }
}
