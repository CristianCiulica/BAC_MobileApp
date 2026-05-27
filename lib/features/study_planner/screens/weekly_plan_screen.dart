import 'package:flutter/cupertino.dart';

import '../../../src/models/app_data.dart';
import '../../gamification/widgets/badge_grid.dart';
import '../services/study_planner_service.dart';
import '../widgets/study_task_card.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Plan săptămânal'),
        previousPageTitle: 'Înapoi',
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: StudyPlannerService.instance.tasksNotifier,
          builder: (context, _, _) {
            final tasks = StudyPlannerService.instance.tasksForWeek(now);
            final grouped = <String, List<dynamic>>{};
            for (var i = 0; i < 7; i++) {
              final day = weekStart.add(Duration(days: i));
              final key = _formatRoDay(day);
              grouped[key] = StudyPlannerService.instance.tasksForDate(day);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                for (final entry in grouped.entries) ...[
                  Text(
                    entry.key,
                    style: AppText.footnoteSectionStyle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (entry.value.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Zi liberă sau fără task-uri.',
                        style: AppText.captionStyle,
                      ),
                    ),
                  for (final task in entry.value) ...[
                    StudyTaskCard(
                      task: task,
                      onChanged: (value) => StudyPlannerService.instance
                          .toggleTaskCompletion(task.id, value),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 8),
                const Text(
                  'Badge-uri',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const BadgeGrid(),
                if (tasks.isEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Nu există task-uri în această săptămână.',
                    style: AppText.subheadStyle,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatRoDay(DateTime day) {
  const weekdays = <String>[
    'Luni',
    'Marți',
    'Miercuri',
    'Joi',
    'Vineri',
    'Sâmbătă',
    'Duminică',
  ];
  const months = <String>[
    'ian',
    'feb',
    'mar',
    'apr',
    'mai',
    'iun',
    'iul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];
  return '${weekdays[day.weekday - 1]}, ${day.day.toString().padLeft(2, '0')} ${months[day.month - 1]}';
}
