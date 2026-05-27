import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../src/models/app_data.dart';
import '../../gamification/widgets/streak_card.dart';
import '../../gamification/widgets/xp_progress_card.dart';
import '../services/study_planner_service.dart';
import '../widgets/planner_progress_card.dart';
import '../widgets/study_task_card.dart';
import 'planner_setup_screen.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Planul de Azi'),
        previousPageTitle: 'Înapoi',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const PlannerSetupScreen()),
            );
          },
          child: const Text('Setup'),
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: StudyPlannerService.instance.tasksNotifier,
          builder: (context, _, _) {
            final tasks = StudyPlannerService.instance.tasksForDate(
              DateTime.now(),
            );
            final completed = tasks.where((task) => task.isCompleted).length;

            if (StudyPlannerService.instance.planNotifier.value == null) {
              return _EmptyPlannerState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                PlannerProgressCard(
                  completedTasks: completed,
                  totalTasks: tasks.length,
                  onOpenTodayPlan: () {},
                ),
                const SizedBox(height: 12),
                const XPProgressCard(),
                const SizedBox(height: 12),
                const StreakCard(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: AppColors.indigo,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () async {
                          final granted = await StudyPlannerService.instance
                              .completeStudySessionForToday();
                          if (!context.mounted) return;
                          HapticFeedback.mediumImpact();
                          showCupertinoDialog<void>(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: Text(
                                granted
                                    ? 'Sesiune salvată'
                                    : 'Deja salvată azi',
                              ),
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
                        },
                        child: const Text('Finalizează sesiunea (+25 XP)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nu ai task-uri programate azi. Poți regenera planner-ul din Setup.',
                      style: AppText.subheadStyle,
                    ),
                  ),
                for (final task in tasks) ...[
                  StudyTaskCard(
                    task: task,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      StudyPlannerService.instance.toggleTaskCompletion(
                        task.id,
                        value,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyPlannerState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 40,
              color: AppColors.blue,
            ),
            const SizedBox(height: 12),
            Text(
              'Nu ai un planner configurat.',
              style: AppText.titleStyle.copyWith(fontSize: 21),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Configurează rapid materiile și timpul disponibil, apoi generăm task-urile automat.',
              style: AppText.subheadStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const PlannerSetupScreen()),
              ),
              child: const Text('Configurează Planner-ul'),
            ),
          ],
        ),
      ),
    );
  }
}
