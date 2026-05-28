import 'package:flutter/cupertino.dart';

import '../../../src/models/app_data.dart';
import '../../../src/services/auth_service.dart';
import '../../../src/services/app_settings.dart';
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
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Setează data Bacului'),
        previousPageTitle: 'Înapoi',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saving ? null : _save,
          child: _saving
              ? const CupertinoActivityIndicator()
              : const Text('Salvează'),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Alege data oficială a examenului pentru un plan personalizat.',
                style: AppText.subheadStyle,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                maximumDate: DateTime(DateTime.now().year + 2, 12, 31),
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
          ],
        ),
      ),
    );
  }
}
