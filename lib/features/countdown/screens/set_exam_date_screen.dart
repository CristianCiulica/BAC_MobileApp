import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../../../src/services/app_settings.dart';
import '../../../src/services/auth_service.dart';
import '../../../src/services/firestore_service.dart';
import '../../../src/services/notification_service.dart';
import '../../study_planner/services/study_planner_service.dart';
import '../services/countdown_service.dart';

class SetExamDateScreen extends StatefulWidget {
  const SetExamDateScreen({super.key});

  @override
  State<SetExamDateScreen> createState() => _SetExamDateScreenState();
}

class _SetExamDateScreenState extends State<SetExamDateScreen> {
  late DateTime _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = CountdownService.instance.notifier.value.examDate;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    AppHaptics.medium();
    await CountdownService.instance.setExamDate(_selectedDate);
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        final profile = await FirestoreService.watchProfile(user).first;
        await NotificationService.instance.syncFromSettings(
          dailyReminder: profile.dailyReminder,
          streakReminder: profile.streakReminder,
          examAlerts: profile.examAlerts,
          examDate: _selectedDate,
        );
      } catch (_) {}
    }
    final existingPlan = StudyPlannerService.instance.planNotifier.value;
    if (existingPlan != null) {
      await StudyPlannerService.instance.savePlanAndGenerate(
        existingPlan.copyWith(
          examDate: _selectedDate,
          generatedAt: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = DateTime(now.year + 2, 12, 31);
    // Guarantee the picker's initial value stays within [min, max]; otherwise
    // CupertinoDatePicker throws an assertion.
    final initialDate = _selectedDate.isBefore(today)
        ? today
        : (_selectedDate.isAfter(maxDate) ? maxDate : _selectedDate);
    final daysLeft = _selectedDate.difference(today).inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Data examenului', titleSize: 27),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.x5,
                AppSpacing.page,
                AppSpacing.x10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Alege data oficială a examenului pentru countdown și un plan de studiu personalizat.',
                    style: AppText.subheadStyle,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  FloatingCard(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      height: 216,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initialDate,
                        minimumDate: today,
                        maximumDate: maxDate,
                        onDateTimeChanged: (value) {
                          setState(() {
                            _selectedDate = DateTime(
                              value.year,
                              value.month,
                              value.day,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  FloatingCard(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    radius: AppRadius.md,
                    child: Row(
                      children: [
                        const TintedIcon(
                          icon: CupertinoIcons.timer,
                          color: AppColors.indigo,
                        ),
                        const SizedBox(width: AppSpacing.x3),
                        Expanded(
                          child: Text(
                            daysLeft <= 0
                                ? 'Examenul este astăzi sau a trecut.'
                                : '$daysLeft zile până la examen',
                            style: AppText.headlineStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  AppButton(
                    label: 'Salvează data',
                    icon: CupertinoIcons.checkmark_alt,
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
