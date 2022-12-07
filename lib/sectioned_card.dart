import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sunny_essentials/provided.dart';
import 'package:sunny_essentials/sunny_essentials.dart';

import 'expanding_card.dart';

typedef ExpandingBuilder = Widget Function(
    BuildContext context, ExpandingCardState state);

const _kdefaults = const SectionedCardTheme(
  headerPadding: EdgeInsets.symmetric(horizontal: 8),
  bodyPadding: EdgeInsets.symmetric(horizontal: 8),
  footerPadding: EdgeInsets.symmetric(horizontal: 8),
  elevation: 2,
  footerAlignment: Alignment.center,
  headerAlignment: Alignment.center,
  bodyAlignment: Alignment.centerLeft,
  minHeaderHeight: 56,
  minFooterHeight: 24,
);

class SectionedCardTheme {
  /// Default value for [Card.clipBehavior].
  ///
  /// If null, [Card] uses [Clip.none].
  final Clip? clipBehavior;

  /// Default value for [Card.shadowColor].
  ///
  /// If null, [Card] defaults to fully opaque black.
  final Color? shadowColor;

  /// Default value for [Card.surfaceTintColor].
  ///
  /// If null, [Card] will not display an overlay color.
  ///
  /// See [Material.surfaceTintColor] for more details.
  final Color? surfaceTintColor;

  /// Default value for [Card.elevation].
  ///
  /// If null, [Card] uses a default of 1.0.
  final double? elevation;

  /// Default value for [Card.margin].
  ///
  /// If null, [Card] uses a default margin of 4.0 logical pixels on all sides:
  /// `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry? margin;

  /// Default value for [Card.shape].
  ///
  /// If null, [Card] then uses a [RoundedRectangleBorder] with a circular
  /// corner radius of 4.0.
  final ShapeBorder? shape;

  final Color? headerBackgroundColor;
  final Color? bodyBackgroundColor;
  final Color? footerBackgroundColor;

  final Color? headerForegroundColor;
  final Color? bodyForegroundColor;
  final Color? footerForegroundColor;

  final EdgeInsets? headerPadding;
  final EdgeInsets? footerPadding;
  final EdgeInsets? bodyPadding;

  final Alignment? headerAlignment;
  final Alignment? bodyAlignment;
  final Alignment? footerAlignment;

  final double? minHeaderHeight;
  final double? minFooterHeight;

  BoxConstraints? get footerConstraints => minFooterHeight == null
      ? null
      : BoxConstraints(minHeight: minFooterHeight!);

  BoxConstraints? get headerConstraints => minHeaderHeight == null
      ? null
      : BoxConstraints(minHeight: minHeaderHeight!);

  SectionedCardTheme copyWith({
    Color? headerBackgroundColor,
    Color? bodyBackgroundColor,
    Color? footerBackgroundColor,
    Color? headerForegroundColor,
    Color? bodyForegroundColor,
    Color? footerForegroundColor,
    Clip? clipBehavior,
    Color? shadowColor,
    Color? surfaceTintColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
    ShapeBorder? shape,
    EdgeInsets? headerPadding,
    EdgeInsets? footerPadding,
    EdgeInsets? bodyPadding,
    Alignment? headerAlignment,
    Alignment? bodyAlignment,
    Alignment? footerAlignment,
    double? minHeaderHeight,
    double? minFooterHeight,
  }) {
    return SectionedCardTheme._(
      clipBehavior ?? this.clipBehavior,
      shadowColor ?? this.shadowColor,
      surfaceTintColor ?? this.surfaceTintColor,
      elevation ?? this.elevation,
      margin ?? this.margin,
      shape ?? this.shape,
      headerBackgroundColor ?? this.headerBackgroundColor,
      bodyBackgroundColor ?? this.bodyBackgroundColor,
      footerBackgroundColor ?? this.footerBackgroundColor,
      headerForegroundColor ?? this.headerForegroundColor,
      bodyForegroundColor ?? this.bodyForegroundColor,
      footerForegroundColor ?? this.footerForegroundColor,
      headerPadding ?? this.headerPadding,
      footerPadding ?? this.footerPadding,
      bodyPadding ?? this.bodyPadding,
      headerAlignment ?? this.headerAlignment,
      bodyAlignment ?? this.bodyAlignment,
      footerAlignment ?? this.footerAlignment,
      minHeaderHeight ?? this.minHeaderHeight,
      minFooterHeight ?? this.minFooterHeight,
    );
  }

