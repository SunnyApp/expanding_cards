import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sunny_dart/helpers/logging_mixin.dart';

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

/// A bar (top or bottom) that knows how to resize during hero transition
class HeroBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget, HeroHints {
  @override
  final Size preferredSize;
  final Size expandedSize;
  final Widget child;
  final HeroHintsBuilder transition;

  const HeroBar(
      {Key key,
      @required this.child,
      this.transition,
      @required this.preferredSize,
      this.expandedSize})
      : assert(child != null),
        super(key: key);

  HeroBar.ofHeight(
      {Key key,
      @required this.child,
      this.transition,
      @required double height,
      double expandedHeight})
      : assert(child != null),
        preferredSize = Size.fromHeight(height),
        expandedSize =
            expandedHeight == null ? null : Size.fromHeight(expandedHeight),
        super(key: key);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }

  @override
  Widget buildCard(BuildContext context, HeroAnimation heroInfo) {
    if (expandedSize == null)
      return SizedBox(height: preferredSize.height, child: this.child);
    final state = heroInfo.state;

    if (heroInfo.animation == null) {
      return SizedBox(
          height:
              state.isCollapsed ? preferredSize.height : expandedSize.height,
          child: child);
    } else {
      final sizeAnimation = heroInfo.animation.drive(Tween(
        begin: preferredSize.height,
        end: expandedSize.height,
      ));
      return AnimatedBuilder(
        builder: (BuildContext context, Widget child) {
          return SizedBox(height: sizeAnimation.value, child: this.child);
        },
        animation: sizeAnimation,
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
