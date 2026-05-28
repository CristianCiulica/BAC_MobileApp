import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design/ui.dart';
import '../models/app_data.dart';

export '../design/ui.dart';

/// Soft-tinted icon badge — SF-Symbols style, replaces the old solid squares.
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return TintedIcon(icon: icon, color: color, size: size);
  }
}

/// Grouped floating card of rows (kept name for compatibility).
class IOSSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;

  const IOSSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CardGroup(header: header, footer: footer, children: children);
  }
}

/// Row within a section (kept name for compatibility).
class IOSCell extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const IOSCell({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardRow(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;

  const CountBadge(this.count, {super.key});

  @override
  Widget build(BuildContext context) {
    return PillBadge('$count materii', color: AppColors.blue);
  }
}

/// Hero title card for a subject — bright surface, soft accent glow.
class SubjectTitleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;

  const SubjectTitleCard({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = AppColors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: accentColor,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppText.subheadStyle),
          ],
        ],
      ),
    );
  }
}
