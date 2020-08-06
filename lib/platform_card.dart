import 'package:expanding_cards/platform_card_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:sunny_dart/helpers/functions.dart';

class PlatformCard extends StatelessWidget {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;

  final BorderRadius borderRadius;
  final bool useShadow;
  final double height;
  final double width;
  final Widget child;
  final double minHeight;
  final double minWidth;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final List<BoxShadow> shadow;
  final PlatformCardTheme theme;
  final bool shouldClip;

  const PlatformCard({
    Key key,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color = Colors.white,
    this.height,
    this.width,
    this.child,
    this.useShadow = true,
    this.minWidth,
    this.theme,
    this.minHeight,
    this.onTap,
    this.shouldClip,
    this.onLongPress,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? PlatformCardTheme.of(context);
    Widget widget;
    if (isIOS) {
      final iosCenter = Container(
        margin: margin ?? theme.margin,
        padding: padding ?? theme.padding,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
            color: color ?? theme.cardColor,
            borderRadius: borderRadius ?? theme.borderRadius,
            boxShadow: useShadow ? shadow ?? theme.boxShadow : null),
        child: child,
      );
      widget = shouldClip == true
          ? ClipRRect(
              borderRadius: borderRadius ?? theme.borderRadius,
              child: iosCenter)
          : iosCenter;
    } else {
      widget = Card(
          margin: margin ?? theme.margin,
          child: Container(
            padding: padding ?? theme.padding,
            child: child,
          ));
    }

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: widget,
      );
    } else {
      return widget;
    }
  }
}
