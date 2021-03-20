import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:dartxx/dartxx.dart';

import 'expanding_card.dart';

typedef HeroHintsBuilder = Widget Function(
    BuildContext context, HeroAnimation heroInfo);

abstract class HeroHints extends Widget {
  const factory HeroHints({Key? key, required HeroHintsBuilder builder}) =
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
  final Animation<double>? animation;
  final ExpandingCardState state;

  const HeroAnimation(this.animation, this.state);
  const HeroAnimation.expanded()
      : this.state = ExpandingCardState.expanded,
        animation = null;
  const HeroAnimation.collapsed()
      : this.state = ExpandingCardState.collapsed,
        animation = null;

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

  Widget provide({Widget? child}) {
    return Provider.value(
      value: this,
      updateShouldNotify: (dynamic a, dynamic b) => a != b,
      child: child,
    );
  }
}

class _HeroHints extends StatelessWidget with HeroHintsProviderMixin {
  final HeroHintsBuilder? builder;

  const _HeroHints({Key? key, this.builder}) : super(key: key);

  @override
  Widget buildCard(BuildContext context, HeroAnimation info) {
    if (builder == null) {
      final _HeroHints self = this;
      assert(self is HeroWithChild,
          "No child provided to the hero widget builder.");

      return (self as HeroWithChild).child;
    }
    return builder!(context, info);
  }
}

extension HeroBarWidgets on Iterable<HeroBarWidget> {
  Size get expandedHeight {
    return Size.fromHeight(expandedWidgets.sumBy((w) => w.expandedHeight));
  }

  Iterable<HeroBarWidget> get expandedWidgets {
    return this.where((widget) => widget.expandedHeight > 0);
  }

  Iterable<HeroBarWidget> get collapsedWidgets {
    return this.where((widget) => widget.collapsedHeight > 0);
  }

  Widget collapsedColumn(bool constrained) {
    return _maybeColumn([
      for (final w in this)
        if (w.collapsedHeight > 0)
          if (constrained)
            SizedBox(height: w.collapsedHeight, child: w.child)
          else
            w.child,
    ]);
  }

  Widget expandedColumn(bool constrained) {
    return _maybeColumn([
      for (final w in this)
        if (w.expandedHeight > 0)
          if (constrained)
            SizedBox(height: w.expandedHeight, child: w.child)
          else
            w.child,
    ]);
  }

  Widget _maybeColumn(List<Widget> widgets) {
    switch (widgets.length) {
      case 0:
        return SizedBox(height: 0, width: 0);
      case 1:
        return widgets.first;
      default:
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
    }
  }

  Size get collapsedHeight {
    return Size.fromHeight(collapsedWidgets.sumBy((w) => w.collapsedHeight));
  }
}

