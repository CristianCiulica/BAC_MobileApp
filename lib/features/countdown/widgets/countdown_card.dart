import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/models/app_data.dart';
import '../services/countdown_service.dart';

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
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark ? 0.18 : 0.05,
                ),
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withAlpha(32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.calendar_today,
                      size: 19,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Countdown Bac',
                      style: AppText.titleStyle.copyWith(fontSize: 19),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      'Iunie-Iulie $examYear',
                      style: AppText.captionStyle.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sesiunea începe pe ${_formatDateRo(sessionStart)} · probe scrise din ${_formatDateRo(model.examDate)}',
                style: AppText.captionStyle,
              ),
              const SizedBox(height: 10),
              Text(
                '${model.daysRemaining} zile · ${model.weeksRemaining} săptămâni',
                style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: model.progressPercent,
                  backgroundColor: AppColors.separator.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percent.toStringAsFixed(0)}% din parcursul până la examen',
                style: AppText.captionStyle,
              ),
              const SizedBox(height: 8),
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
