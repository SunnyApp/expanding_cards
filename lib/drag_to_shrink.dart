import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

/// Returns true/false to determine whether the widget should continue
/// checking for stretch threshold.
///
/// If you are popping the current view, you probably don't want to keep
/// checking overscroll
typedef StretchCallback = Future<bool> Function(BuildContext context);

/// Wraps the resizing widget
typedef ResizeDecorator = Widget Function(Widget widget);

Future<bool> _navigatorPop(BuildContext context) async {
  Navigator.pop(context);
  return false;
}

/// A widget that shrinks when on drag down.  It doesn't matter if you are dragging
/// directly on the widget or not, the effect is the same.
class DragToShrink extends StatefulWidget {
  final Widget child;
  final double stretchOffset;
  final StretchCallback onStretch;
  final double maxBorderRadius;
  final ResizeDecorator resizeDecorator;

  const DragToShrink({
    Key key,
    @required this.child,
    this.stretchOffset,
    this.onStretch,
    this.maxBorderRadius,
    this.resizeDecorator,
  }) : super(key: key);

  /// When the [stretchOffset] is reached, this view is popped off the Navigator stack
  const DragToShrink.navigatorPop({
    Key key,
    @required this.child,
    this.stretchOffset = 100 / 2,
    this.maxBorderRadius,
    this.resizeDecorator,
  })  : onStretch = _navigatorPop,
        super(key: key);

  @override
  _DragToShrinkState createState() => _DragToShrinkState();
}

class _DragToShrinkState extends State<DragToShrink>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _processingStretch = false;
  static const _maxScaleRange = 1;
  static const _minScaleRange = 0.6;
  static const _maxUnitRange = 1;
  static const _minUnitRange = 0;

  /// pre-calculated constants for doing the lerping
  static const a =
      (_maxScaleRange - _minScaleRange) / (_maxUnitRange - _minUnitRange);
  static const b = _minScaleRange - (a * _minUnitRange);

  /// The current scale of the widget
  double _scale;

  /// The current distance the user has underscrolled
  double _offset = 0;

  /// How much stretch is allowed before triggering [DragToShrink.onStretch]
  double _stretchOffset;

  /// The cached child widget, with any decoration
  Widget _wrapped;

  /// Cached [MediaQuery.size] of this widget
  Size _size;

  /// Cached value for the centerPoint, based off [_size]
  Offset _center;

  @override
  void initState() {
    super.initState();
    _scale = 1;
    _stretchOffset = widget.stretchOffset ?? 100000000;

    /// This controller manages the snapback, eg. when the user releases but does not reach the
    /// stretch threshold
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 100),
    );

    _controller.addListener(() {
      setState(() {
        _scale = _controller.value as double;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runAnimation(Offset pixelsPerSecond, double scale) {
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.

    final unitsPerSecondY = pixelsPerSecond.dy / math.max(0.1, scale);

    final unitVelocity = unitsPerSecondY;

    const spring = SpringDescription(
      mass: 30.0,
      stiffness: 1.0,
      damping: 1.0,
    );

    final simulation = SpringSimulation(spring, scale, 1, unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    _size ??= MediaQuery.of(context).size;
    _center ??= _size.center(Offset.zero);
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrolled) {
          if (scrolled is ScrollEndNotification) {
            if (scrolled.dragDetails != null) {
              _runAnimation(
                  scrolled.dragDetails?.velocity?.pixelsPerSecond, _scale);
            }
            return false;
          }

          /// Ignore if we're in the middle of processing an oversstretch
          if (_processingStretch) {
            return true;
          }

          final details = scrolled.metrics;

          /// We are only interested in downward swipes
          if (details.pixels >= 0) {
            return true;
          }
          _offset = 0 - details.pixels;

          if (_offset >= _stretchOffset) {
            if (widget.onStretch != null) {
              _processingStretch = true;
              widget.onStretch(context)?.then((shouldContinue) {
                _processingStretch = !shouldContinue;
              });
            }
          } else {
            final newScale = (1 - ((_offset) / 300)).clamp(0, 1);
            setState(() {
              _scale = newScale.toDouble();
            });
          }
          return false;
        },
        child: Transform(
          transform: Matrix4Transform()
              .scaleBy(x: a * _scale + b, y: a * _scale + b, origin: _center)
//              .down(_offset.clamp(.1, 1000) / 3)
              .matrix4,
//          scale: a * _scsale + b,
          child: _wrapped ??= _buildDecorated(),
          transformHitTests: false,
        ),
      ),
    );
  }

  Widget _buildDecorated() {
    return widget.resizeDecorator?.call(widget.child) ?? widget.child;
  }
}
