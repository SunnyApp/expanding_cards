import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

class CustomRectTween extends RectTween {
  CustomRectTween({this.begin, this.end}) : super(begin: begin, end: end);
  final Rect begin;
  final Rect end;

  @override
  Rect lerp(double t) {
//    Curves.elasticOut.transform(t);
    //any curve can be applied here e.g. Curve.elasticOut.transform(t);
    final verticalDist = Curves.decelerate.transform(t);

    final top = lerpDouble(begin.top, end.top, t) * verticalDist;
    return Rect.fromLTRB(
      lerpDouble(begin.left, end.left, verticalDist),
      lerpDouble(begin.top, end.top, verticalDist),
      lerpDouble(begin.right, end.right, verticalDist),
      lerpDouble(begin.bottom, end.bottom, verticalDist),
    );
  }

  double lerpDouble(num a, num b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return (a + (b - a) * t).toDouble();
  }
}

class ElastiRectTween extends RectTween {
  ElastiRectTween.ofPosition({this.begin, this.end})
      : heightTween = Tween(begin: begin.height, end: end.height),
        widthTween = Tween(begin: begin.width, end: end.width),
        centerTween = Tween(begin: begin.center, end: end.center)
            .chain(CurveTween(curve: ElasticOutCurve(0.6))),
        super(begin: begin, end: end);

  final Rect begin;
  final Rect end;
  final Tween<double> heightTween;
  final Tween<double> widthTween;
  final Animatable<Offset> centerTween;

  @override
  Rect lerp(double t) {
    final centerLoc = centerTween.transform(t);

    return Rect.fromCenter(
        center: centerLoc,
        width: widthTween.lerp(t),
        height: heightTween.lerp(t));
  }
}

final customSprung =
    Sprung.scroll(damping: 1.0, stiffness: 300, mass: 3, velocity: 5);
final customSprungFlipped = customSprung.flipped;
final frontLoaded = Interval(0, 1, curve: Curves.linear);

class OvershootingRectTween extends RectTween {
  OvershootingRectTween.ofPosition({this.begin, this.end, Curve curve})
      : heightTween = Tween(begin: begin.height, end: end.height),
        widthTween = Tween(begin: begin.width, end: end.width),
        topTween = Tween(begin: begin.topLeft, end: end.topLeft),
        super(begin: begin, end: end);

  final Rect begin;
  final Rect end;
  final Tween<double> heightTween;
  final Tween<double> widthTween;
  final Animatable<Offset> topTween;

  @override
  Rect lerp(double t) {
    final s = customSprung.transform(t);
    final fl = frontLoaded.transform(t);
    final centerLoc = topTween.transform(s);

    return Rect.fromLTWH(
      centerLoc.dx,
      centerLoc.dy,
      widthTween.lerp(fl),
      heightTween.lerp(fl),
    );
  }
}

class Sprung extends Curve {
  /// The underlying physics simulation.
  final SpringSimulation _sim;

  /// A Curve that uses the Flutter Physics engine to drive realistic animations.
  ///
  /// Provides a critically damped spring by default, with an easily overrideable damping value.
  ///
  /// See also: [Sprung.custom], [Sprung.underDamped], [Sprung.criticallyDamped], [Sprung.overDamped]
  factory Sprung([double damping = 20]) => Sprung.custom(damping: damping);

  Sprung.scroll(
      {double damping = 1.0,
      double stiffness = 180,
      double mass = 1.0,
      double velocity = 0.0})
      : _sim = ScrollSpringSimulation(
            SpringDescription.withDampingRatio(
              mass: mass,
              stiffness: stiffness,
              ratio: damping,
            ),
            0.0,
            1.0,
            velocity);

  /// Provides a critically damped spring by default, with an easily overrideable damping, stiffness and mass value.
  Sprung.custom({
    double damping = 20,
    double stiffness = 180,
    double mass = 1.0,
    double velocity = 0.0,
  }) : this._sim = SpringSimulation(
          SpringDescription(
            damping: damping,
            mass: mass,
            stiffness: stiffness,
          ),
          0.0,
          1.0,
          velocity,
        );

  /// Provides an **under damped** spring, which wobbles loosely at the end.
  static Curve get underDamped => Sprung(12);

  /// Provides a **critically damped** spring, which overshoots once very slightly.
  static Curve get criticallyDamped => Sprung(20);

  /// Provides an **over damped** spring, which smoothly glides into place.
  static Curve get overDamped => Sprung(28);

  /// Returns the position from the simulator and corrects the final output `x(1.0)` for tight tolerances.
  @override
  double transform(double t) => _sim.x(t) + t * (1 - _sim.x(1.0));
}
