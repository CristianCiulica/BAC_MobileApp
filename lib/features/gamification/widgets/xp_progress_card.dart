import 'package:flutter/cupertino.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../services/gamification_service.dart';

class XPProgressCard extends StatelessWidget {
  const XPProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GamificationService.instance.notifier,
      builder: (context, model, _) {
        return FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const TintedIcon(
                    icon: CupertinoIcons.bolt_fill,
                    color: AppColors.orange,
                    size: 36,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model.xpTotal} XP',
                          style: AppText.statStyle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${model.xpToNextLevel} XP până la următorul nivel',
                          style: AppText.captionStyle,
                        ),
                      ],
                    ),
                  ),
                  PillBadge('Nivel ${model.level}', color: AppColors.orange),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              SoftProgressBar(
                value: model.nextLevelProgress,
                color: AppColors.orange,
              ),
            ],
          ),
        );
      },
    );
  }
}
