import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Enforces HitTest.opaque and removes parameters
Widget tappable<R>(Widget child,
    {FutureOrCallback onTap,
    Key key,
    double pressOpacity: 1.0,
    BuildContext context,
    String routeName,
    arguments,
    void callback(R result)}) {
  if (onTap == null && routeName == null) return child;

  return GestureDetector(
      child: child,
      onTap: () async {
        onTap?.call();
        assert(routeName == null || context != null,
            "If you provide a route, you must also provide a buildContext");
        if (routeName != null) {
          final R result = await Navigator.pushNamed(context, routeName,
              arguments: arguments);
          callback(result);
        }
      },
      behavior: HitTestBehavior.opaque);
}

typedef FutureOrCallback<T> = FutureOr<T> Function();
typedef FutureCallback<T> = Future<T> Function(BuildContext context);

enum TapTransform {
  opacity,
  scale,
}

class TapHandler extends StatefulWidget {
  final double pressOpacity;
  final double pressScale;
  final FutureCallback onTap;
  final Widget child;
  final Duration duration;

  TapHandler.link(
    String s, {
    this.onTap,
    TextStyle style,
  })  : duration = const Duration(milliseconds: 300),
        pressOpacity = null,
        pressScale = null,
        child = Text(s, style: style);

  const TapHandler(
      {Key key,
      this.pressOpacity = 0.7,
      this.pressScale,
      this.duration = const Duration(milliseconds: 300),
      this.onTap,
      this.child})
      : super(key: key);

  @override
  _TapHandlerState createState() => _TapHandlerState();
}

class _TapHandlerState extends State<TapHandler>
    with SingleTickerProviderStateMixin {
  AnimationController _ac;
  Animation<double> _scaleAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 0,
    );
    _opacityAnimation =
        _ac.drive(Tween(begin: 1, end: widget.pressOpacity ?? 1));
    _scaleAnimation = _ac.drive(Tween(begin: 1, end: widget.pressScale ?? 1));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (tap) {
        _ac.forward();
      },
      onTapUp: (_) async {
        try {
          await widget.onTap?.call(context);
        } finally {
          if (mounted) {
            _ac.reverse();
          }
        }
      },
      onTapCancel: () {
        _ac.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
