import 'package:flutter/cupertino.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../services/gamification_service.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GamificationService.instance.notifier,
      builder: (context, model, _) {
        return FloatingCard(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Row(
            children: [
              const TintedIcon(
                icon: CupertinoIcons.flame_fill,
                color: AppColors.red,
                size: 40,
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model.streakDays} ${model.streakDays == 1 ? 'zi' : 'zile'} streak',
                      style: AppText.headlineStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Păstrează ritmul zilnic pentru bonus XP.',
                      style: AppText.captionStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
