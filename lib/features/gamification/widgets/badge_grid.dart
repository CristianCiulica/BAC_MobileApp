import 'package:flutter/cupertino.dart';

import '../../../src/models/app_data.dart';
import '../models/badge_model.dart';
import '../services/gamification_service.dart';

class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GamificationService.instance.notifier,
      builder: (context, model, _) {
        final badges = model.badges.values.toList()
          ..sort((a, b) => a.title.compareTo(b.title));
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 116,
            crossAxisSpacing: AppSpacing.x3,
            mainAxisSpacing: AppSpacing.x3,
          ),
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _BadgeTile(badge: badge);
          },
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUnlocked
                ? CupertinoIcons.checkmark_seal_fill
                : CupertinoIcons.lock,
            color: isUnlocked ? AppColors.green : AppColors.tertiaryLabel,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            badge.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isUnlocked ? AppColors.label : AppColors.secondLabel,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.captionStyle,
          ),
        ],
      ),
    );
  }
}
