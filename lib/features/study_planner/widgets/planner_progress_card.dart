import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planul de azi',
            style: AppText.titleStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            totalTasks == 0
                ? 'Nu există task-uri pentru astăzi.'
                : '$completedTasks / $totalTasks task-uri completate',
            style: AppText.subheadStyle,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: onOpenTodayPlan,
              child: const Text('Începe task-urile'),
            ),
          ),
        ],
      ),
    );
  }
}
