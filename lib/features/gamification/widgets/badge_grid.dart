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
            mainAxisExtent: 110,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.green.withAlpha(22) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? AppColors.green.withAlpha(80)
              : AppColors.separator,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUnlocked
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.lock_fill,
            color: isUnlocked ? AppColors.green : AppColors.tertiaryLabel,
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
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
