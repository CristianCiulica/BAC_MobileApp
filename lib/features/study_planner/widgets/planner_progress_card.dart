import 'package:flutter/cupertino.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';

class PlannerProgressCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final VoidCallback onOpenTodayPlan;

  const PlannerProgressCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.onOpenTodayPlan,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final allDone = totalTasks > 0 && completedTasks == totalTasks;

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Planul de azi', style: AppText.titleStyle)),
              if (totalTasks > 0)
                PillBadge(
                  '$completedTasks/$totalTasks',
                  color: allDone ? AppColors.green : AppColors.blue,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            totalTasks == 0
                ? 'Nu există task-uri pentru astăzi.'
                : allDone
                ? 'Toate task-urile de azi sunt gata. Bravo!'
                : '$completedTasks din $totalTasks task-uri completate',
            style: AppText.subheadStyle,
          ),
          const SizedBox(height: AppSpacing.x3),
          SoftProgressBar(
            value: progress,
            color: allDone ? AppColors.green : AppColors.blue,
          ),
        ],
      ),
    );
  }
}
