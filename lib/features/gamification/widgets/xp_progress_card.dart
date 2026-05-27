import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/models/app_data.dart';
import '../services/gamification_service.dart';

class XPProgressCard extends StatelessWidget {
  const XPProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GamificationService.instance.notifier,
      builder: (context, model, _) {
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
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.bolt_fill,
                    color: AppColors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'XP & Level',
                    style: AppText.titleStyle.copyWith(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${model.xpTotal} XP',
                style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${model.level} · ${model.xpToNextLevel} XP până la următorul level',
                style: AppText.captionStyle,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: model.nextLevelProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
