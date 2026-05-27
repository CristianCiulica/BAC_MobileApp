import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/models/app_data.dart';
import '../../../src/navigation.dart';
import '../screens/set_exam_date_screen.dart';
import '../services/countdown_service.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CountdownService.instance.notifier,
      builder: (context, model, _) {
        final percent = (model.progressPercent * 100).clamp(0, 100).toDouble();
        return Container(
          width: double.infinity,
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
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await Navigator.push(
                        context,
                        cupertinoRoute(const SetExamDateScreen()),
                      );
                      await CountdownService.instance.refreshNow();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Setează',
                        style: AppText.captionStyle.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  backgroundColor: Colors.grey[300],
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
}