  SectionedCardTheme resolve(SectionedCard widget) {
    return SectionedCardTheme._(
      widget.clipBehavior ?? this.clipBehavior ?? _kdefaults.clipBehavior,
      widget.shadowColor ?? this.shadowColor ?? _kdefaults.shadowColor,
      widget.surfaceTintColor ??
          this.surfaceTintColor ??
          _kdefaults.surfaceTintColor,
      widget.elevation ?? this.elevation ?? _kdefaults.elevation,
      widget.margin ?? this.margin ?? _kdefaults.margin,
      widget.shape ?? this.shape ?? _kdefaults.shape,
      widget.headerBackgroundColor ??
          this.headerBackgroundColor ??
          _kdefaults.headerBackgroundColor,
      widget.bodyBackgroundColor ??
          this.bodyBackgroundColor ??
          _kdefaults.bodyBackgroundColor,
      widget.footerBackgroundColor ??
          this.footerBackgroundColor ??
          _kdefaults.footerBackgroundColor,
      widget.headerForegroundColor ??
          this.headerForegroundColor ??
          _kdefaults.headerForegroundColor,
      widget.bodyForegroundColor ??
          this.bodyForegroundColor ??
          _kdefaults.bodyForegroundColor,
      widget.footerForegroundColor ??
          this.footerForegroundColor ??
          _kdefaults.footerForegroundColor,
      widget.headerPadding ?? this.headerPadding ?? _kdefaults.headerPadding,
      widget.footerPadding ?? this.footerPadding ?? _kdefaults.footerPadding,
      widget.bodyPadding ?? this.bodyPadding ?? _kdefaults.bodyPadding,
      widget.headerAlignment ??
          this.headerAlignment ??
          _kdefaults.headerAlignment,
      widget.bodyAlignment ?? this.bodyAlignment ?? _kdefaults.bodyAlignment,
      widget.footerAlignment ??
          this.footerAlignment ??
          _kdefaults.footerAlignment,
      widget.minHeaderHeight ??
          this.minHeaderHeight ??
          _kdefaults.minHeaderHeight,
      widget.minFooterHeight ??
          this.minFooterHeight ??
          _kdefaults.minFooterHeight,
    );
  }

  const SectionedCardTheme._(
      this.clipBehavior,
      this.shadowColor,
      this.surfaceTintColor,
      this.elevation,
      this.margin,
      this.shape,
      this.headerBackgroundColor,
      this.bodyBackgroundColor,
      this.footerBackgroundColor,
      this.headerForegroundColor,
      this.bodyForegroundColor,
      this.footerForegroundColor,
      this.headerPadding,
      this.footerPadding,
      this.bodyPadding,
      this.headerAlignment,
      this.bodyAlignment,
      this.footerAlignment,
      this.minHeaderHeight,
      this.minFooterHeight);

  static SectionedCardTheme fromTheme(ThemeData data) {
    var cardTheme = data.cardTheme;
    return SectionedCardTheme._(
        cardTheme.clipBehavior,
        cardTheme.shadowColor,
        cardTheme.surfaceTintColor,
        cardTheme.elevation,
        cardTheme.margin,
        cardTheme.shape,
        data.appBarTheme.backgroundColor ?? data.colorScheme.secondaryContainer,
        data.cardTheme.color,
        data.bottomNavigationBarTheme.backgroundColor ??
            data.colorScheme.tertiaryContainer,
        data.appBarTheme.foregroundColor ??
            data.colorScheme.onSecondaryContainer,
        data.bottomNavigationBarTheme.selectedItemColor ??
            data.colorScheme.onTertiaryContainer,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null);
  }

  static SectionedCardTheme of(BuildContext context) {
    var existing = Provided.find<SectionedCardTheme>(context);
    return existing ?? SectionedCardTheme.fromTheme(Theme.of(context));
  }

  static SectionedCardTheme resolved(BuildContext context, SectionedCard card) {
    var th = of(context);
    return th.resolve(card);
  }

  const SectionedCardTheme({
    this.clipBehavior,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.margin,
    this.shape,
    this.headerBackgroundColor,
    this.bodyBackgroundColor,
    this.footerBackgroundColor,
    this.headerForegroundColor,
    this.bodyForegroundColor,
    this.footerForegroundColor,
    this.headerPadding,
    this.footerPadding,
    this.bodyPadding,
    this.headerAlignment,
    this.bodyAlignment,
    this.footerAlignment,
    this.minHeaderHeight,
    this.minFooterHeight,
  });
}

