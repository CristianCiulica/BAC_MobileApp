import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../../../src/services/app_settings.dart';
import '../../gamification/widgets/badge_grid.dart';
import '../models/study_task_model.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          glassSliverBar(context, title: 'Plan săptămânal', titleSize: 27),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: StudyPlannerService.instance.tasksNotifier,
              builder: (context, _, _) {
                final tasks = StudyPlannerService.instance.tasksForWeek(now);
                final grouped = <String, List<StudyTaskModel>>{};
                for (var i = 0; i < 7; i++) {
                  final day = weekStart.add(Duration(days: i));
                  grouped[_formatRoDay(day)] = StudyPlannerService.instance
                      .tasksForDate(day);
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.x5,
                    AppSpacing.page,
                    AppSpacing.x10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tasks.isEmpty)
                        const EmptyState(
                          icon: CupertinoIcons.calendar,
                          title: 'Săptămână liberă',
                          message:
                              'Nu există task-uri generate pentru această săptămână. Configurează planner-ul de pe ecranul principal.',
                        ),
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.x2,
                            bottom: AppSpacing.x2,
                          ),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: AppText.footnoteSectionStyle,
                          ),
                        ),
                        if (entry.value.isEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.x4,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.x3),
                            decoration: BoxDecoration(
                              color: AppColors.fill,
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                            ),
                            child: Text(
                              'Zi liberă sau fără task-uri.',
                              style: AppText.captionStyle,
                            ),
                          ),
                        for (final task in entry.value) ...[
                          StudyTaskCard(
                            task: task,
                            onChanged: (value) {
                              AppHaptics.selection();
                              StudyPlannerService.instance
                                  .toggleTaskCompletion(task.id, value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.x3),
                        ],
                        if (entry.value.isNotEmpty)
                          const SizedBox(height: AppSpacing.x2),
                      ],
                      const SizedBox(height: AppSpacing.x4),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.x2,
                          bottom: AppSpacing.x2,
                        ),
                        child: Text(
                          'BADGE-URI',
                          style: AppText.footnoteSectionStyle,
                        ),
                      ),
                      const BadgeGrid(),
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
