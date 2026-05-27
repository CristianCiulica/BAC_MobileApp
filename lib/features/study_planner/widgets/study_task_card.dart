import 'package:flutter/cupertino.dart';

import '../../../src/models/app_data.dart';
import '../models/study_task_model.dart';

class StudyTaskCard extends StatelessWidget {
  final StudyTaskModel task;
  final ValueChanged<bool> onChanged;

  const StudyTaskCard({super.key, required this.task, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? AppColors.green.withAlpha(120) : AppColors.separator,
        ),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(28, 28),
            onPressed: () => onChanged(!isDone),
            child: Icon(
              isDone
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: isDone ? AppColors.green : AppColors.tertiaryLabel,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppText.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.durationMinutes} min · ${task.subject}',
                  style: AppText.captionStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('+${task.xpReward} XP', style: AppText.captionStyle),
        ],
      ),
    );
  }
}
