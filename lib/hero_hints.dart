import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sunny_dart/helpers/logging_mixin.dart';
import 'package:sunny_dart/sunny_dart.dart';

import 'expanding_card.dart';

typedef HeroHintsBuilder = Widget Function(
    BuildContext context, HeroAnimation heroInfo);

abstract class HeroHints extends Widget {
  const factory HeroHints({Key key, @required HeroHintsBuilder builder}) =
      _HeroHints;

  Widget buildCard(BuildContext context, HeroAnimation heroInfo);
}

mixin HeroHintsProviderMixin implements HeroHints {
  Widget build(BuildContext context) {
    final anim = HeroAnimation.of(context);
    return buildCard(context, anim);
  }
}

class HeroAnimation {
  final Animation<double> animation;
  final ExpandingCardState state;

  const HeroAnimation(this.animation, this.state);

  factory HeroAnimation.of(BuildContext context) {
    try {
      return Provider.of<HeroAnimation>(context);
    } on ProviderNotFoundException {
      return const HeroAnimation(null, ExpandingCardState.collapsed);
    }
  }

  bool get isExpanded => state.isExpanded;

  bool get isCollapsed => state.isCollapsed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeroAnimation &&
          runtimeType == other.runtimeType &&
          animation == other.animation &&
          state == other.state;

  @override
  int get hashCode => animation.hashCode ^ state.hashCode;
}

class _HeroHints extends StatelessWidget with HeroHintsProviderMixin {
  final HeroHintsBuilder builder;

  const _HeroHints({Key key, @required this.builder}) : super(key: key);

  @override
  Widget buildCard(BuildContext context, HeroAnimation info) {
    if (builder == null) {
      final self = this;
      assert(self is HeroWithChild,
          "No child provided to the hero widget builder.");

      return (self as HeroWithChild).child;
    }
    return builder(context, info);
  }
}

extension HeroBarWidgets on Iterable<HeroBarWidget> {
  Size get expandedHeight {
    return Size.fromHeight(expandedWidgets.sumBy((w) => w.expandedHeight));
  }

  Iterable<HeroBarWidget> get expandedWidgets {
    return this.orEmpty().where((widget) => widget.expandedHeight > 0);
  }

  Iterable<HeroBarWidget> get collapsedWidgets {
    return this.orEmpty().where((widget) => widget.collapsedHeight > 0);
  }

  Widget get collapsedColumn {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final w in this.orEmpty())
        if (w.collapsedHeight > 0)
          SizedBox(height: w.collapsedHeight, child: w.child),
    ]);
  }

  Widget get expandedColumn {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final w in this.orEmpty())
        if (w.expandedHeight > 0)
          SizedBox(height: w.expandedHeight, child: w.child),
    ]);
  }

  Size get collapsedHeight {
    return Size.fromHeight(collapsedWidgets.sumBy((w) => w.collapsedHeight));
  }
}

class HeroBarWidget extends StatelessWidget {
  final Widget child;
  final double expandedHeight;
  final double collapsedHeight;

  const HeroBarWidget.fixed({
    Key key,
    @required this.child,
    @required double height,
  })  : expandedHeight = height,
        collapsedHeight = height,
        super(key: key);

  const HeroBarWidget.expanding({
    Key key,
    @required this.child,
    @required this.collapsedHeight,
    @required this.expandedHeight,
  }) : super(key: key);

  const HeroBarWidget.collapsed({
    Key key,
    @required this.child,
    @required double height,
  })  : collapsedHeight = height,
        expandedHeight = 0.0,
        super(key: key);

  const HeroBarWidget.expanded({
    Key key,
    @required this.child,
    @required double height,
  })  : collapsedHeight = 0.0,
        expandedHeight = height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  Widget lerp(double value) {
    /// Wrap a sized box between collapsed and expanded height.
    if (collapsedHeight == expandedHeight) {
      return SizedBox(height: collapsedHeight, child: child);
    } else {
      final h = lerpDouble(collapsedHeight, expandedHeight, value);
      return SizedBox(height: h, child: child);
    }
  }
}

/// A bar (top or bottom) that knows how to resize during hero transition
class HeroBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget, HeroHints {
  @override
  final Size preferredSize;
  final Size expandedSize;
  final bool isExpanding;
  final List<HeroBarWidget> children;
  final HeroHintsBuilder transition;

  HeroBar._({
    Key key,
    @required List<HeroBarWidget> children,
    HeroHintsBuilder transition,
  }) : this.__(
            children: children,
            key: key,
            transition: transition,
            preferredSize: children.collapsedHeight,
            expandedSize: children.expandedHeight);

  HeroBar.__({
    Key key,
    @required this.children,
    this.transition,
    this.preferredSize,
    this.expandedSize,
  })  : assert(children != null),
        isExpanding = preferredSize?.height != expandedSize?.height,
        super(key: key);

  HeroBar(
      {Key key,
      @required Widget child,
      HeroHintsBuilder transition,
      @required double height,
      double expandedHeight})
      : this._(key: key, transition: transition, children: [
          HeroBarWidget.expanding(
            child: child,
            collapsedHeight: height,
            expandedHeight: expandedHeight ?? height,
          )
        ]);

  HeroBar.stacked({
    Key key,
    @required List<HeroBarWidget> children,
    HeroHintsBuilder transition,
  }) : this._(children: children, transition: transition, key: key);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }

  @override
  Widget buildCard(BuildContext context, HeroAnimation heroInfo) {
    final state = heroInfo.state;
    if (heroInfo.animation == null) {
      return state.isCollapsed
          ? SizedBox(
              height: preferredSize.height,
              child: children.collapsedColumn,
            )
          : SizedBox(
              height: expandedSize.height,
              child: children.expandedColumn,
            );
    } else {
      return AnimatedBuilder(
        builder: (BuildContext context, Widget child) {
          return SizedBox(
            height: lerpDouble(preferredSize.height, expandedSize.height,
                heroInfo.animation.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final w in children) w.lerp(heroInfo.animation.value),
              ],
            ),
          );
        },
        animation: heroInfo.animation,
      );
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _HeroBarState();
  }
}

class _HeroBarState extends State<HeroBar> with LoggingMixin {
  Map<HeroAnimation, Widget> _cached = {};

  @override
  Widget build(BuildContext context) {
    final anim = HeroAnimation.of(context);
    return _cached.putIfAbsent(anim, () {
      log.fine(() =>
          "Built new hero bar: (hasAnimation=${anim.animation != null}; direction=${anim.state}");
      return widget.buildCard(context, anim);
    });
  }
}

abstract class HeroWithChild {
  Widget get child;
}
