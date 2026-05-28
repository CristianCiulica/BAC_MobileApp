import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../services/app_settings.dart';

/// ---------------------------------------------------------------------------
/// BacPro Design System · Component library
/// Liquid Glass surfaces, spring-pressable controls, floating cards.
/// ---------------------------------------------------------------------------

/// Frosted translucent panel — the core Liquid Glass surface.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? color;
  final List<BoxShadow>? shadows;

  /// When false, drops the diagonal white sheen and renders a clean, evenly
  /// translucent frosted surface (used by the floating tab bar).
  final bool showSheen;

  const GlassPanel({
    super.key,
    required this.child,
    this.radius = AppRadius.lg,
    this.padding,
    this.blur = AppBlur.glass,
    this.color,
    this.shadows,
    this.showSheen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.glass,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppColors.glassStroke, width: 1),
              gradient: showSheen ? AppGradients.glassSheen : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Opaque floating card — white surface, soft elevation, generous radius.
class FloatingCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final Color? color;

  const FloatingCard({
    super.key,
    required this.child,
    this.radius = AppRadius.lg,
    this.padding = const EdgeInsets.all(AppSpacing.x5),
    this.shadows,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppShadows.soft,
      ),
      child: child,
    );
  }
}

/// Wraps any child with a natural spring press-down animation + haptics.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.haptic) AppHaptics.selection();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        scale: _pressed ? widget.pressedScale : 1.0,
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: _pressed ? 0.9 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}

enum AppButtonStyle { primary, secondary, glass, destructive, subtle }

/// Unified button. Gradient primary, tinted secondary, frosted glass variant.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool loading;
  final bool expanded;
  final IconData? icon;
  final double height;
  final Color? accent;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.loading = false,
    this.expanded = true,
    this.icon,
    this.height = 54,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final accentColor = accent ?? AppColors.blue;

    Color? bg;
    Gradient? gradient;
    Color fg;
    List<BoxShadow> shadows = const [];
    Border? border;

    switch (style) {
      case AppButtonStyle.primary:
        gradient = AppGradients.accent(accentColor);
        fg = Colors.white;
        if (enabled) shadows = AppShadows.soft;
      case AppButtonStyle.secondary:
        bg = AppColors.tint(accentColor);
        fg = accentColor;
      case AppButtonStyle.glass:
        bg = AppColors.glass;
        fg = AppColors.label;
        border = Border.all(color: AppColors.glassStroke);
        shadows = AppShadows.soft;
      case AppButtonStyle.destructive:
        bg = AppColors.tint(AppColors.red);
        fg = AppColors.red;
      case AppButtonStyle.subtle:
        bg = AppColors.fill;
        fg = AppColors.secondLabel;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          CupertinoActivityIndicator(color: fg)
        else ...[
          if (icon != null) ...[
            Icon(icon, color: fg, size: 19),
            const SizedBox(width: AppSpacing.x2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: fg,
              ),
            ),
          ),
        ],
      ],
    );

    final button = AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: enabled || loading ? 1 : 0.45,
      child: Container(
        height: height,
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
        decoration: BoxDecoration(
          color: bg,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: border,
          boxShadow: enabled ? shadows : const [],
        ),
        child: Center(child: content),
      ),
    );

    if (style == AppButtonStyle.glass) {
      return Pressable(
        onTap: enabled ? onPressed : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: AppBlur.glass,
              sigmaY: AppBlur.glass,
            ),
            child: button,
          ),
        ),
      );
    }

    return Pressable(onTap: enabled ? onPressed : null, child: button);
  }
}

/// Soft-tinted rounded icon badge (SF-Symbols style).
class TintedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const TintedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Small pill badge for counts / statuses.
class PillBadge extends StatelessWidget {
  final String label;
  final Color color;

  const PillBadge(this.label, {super.key, this.color = AppColors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Rounded progress bar with soft gradient fill.
class SoftProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const SoftProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.blue,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: AppColors.fill,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: AppDurations.slow,
            curve: AppDurations.ease,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.accent(color),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A stat tile: big number over a quiet caption.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) ...[
            TintedIcon(icon: icon!, color: accent ?? AppColors.blue, size: 32),
            const SizedBox(height: AppSpacing.x3),
          ],
          Text(
            value,
            maxLines: 1,
            style: AppText.statStyle.copyWith(
              color: accent ?? AppColors.label,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.captionStyle,
          ),
        ],
      ),
    );
  }
}