class SectionedCard extends StatelessWidget {
  const SectionedCard({
    super.key,
    this.header,
    this.onTap,
    this.onLongPress,
    this.clipBehavior,
    this.elevation,
    this.margin,
    this.shape,
    this.shadowColor,
    this.surfaceTintColor,
    required this.body,
    this.footer,
    this.headerPadding,
    this.footerPadding,
    this.bodyPadding,
    this.headerAlignment,
    this.bodyAlignment,
    this.footerAlignment,
    this.minHeaderHeight,
    this.minFooterHeight,
    this.headerBackgroundColor,
    this.bodyBackgroundColor,
    this.footerBackgroundColor,
    this.headerForegroundColor,
    this.bodyForegroundColor,
    this.footerForegroundColor,
    this.headerStyle,
    this.footerStyle,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? header;
  final Widget body;
  final Widget? footer;

  final Color? headerBackgroundColor;
  final Color? bodyBackgroundColor;
  final Color? footerBackgroundColor;

  final Color? headerForegroundColor;
  final Color? bodyForegroundColor;
  final Color? footerForegroundColor;

  /// Default value for [Card.clipBehavior].
  ///
  /// If null, [Card] uses [Clip.none].
  final Clip? clipBehavior;

  /// Default value for [Card.shadowColor].
  ///
  /// If null, [Card] defaults to fully opaque black.
  final Color? shadowColor;

  /// Default value for [Card.surfaceTintColor].
  ///
  /// If null, [Card] will not display an overlay color.
  ///
  /// See [Material.surfaceTintColor] for more details.
  final Color? surfaceTintColor;

  /// Default value for [Card.elevation].
  ///
  /// If null, [Card] uses a default of 1.0.
  final double? elevation;

  /// Default value for [Card.margin].
  ///
  /// If null, [Card] uses a default margin of 4.0 logical pixels on all sides:
  /// `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry? margin;

  /// Default value for [Card.shape].
  ///
  /// If null, [Card] then uses a [RoundedRectangleBorder] with a circular
  /// corner radius of 4.0.
  final ShapeBorder? shape;

  final EdgeInsets? headerPadding;
  final EdgeInsets? footerPadding;
  final EdgeInsets? bodyPadding;

  final Alignment? headerAlignment;
  final Alignment? bodyAlignment;
  final Alignment? footerAlignment;

  final double? minHeaderHeight;
  final double? minFooterHeight;

  final TextStyle? headerStyle;
  final TextStyle? footerStyle;

  @override
  Widget build(BuildContext context) {
    return onTap != null || onLongPress != null
        ? HoverEffect(
            cursor: SystemMouseCursors.click,
            builder: (isHovered) => Tappable(
              onTap: onTap == null
                  ? null
                  : (_) {
                      onTap!();
                    },
              onLongPress: onLongPress == null ? null : (_) => onLongPress!(),
              child: _buildCard(context, isHovered),
            ),
          )
        : _buildCard(context, false);
  }

  Widget _buildCard(BuildContext context, bool isHovered) {
    var theme = SectionedCardTheme.of(context);
    theme = theme.resolve(this);
    return Card(
      color: theme.bodyBackgroundColor,
      clipBehavior: theme.clipBehavior,
      elevation: theme.elevation! + (isHovered ? 2 : 0.0),
      margin: theme.margin,
      shadowColor: theme.shadowColor,
      surfaceTintColor: theme.surfaceTintColor,
      shape: theme.shape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Container(
              padding: theme.headerPadding,
              constraints: theme.headerConstraints,
              alignment: theme.headerAlignment,
              color: theme.headerBackgroundColor,
              child: DefaultTextStyle(
                  child: header!,
                  style: (headerStyle ?? const TextStyle(inherit: true))
                      .copyWith(color: theme.headerForegroundColor)),
            ),
          Container(
              padding: theme.bodyPadding,
              alignment: theme.bodyAlignment,
              child: DefaultTextStyle.merge(
                  style: TextStyle(
                      inherit: true, color: theme.bodyForegroundColor),
                  child: body)),
          if (footer != null)
            Container(
              constraints: theme.footerConstraints,
              padding: theme.footerPadding,
              alignment: theme.footerAlignment,
              color: theme.footerBackgroundColor,
              child: DefaultTextStyle.merge(
                child: footer!,
                style: (footerStyle ?? const TextStyle(inherit: true))
                    .copyWith(color: theme.footerForegroundColor),
              ),
            ),
        ],
      ),
    );
  }
}
