import 'package:flutter/cupertino.dart';

import '../../../src/design/ui.dart';
import '../../../src/models/app_data.dart';
import '../services/countdown_service.dart';

/// Exam countdown — floating card with big numerals and a soft progress bar.
class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CountdownService.instance.notifier,
      builder: (context, model, _) {
        final percent = (model.progressPercent * 100).clamp(0, 100).toDouble();
        final examYear = model.examDate.year;
        final sessionStart = DateTime(examYear, 6, 2);

        return FloatingCard(
          radius: AppRadius.xl,
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const TintedIcon(
                    icon: CupertinoIcons.calendar,
                    color: AppColors.indigo,
                    size: 36,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Text('Countdown BAC', style: AppText.titleStyle),
                  ),
                  PillBadge('Iunie $examYear', color: AppColors.blue),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${model.daysRemaining}',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                      height: 1,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'zile · ${model.weeksRemaining} săptămâni',
                      style: AppText.subheadStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x3),
              SoftProgressBar(value: model.progressPercent),
              const SizedBox(height: AppSpacing.x2),
              Text(
                '${percent.toStringAsFixed(0)}% din parcursul până la examen',
                style: AppText.captionStyle,
              ),
              const SizedBox(height: AppSpacing.x3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Sesiunea începe pe ${_formatDateRo(sessionStart)} · probe scrise din ${_formatDateRo(model.examDate)}',
                  style: AppText.captionStyle,
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(model.motivationalMessage, style: AppText.subheadStyle),
            ],
          ),
        );
      },
    );
  }

  static String _formatDateRo(DateTime date) {
    const months = <String>[
      'ianuarie',
      'februarie',
      'martie',
      'aprilie',
      'mai',
      'iunie',
      'iulie',
      'august',
      'septembrie',
      'octombrie',
      'noiembrie',
      'decembrie',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