class HeroBarWidget extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Widget child;
  final double expandedHeight;
  final double collapsedHeight;

  Animation<double> sizeFactor(Animation<double>? driver, bool isForward) {
    if (driver == null) {
      return kAlwaysCompleteAnimation;
    }
    return hides
        ? driver.drive(Tween(begin: 1, end: 0))
        : driver.drive(Tween(
            end: isForward
                ? (collapsedHeight / expandedHeight)
                : (expandedHeight / collapsedHeight),
            begin: 1,
          ));
  }

  bool get hides {
    return expandedHeight == 0.0 || collapsedHeight == 0.0;
  }

  Widget animate(HeroAnimation heroInfo) {
    final animation = heroInfo.animation;
    final direction = heroInfo.state;
    return hides
        ? SizeTransition(
            sizeFactor: sizeFactor(animation, direction.isCollapsed),
            child: child,
          )
        : AnimatedBuilder(
            builder: (BuildContext context, Widget? child) {
              return SizedBox(
                height: lerpDouble(
                  collapsedHeight,
                  expandedHeight,
                  heroInfo.animation!.value,
                ),
                child: child,
              );
            },
            child: child,
            animation: heroInfo.animation!,
          );
  }

  const HeroBarWidget.fixed({
    Key? key,
    required this.child,
    required double height,
  })   : expandedHeight = height,
        collapsedHeight = height,
        super(key: key);

  const HeroBarWidget.expanding({
    Key? key,
    required this.child,
    required this.collapsedHeight,
    required this.expandedHeight,
  }) : super(key: key);

  HeroBarWidget.collapsed({
    Key? key,
    required Widget child,
    required double height,
  })   : child = SizedBox(height: height, child: child),
        collapsedHeight = height,
        expandedHeight = 0.0,
        super(key: key);

  const HeroBarWidget.expanded({
    Key? key,
    required this.child,
    required double height,
  })   : collapsedHeight = 0.0,
        expandedHeight = height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  // Widget lerp(double value) {
  //   /// Wrap a sized box between collapsed and expanded height.
  //   if (collapsedHeight == expandedHeight) {
  //     return SizedBox(height: collapsedHeight, child: child);
  //   } else {
  //     final h = lerpDouble(collapsedHeight, expandedHeight, value);
  //     return SizedBox(height: h, child: child);
  //   }
  // }

  @override
  Size get preferredSize => Size.fromHeight(expandedHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}

/// A bar (top or bottom) that knows how to resize during hero transition
class HeroBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget, HeroHints {
  @override
  final Size preferredSize;
  final Size? expandedSize;
  final bool isExpanding;
  final bool? skipConstraints;
  final List<HeroBarWidget> children;
  final HeroHintsBuilder? transition;

  HeroBar._({
    Key? key,
    required List<HeroBarWidget> children,
    required bool? skipConstraints,
    HeroHintsBuilder? transition,
  }) : this.__(
            children: children,
            key: key,
            skipConstraints: skipConstraints,
            transition: transition,
            preferredSize: children.collapsedHeight,
            expandedSize: children.expandedHeight);

  HeroBar.__({
    Key? key,
    required this.children,
    required this.transition,
    required this.skipConstraints,
    required this.preferredSize,
    this.expandedSize,
  })  : isExpanding = preferredSize.height != expandedSize?.height,
        super(key: key);

  HeroBar(
      {Key? key,
      required Widget child,
      HeroHintsBuilder? transition,
      bool? skipConstraints,
      required double height,
      double? expandedHeight})
      : this._(
            key: key,
            transition: transition,
            skipConstraints: skipConstraints,
            children: [
              HeroBarWidget.expanding(
                child: child,
                collapsedHeight: height,
                expandedHeight: expandedHeight ?? height,
              )
            ]);

  HeroBar.stacked({
    Key? key,
    required List<HeroBarWidget> children,
    bool? skipConstraints,
    HeroHintsBuilder? transition,
  }) : this._(
            children: children,
            skipConstraints: skipConstraints,
            transition: transition,
            key: key);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }

  Widget _constrained(HeroAnimation heroInfo) {
    final state = heroInfo.state;
    final column = state.isCollapsed
        ? children.collapsedColumn(skipConstraints != true)
        : children.expandedColumn(skipConstraints != true);
    if (skipConstraints == true) {
      return column;
    }
    return state.isCollapsed
        ? SizedBox(
            height: preferredSize.height,
            child: column,
          )
        : SizedBox(
            height: expandedSize!.height,
            child: column,
          );
  }

  @override
  Widget buildCard(BuildContext context, HeroAnimation heroInfo) {
    if (heroInfo.animation == null) {
      return _constrained(heroInfo);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in children) w.animate(heroInfo),
        ],
      );
    }
  }

  Widget buildUnconstrained(BuildContext context) {
    return children.expandedColumn(skipConstraints != true);
  }

  @override
  State<StatefulWidget> createState() {
    return _HeroBarState();
  }
}

class _HeroBarState extends State<HeroBar> {
  final log = Logger("heroBarState");
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
