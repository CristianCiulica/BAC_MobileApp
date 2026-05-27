import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../src/models/app_data.dart';
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
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Setup Study Planner'),
        previousPageTitle: 'Înapoi',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saving ? null : _savePlan,
          child: _saving
              ? const CupertinoActivityIndicator()
              : const Text('Generează'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _sectionCard(
              title: 'Nivel Matematică',
              child: Column(
                children: [
                  _MathLevelCard(
                    title: 'Începător',
                    subtitle: 'Nota 1-5',
                    selected: _mathLevel == SubjectLevel.weak,
                    onTap: () => setState(() => _mathLevel = SubjectLevel.weak),
                  ),
                  const SizedBox(height: 10),
                  _MathLevelCard(
                    title: 'Mediu',
                    subtitle: 'Nota 5-8',
                    selected: _mathLevel == SubjectLevel.medium,
                    onTap: () =>
                        setState(() => _mathLevel = SubjectLevel.medium),
                  ),
                  const SizedBox(height: 10),
                  _MathLevelCard(
                    title: 'Avansat',
                    subtitle: 'Nota 8-10',
                    selected: _mathLevel == SubjectLevel.good,
                    onTap: () => setState(() => _mathLevel = SubjectLevel.good),
                  ),
                  if (_mathLevel == SubjectLevel.weak) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue.withAlpha(70)),
                      ),
                      child: Text(
                        'Focus începător: matrici, legi de compoziție, polinoame (punctele a și b), primele 4 exerciții de la Subiectul I, derivata punctul a și integrala punctul a.',
                        style: AppText.subheadStyle.copyWith(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(
                      'Pentru nivelurile Mediu și Avansat extindem planul în pasul următor.',
                      style: AppText.captionStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MathLevelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MathLevelCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue.withAlpha(28) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.separator,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.subheadStyle),
                ],
              ),
            ),
            Icon(
              selected
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: selected ? AppColors.blue : AppColors.tertiaryLabel,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
