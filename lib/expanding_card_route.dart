import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class ExpandingCardRoute<T> extends TransitionRoute<T> {
  final Duration transitionDuration;
  final WidgetBuilder builder;
  ExpandingCardRoute({
    @required this.builder,
    String title,
    String name,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    @required this.transitionDuration,
  }) : super(settings: RouteSettings(name: name));

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(builder: this.builder, maintainState: false);
  }

  @override
  bool get opaque => false;
}
