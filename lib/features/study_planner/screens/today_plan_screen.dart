import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../../../src/services/app_settings.dart';
import '../../gamification/widgets/streak_card.dart';
import '../../gamification/widgets/xp_progress_card.dart';
import '../services/study_planner_service.dart';
import '../widgets/planner_progress_card.dart';
import '../widgets/study_task_card.dart';
import 'planner_setup_screen.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  Future<void> _completeSession(BuildContext context) async {
    final granted = await StudyPlannerService.instance
        .completeStudySessionForToday();
    if (!context.mounted) return;
    AppHaptics.medium();
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(granted ? 'Sesiune salvată' : 'Deja salvată azi'),
        content: Text(
          granted
              ? 'Ai primit +25 XP pentru sesiunea de studiu.'
              : 'Bonusul pentru sesiune a fost acordat deja astăzi.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
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
          glassSliverBar(
            context,
            title: 'Planul de azi',
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.only(right: AppSpacing.x3),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const PlannerSetupScreen(),
                  ),
                ),
                child: const Text(
                  'Setup',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: StudyPlannerService.instance.tasksNotifier,
              builder: (context, _, _) {
                final tasks = StudyPlannerService.instance.tasksForDate(
                  DateTime.now(),
                );
                final completed = tasks
                    .where((task) => task.isCompleted)
                    .length;

                if (StudyPlannerService.instance.planNotifier.value == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                      vertical: AppSpacing.x8,
                    ),
                    child: Column(
                      children: [
                        const EmptyState(
                          icon: CupertinoIcons.calendar_badge_plus,
                          title: 'Nu ai un planner configurat',
                          message:
                              'Configurează rapid nivelul, timpul disponibil și zilele de studiu, apoi generăm task-urile automat.',
                        ),
                        AppButton(
                          label: 'Configurează planner-ul',
                          icon: CupertinoIcons.slider_horizontal_3,
                          onPressed: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => const PlannerSetupScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    AppSpacing.x10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlannerProgressCard(
                        completedTasks: completed,
                        totalTasks: tasks.length,
                        onOpenTodayPlan: () {},
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      const XPProgressCard(),
                      const SizedBox(height: AppSpacing.x3),
                      const StreakCard(),
                      const SizedBox(height: AppSpacing.x4),
                      AppButton(
                        label: 'Finalizează sesiunea (+25 XP)',
                        icon: CupertinoIcons.checkmark_seal,
                        style: AppButtonStyle.secondary,
                        accent: AppColors.indigo,
                        onPressed: () => _completeSession(context),
                      ),
                      const SizedBox(height: AppSpacing.x5),
                      if (tasks.isEmpty)
                        const EmptyState(
                          icon: CupertinoIcons.moon_zzz,
                          title: 'Zi liberă',
                          message:
                              'Nu ai task-uri programate azi. Poți regenera planner-ul din Setup.',
                        ),
                      for (final task in tasks) ...[
                        StudyTaskCard(
                          task: task,
                          onChanged: (value) {
                            AppHaptics.selection();
                            StudyPlannerService.instance.toggleTaskCompletion(
                              task.id,
                              value,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.x3),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