/// Empty state with icon, title and message.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x6,
        vertical: AppSpacing.x8,
      ),
      child: Column(
        children: [
          TintedIcon(icon: icon, color: AppColors.blue, size: 64),
          const SizedBox(height: AppSpacing.x4),
          Text(title, style: AppText.headlineStyle),
          const SizedBox(height: AppSpacing.x1),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.subheadStyle,
          ),
        ],
      ),
    );
  }
}

/// Pinned glass navigation bar as a sliver. Large title collapses gracefully.
SliverAppBar glassSliverBar(
  BuildContext context, {
  required String title,
  bool largeTitle = true,
  Widget? leading,
  List<Widget>? actions,
  bool showBack = true,
  double? titleSize,
}) {
  final canPop = showBack && Navigator.of(context).canPop();
  return SliverAppBar(
    pinned: true,
    toolbarHeight: 58,
    expandedHeight: largeTitle ? 104 : null,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: false,
    leadingWidth: 62,
    leading:
        leading ??
        (canPop
            ? Center(
                child: GlassBackButton(onTap: () => Navigator.pop(context)),
              )
            : null),
    actions: actions,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: AppBlur.glass, sigmaY: AppBlur.glass),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.68),
            border: Border(
              bottom: BorderSide(
                color: AppColors.separator.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: largeTitle
              ? FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.x4,
                    14,
                  ),
                  expandedTitleScale: 1.0,
                  collapseMode: CollapseMode.none,
                  title: Text(
                    title,
                    style: AppText.largeTitleStyle.copyWith(
                      fontSize: titleSize ?? 30,
                    ),
                  ),
                )
              : SafeArea(
                  bottom: false,
                  child: Center(
                    child: Text(
                      title,
                      style: AppText.titleStyle.copyWith(fontSize: 17),
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
}

/// Circular frosted back button.
class GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const GlassBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: AppSpacing.x3),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.separator, width: 0.5),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(CupertinoIcons.chevron_back, color: AppColors.blue, size: 20),
      ),
    );
  }
}

/// A grouped card of settings-style rows on a single floating surface.
class CardGroup extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const CardGroup({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.x5,
      AppSpacing.page,
      0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.x2,
                bottom: AppSpacing.x2,
              ),
              child: Text(
                header!.toUpperCase(),
                style: AppText.footnoteSectionStyle,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.soft,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 66,
                        color: AppColors.separator,
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2,
                AppSpacing.x2,
                AppSpacing.x2,
                0,
              ),
              child: Text(footer!, style: AppText.captionStyle),
            ),
        ],
      ),
    );
  }
}

/// Row inside a [CardGroup]: tinted icon, title, subtitle, chevron.
class CardRow extends StatefulWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const CardRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  State<CardRow> createState() => _CardRowState();
}

class _CardRowState extends State<CardRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final row = AnimatedContainer(
      duration: AppDurations.fast,
      color: _pressed ? AppColors.fill : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: 13,
      ),
      child: Row(
        children: [
          widget.leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppText.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppText.subheadStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            widget.trailing!,
            const SizedBox(width: 6),
          ],
          if (widget.onTap != null && widget.showChevron)
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.tertiaryLabel,
              size: 15,
            ),
        ],
      ),
    );

    if (widget.onTap == null) return row;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        AppHaptics.selection();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: row,
    );
  }
}

/// Frosted rounded text field.
class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;
  final IconData? prefixIcon;
  final int maxLines;
  final EdgeInsets scrollPadding;

  const AppInput({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.prefixIcon,
    this.maxLines = 1,
    this.scrollPadding = const EdgeInsets.only(bottom: 140),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Icon(prefixIcon, size: 20, color: AppColors.tertiaryLabel),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              maxLines: maxLines,
              scrollPadding: scrollPadding,
              style: AppText.bodyStyle,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppText.bodyStyle.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: 15,
                ),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}
