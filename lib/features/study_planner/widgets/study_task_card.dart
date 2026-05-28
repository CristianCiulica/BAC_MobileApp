import 'package:flutter/cupertino.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../models/study_task_model.dart';

class StudyTaskCard extends StatelessWidget {
  final StudyTaskModel task;
  final ValueChanged<bool> onChanged;

  const StudyTaskCard({super.key, required this.task, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    return Pressable(
      onTap: () => onChanged(!isDone),
      child: FloatingCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        radius: AppRadius.md,
        child: Row(
          children: [
            AnimatedScale(
              duration: AppDurations.base,
              curve: AppDurations.spring,
              scale: isDone ? 1.05 : 1.0,
              child: Icon(
                isDone
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: isDone ? AppColors.green : AppColors.tertiaryLabel,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppText.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDone ? AppColors.secondLabel : AppColors.label,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${task.durationMinutes} min · ${task.subject}',
                    style: AppText.captionStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            PillBadge(
              '+${task.xpReward} XP',
              color: isDone ? AppColors.green : AppColors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
