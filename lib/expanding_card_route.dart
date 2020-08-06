import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class ExpandingCardRoute<T> extends CupertinoPageRoute<T> {
  bool _opaque = true;

  bool get opaque {
    if (_opaque) {
      _opaque = false;
      return true;
    }
    return _opaque;
  }

  ExpandingCardRoute({
    @required WidgetBuilder builder,
    String title,
    String name,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          title: title,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
}
