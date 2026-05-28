import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../services/app_settings.dart';

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2279),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Text(
              header!.toUpperCase(),
              style: AppText.footnoteSectionStyle,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 0,
                    indent: 60,
                    color: AppColors.separator,
                    thickness: 0.5,
                  ),
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(footer!, style: AppText.captionStyle),
          ),
      ],
    );
  }
}

class IOSCell extends StatefulWidget {
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
  State<IOSCell> createState() => _IOSCellState();
}

class _IOSCellState extends State<IOSCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        AppHaptics.selection();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed ? AppColors.separator : AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            widget.leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppText.bodyStyle),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.subtitle!, style: AppText.subheadStyle),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.tertiaryLabel,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;

  const CountBadge(this.count, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count materii', style: AppText.captionStyle),
    );
  }
}

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
    final backgroundColor = Color.lerp(
      AppColors.surface,
      accentColor,
      AppColors.isDark ? 0.12 : 0.06,
    )!;
    final borderColor = AppColors.isDark
        ? AppColors.separator.withAlpha(220)
        : const Color(0xFFE2E6EC);
    final surfaceBlend = Color.lerp(
      AppColors.surface,
      accentColor,
      AppColors.isDark ? 0.08 : 0.03,
    )!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, surfaceBlend],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark
                ? Colors.black.withAlpha(20)
                : Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: -46,
              top: -62,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withAlpha(AppColors.isDark ? 78 : 52),
                        accentColor.withAlpha(0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                subtitle == null ? 18 : 16,
                18,
                16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: subtitle == null ? 42 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accentColor, accentColor.withAlpha(150)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: AppColors.label,
                                letterSpacing: -0.5,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
