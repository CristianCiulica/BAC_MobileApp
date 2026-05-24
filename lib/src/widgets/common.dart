import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_data.dart';

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconBadge({super.key, required this.icon, required this.color, this.size = 44});

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

  const IOSSection({super.key, this.header, this.footer, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Text(header!.toUpperCase(), style: AppText.footnoteSectionStyle),
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
                  const Divider(height: 0, indent: 60, color: AppColors.separator, thickness: 0.5),
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

  const IOSCell({super.key, required this.leading, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  State<IOSCell> createState() => _IOSCellState();
}

class _IOSCellState extends State<IOSCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
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
            const Icon(CupertinoIcons.chevron_right, color: AppColors.tertiaryLabel, size: 16),
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
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
      child: Text('$count materii', style: AppText.captionStyle),
    );
  }
}

