import 'package:expanding_cards/resizing_pinned_header.dart';
import 'package:expanding_cards/tweens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sunny_core_widgets/platform_card.dart';
import 'package:sunny_core_widgets/platform_card_theme.dart';
import 'package:sunny_core_widgets/sunny_core_widgets.dart';
import 'package:sunny_dart/sunny_dart.dart';

import 'hero_hints.dart';

/// High order function that provide a mechanism to build the expanded card.
/// Could be used in an onTap handler to customize the route, eg:
/// onTap: (context, buildExpandedCard) {
///    Navigator.of(context).push(
///       ExpandingCardRoute(
///            fullscreenDialog: true,
///            maintainState: true,
///            builder: (context) {
///              return buildExpandedCard(context);
///            },
///          )
///    );
typedef ExpandingCardCallback<R> = R Function(
    BuildContext context, BuildExpandedCard builder);
typedef BuildExpandedCard = Widget Function(BuildContext context);

typedef HeaderBuilder = Widget Function(
    BuildContext context, ScrollController scroller, NavigatorState state);

/// Used to decorate the expanded card
typedef ExpandedCardWrapper = Widget Function(
    BuildContext context, Widget child);

typedef WidgetListGetter = List<Widget> Function(BuildContext context);

typedef WidgetGetter = Widget Function(BuildContext context);
typedef RouteCreator = Route Function(
    BuildContext context, WidgetGetter child, double distance);

/// Displays the trip with an item or something else
///
class ExpandingCard extends StatefulWidget {
  static const kDefaultTransitionDuration = Duration(milliseconds: 800);

  /// A Widget or WidgetBuilder.  This is displayed when the card
  /// is in collapsed mode
  final dynamic expandedSection;

  /// A Widget or WidgetBuilder.  This is displayed when the card
  /// is in collapsed mode
  final dynamic collapsedSection;

  /// The footer must be preferredSize in order to apply padding
  /// properly
  final ObstructingPreferredSizeWidget footer;

  /// A header that spans to the top of the screen
  final ObstructingPreferredSizeWidget header;

  /// A header that spans to the top of the screen
  final ObstructingPreferredSizeWidget preHeader;

  /// A list of elements that are always displayed at the top of the card
  final WidgetListGetter alwaysShown;

  /// A unique id that identifies this card from otherss
  final String discriminator;

  /// A theme for the underlying card.  You can also use a `Provider` to use global
  /// styles
  final PlatformCardTheme theme;

  /// The distance to pull before the card collapses
  final double dragToCloseThreshold;

  /// Whether to show a close button
  final bool showClose;

  /// Allows customization of RouteCreator
  final RouteCreator buildRoute;

  /// Called when the collapsed card is tapped.  By default, this will
  /// expand the card.  If you need to override this behavior, make sure to
  /// call the expanding card route.  See [BuildExpandedCard]
  ///
  ///
  final ExpandingCardCallback onCardTap;

  /// Can be used to wrap the expanded card
  final ExpandedCardWrapper expandedWrapper;

  /// Can be used to wrap the expanded card
  final ExpandedCardWrapper expandedFooterWrapper;

  /// The first header provided will be put into the flexible space.  This determines
  /// the height of that flexible space.
  final double headerHeight;

  final dynamic headerLeading;
  final dynamic flexTitle;
  final dynamic headerTrailing;
  final dynamic headerTitle;

  /// Whether to display the already expanded widget
  final bool isExpanded;

  final bool pinFirst;

  /// The background of the card
  final Color backgroundColor;

  final bool useRootNavigator;

  /// THe navigator used to expand this card - used when starting from teh expanded state.
  final NavigatorState navigator;

  const ExpandingCard({
    Key key,
    this.dragToCloseThreshold = 30,
    this.expandedSection,
    this.collapsedSection,
    this.footer,
    this.preHeader,
    this.header,
    this.flexTitle,
    this.headerLeading,
    this.headerTrailing,
    this.isExpanded,
    this.theme,
    this.headerTitle,
    this.buildRoute,
    this.discriminator,
    this.onCardTap,
    this.pinFirst = false,
    this.expandedFooterWrapper,
    this.expandedWrapper,
    this.showClose = false,
    this.useRootNavigator = false,
    this.navigator,
    this.headerHeight,
    this.backgroundColor = Colors.white,
    this.alwaysShown,
  })  : assert(expandedSection is Widget || expandedSection is WidgetBuilder),
        assert(collapsedSection is Widget || collapsedSection is WidgetBuilder),
        super(key: key);

  @override
  _ExpandingCardState createState() => _ExpandingCardState();
}

enum ExpandingCardState { collapsed, transitioning, expanded }

class FixedSliverOverlapHandle implements SliverOverlapAbsorberHandle {
  final double _layoutExtent;
  final double _scrollExtent;

  const FixedSliverOverlapHandle(this._layoutExtent, this._scrollExtent);

  @override
  bool get hasListeners {
    return false;
  }

  @override
  void notifyListeners() {}

  @override
  void dispose() {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addListener(VoidCallback listener) {
    listener();
  }

  @override
  double get layoutExtent => _layoutExtent;

  @override
  double get scrollExtent => _scrollExtent;
}

class _ExpandingCardState extends State<ExpandingCard>
    with SingleTickerProviderStateMixin, LoggingMixin {
  ExpandingCardState _cardState = ExpandingCardState.collapsed;
  AnimationController _controller;

  String _discriminator;

  /// Cached bottom padding if you don't have a footer
  EdgeInsets _bottomPadding;
  PlatformCardTheme _theme;

  /// Cached builds
  Widget _collapsed;
  Widget _expanded;
  Widget _transition;

  Widget _builtExpandedHeader;
  Widget _builtPinnedHeader;
  Widget _builtCollapsedHeader;

  Widget _builtExpandedFooter;
  Widget _builtCollapsedFooter;

  Widget _builtExpandedSticky;
  Widget _builtWithGestures;
  Widget _builtWithGesturesExpanded;
  Widget _builtWithGesturesCollapsed;

  Widget _expandedPage;

  NavigatorState _sourceNavigator;

  MediaQueryData _mq;

  SliverOverlapAbsorberHandle _handle;
  SliverOverlapAbsorberHandle _h1Handle;

  ScrollController _scroller;

  @override
  void initState() {
    super.initState();
    _handle = FixedSliverOverlapHandle(0, 0);

    _bottomPadding = widget.footer != null
        ? EdgeInsets.only(bottom: widget.footer.preferredSize.height)
        : EdgeInsets.zero;
    _discriminator = widget.discriminator ?? uuid();
    _controller = AnimationController(
      value: 0,
      duration: ExpandingCard.kDefaultTransitionDuration,
      vsync: this,
    );
    _theme = widget.theme;
    _h1Handle = SliverOverlapAbsorberHandle();
    _scroller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _handle.dispose();
    _h1Handle.dispose();
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _mq ??= MediaQuery.of(context);
    _theme ??= PlatformCardTheme.of(context);
    if (widget.isExpanded == true) {
      Widget widget;
      return Provider.value(
        value: HeroAnimation(null, ExpandingCardState.expanded),
        updateShouldNotify: (a, b) => a != b,
        child: Builder(
          builder: (context) => widget ??= _buildExpandedPage(context),
        ),
      );
    }
    return _builtWithGestures ??= _wrapHero(
      _buildWithGestures(context, _cardState),
      _cardState,
    );
  }

  Widget builtFooter(
      BuildContext context, Animation<double> anim, ExpandingCardState state) {
    if (state.isCollapsed) {
      return _builtCollapsedFooter ??= _buildFooter(context, anim, state);
    } else {
      if (_builtExpandedFooter != null) return _builtExpandedFooter;
      final built = _buildFooter(context, anim, state);
      return _builtExpandedFooter ??= (widget.expandedFooterWrapper == null
          ? built
          : widget.expandedFooterWrapper(context, built));
    }
  }

  Widget builtPinnedHeader(BuildContext context) {
    final firstWidget = widget.alwaysShown(context).first;
    double height;
    if (firstWidget is HeroBar) {
      height = firstWidget.expandedSize.height;
    } else if (firstWidget is HeroBarWidget) {
      height = firstWidget.expandedHeight;
    }
    return _builtPinnedHeader ??= SliverPersistentHeader(
      pinned: true,
      delegate: ResizingPinnedHeader(
        debugLabel: "Pinned: ",
        expandedHeight: height ?? kToolbarHeight,
//        stretchConfiguration: OverScrollHeaderStretchConfiguration(
//          stretchTriggerOffset: 50,
//        ),
        child: firstWidget,
        builder: (size, ratio, child) => child,
      ),
    );
  }
//
//  Widget builtExpandedHeader2(BuildContext context) {
////    final staticH1 = Stack(
////
////      children: [
////        Container(color: Colors.white),
////        FlexibleSpaceBar(
////          background: clippedHeader,
//////                  centerTitle: true,
//////                  titlePadding: EdgeInsets.all(8),
////          collapseMode: CollapseMode.parallax,
////          stretchModes: [StretchMode.zoomBackground, StretchMode.fadeTitle],
////        ),
////      ],
////    );
//    return _builtExpandedHeader ??= SliverAppBar(
//      primary: false,
//      pinned: true,
//      stretch: true,
//      elevation: 0,
//      toolbarHeight: 10,
//      collapsedHeight: 15,
//      onStretchTrigger: () async {},
//      flexibleSpace: FlexibleSpaceBar(
//        background: widget.header,
//        centerTitle: true,
//        stretchModes: [
//          StretchMode.zoomBackground,
//          StretchMode.fadeTitle,
//        ],
////                  centerTitle: true,
////                  titlePadding: EdgeInsets.all(8),
//        collapseMode: CollapseMode.parallax,
//      ),
//      expandedHeight: _headerHeightExpanded,
//
////          actions:
////          widget.headerTrailing == null ? null : [widget.headerTrailing],
//////          automaticallyImplyLeading: widget.showClose == true,
////          automaticallyImplyLeading: false,
////          onStretchTrigger: () async {
////            Future.microtask(() => _pushedTo.pop(true));
////          },
////          stretchTriggerOffset: widget.dragToCloseThreshold,
////          stretch: widget.dragToCloseThreshold != null,
////          ),
//    );
//  }

  Widget builtExpandedHeader(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, size) {
        final top = WidgetsBinding.instance.window.padding.top /
            WidgetsBinding.instance.window.devicePixelRatio;

        return _builtExpandedHeader ??= SliverAppBar(
          primary: true,
          pinned: true,

          title: widget.headerTitle == null
              ? null
              : _buildHeaderWidget(context, widget.headerTitle),
          expandedHeight: _headerHeightExpanded - top,
          backgroundColor: Colors.white,
          elevation: 0,

          toolbarHeight: widget.headerHeight,
          leading: _buildHeaderWidget(context, widget.headerLeading),
          flexibleSpace: FlexibleSpaceBar(
            background: widget.header,
            centerTitle: false,
            titlePadding: EdgeInsets.all(8),
            collapseMode: CollapseMode.parallax,
            stretchModes: [StretchMode.zoomBackground],
            title: _buildHeaderWidget(context, widget.flexTitle),
          ),

//          leading: widget.headerLeading,
//          leading: _buildHeaderWidget(context, widget.headerLeading),
          actions: widget.headerTrailing == null
              ? null
              : [_buildHeaderWidget(context, widget.headerTrailing)],
          automaticallyImplyLeading: widget.showClose == true,
          onStretchTrigger: () async {
            Future.microtask(() => pushedTo(context).pop(true));
          },
          stretchTriggerOffset: widget.dragToCloseThreshold,
          stretch: widget.dragToCloseThreshold != null,
        );
      },
    );
  }

  NavigatorState pushedTo(BuildContext context) =>
      _sourceNavigator ?? Navigator.of(context);

  Widget _buildHeaderWidget(BuildContext context, final dynamic widget) {
    if (widget == null) return null;
    if (widget is Widget) {
      return widget;
    }
    if (widget is HeaderBuilder) {
      return widget(context, _scroller, pushedTo(context));
    }
    throw illegalState("Invalid header type.  Must be Widget or HeaderBuilder");
  }

  Widget get builtCollapsedHeader {
    return _builtCollapsedHeader ??= clippedHeader;
  }

  Widget builtExpandedFooter(BuildContext context) {
    if (_builtExpandedFooter == null) {
      final built = _buildFooter(
        context,
        null,
        ExpandingCardState.expanded,
      );
      _builtExpandedFooter = widget.expandedFooterWrapper != null
          ? widget.expandedFooterWrapper(context, built)
          : built;
    }
    return _builtExpandedFooter;
  }

  Widget get builtCollapsedFooter {
    return _builtCollapsedFooter ??= _buildFooter(
      context,
      null,
      ExpandingCardState.collapsed,
    );
  }

  Widget get clippedHeader {
    final source = widget.preHeader != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                widget.preHeader,
                if (widget.header != null) widget.header,
              ])
        : widget.header;

    return ClipRRect(
      borderRadius: _theme.borderRadius.top,
      child: source,
    );
  }

  Widget _wrapHero(Widget builtCard, ExpandingCardState state,
      [Animation<double> animation]) {
    return Material(
      color: Colors.transparent,
      child: Provider.value(
        value: HeroAnimation(animation, state),
        updateShouldNotify: (a, b) => a != b,
        child: Hero(
          tag: "$_discriminator",
          transitionOnUserGestures: true,
          createRectTween: (start, end) {
            return OvershootingRectTween.ofPosition(begin: start, end: end);
          },
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            /// We use a shuttle builder because we need to keep the
            /// center section empty, and we want to ensure that any
            /// hero elements transition correctly
            ///

            Widget built;
            if (state.isCollapsed) {
              built = _builtWithGesturesCollapsed ??=
                  _buildWithGestures(context, state, animation);
            } else {
              built = _builtWithGesturesExpanded ??=
                  _buildWithGestures(context, state, animation);
            }
            var widget = Provider.value(
              value: HeroAnimation(animation, state),
              child: Material(
                color: Colors.transparent,
                child: built,
              ),
            );
            return widget;
          },
          child: builtCard,
        ),
      ),
    );
  }

  /// Builds just the card for collapsed mode
  Widget _buildCollapsedCard(ExpandingCardState _cardState,
      [Animation<double> animation]) {
    return PlatformCard(
      color: widget.backgroundColor,
      theme: _theme,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.passthrough,
        children: [
          ClipRRect(
              borderRadius: _theme.borderRadius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.header != null) builtCollapsedHeader,
                  ...?widget?.alwaysShown(context),
                  _buildBody(context, _cardState, animation),
                ],
              )),
          if (widget.footer != null)
            builtFooter(context, animation, _cardState),
        ],
      ),
    );
  }

  Widget _buildSticky(ExpandingCardState _cardState,
      {Animation<double> animation, int startIndex = 0}) {
    var count = 0;
    return Container(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final headerWidget in widget.alwaysShown(context).orEmpty())
              if (count++ >= startIndex)
                if (count == 1)
                  Container(
                    color: widget.backgroundColor,
                    child: headerWidget,
                  )
                else
                  Container(
                    color: widget.backgroundColor,
                    child: headerWidget,
                  ),
          ]),
    );
  }

  Widget _buildExpandedPage(BuildContext context) {
    // Safe area
    final built = Material(
      color: Colors.transparent,
      child: _wrapHero(
        Builder(builder: (context) {
//          final mq = MediaQuery.of(context);
          return CupertinoPageScaffold(
            backgroundColor: widget.backgroundColor,
            child: Stack(
              alignment: _cardState == ExpandingCardState.expanded
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              fit: _cardState == ExpandingCardState.expanded
                  ? StackFit.expand
                  : StackFit.passthrough,
              children: [
//                  Column(
//                    mainAxisSize: MainAxisSize.max,
//                    children: [
//                      Container(
//                        height: 130,
//                        color: Colors.transparent,
//                      ),
//                      Expanded(
//                          child: Container(
//                        color: widget.backgroundColor,
//                      )),
//                      Container(
//                        height: _cardState.isCollapsed
//                            ? _footerHeightCollapsed
//                            : _footerHeightExpanded,
//                        color: Colors.transparent,
//                      ),
//                    ],
//                  ),
                Container(
                  padding: _bottomPadding,
                  child:
//                    NestedScrollView(
//                      headerSliverBuilder:
//                          (BuildContext context, bool innerBoxIsScrolled) {
//                        return [
//                          if (widget.header != null)
//                            SliverOverlapAbsorber(
//                              // This widget takes the overlapping behavior of the SliverAppBar,
//                              // and redirects it to the SliverOverlapInjector below. If it is
//                              // missing, then it is possible for the nested "inner" scroll view
//                              // below to end up under the SliverAppBar even when the inner
//                              // scroll view thinks it has not been scrolled.
//                              // This is not necessary if the "headerSliverBuilder" only builds
//                              // widgets that do not overlap the next sliver.
//                              handle: NestedScrollView
//                                  .sliverOverlapAbsorberHandleFor(context),
//                              sliver: builtExpandedHeader2(context),
//                            ),
//                        ];
//                      },
//                      body: Builder(builder: (context) {
                      CustomScrollView(
                    controller: _scroller,
                    slivers: [
//                        SliverOverlapInjector(
//                          // This is the flip side of the SliverOverlapAbsorber
//                          // above.
//                          handle:
//                              NestedScrollView.sliverOverlapAbsorberHandleFor(
//                                  context),
//                        ),

                      builtExpandedHeader(context),
                      if (widget.pinFirst) builtPinnedHeader(context),
//                      SliverOverlapInjector(
//                        handle: _h1Handle,
//                      ),

                      SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: true,
                        child: Container(
                          decoration: BoxDecoration(
                              color: widget.backgroundColor,
                              borderRadius: _theme.borderRadius),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _builtExpandedSticky ??= _buildSticky(
                                  ExpandingCardState.expanded,
                                  startIndex: widget.pinFirst == true ? 1 : 0,
                                  animation: null),
                              _buildMiddleSectionNoInset(
                                  context, ExpandingCardState.expanded),
                            ],
                          ),
                        ),
                      ),
                    ],
//                        );
//                      }),
                  ),
                ),
                if (builtExpandedFooter != null && widget.footer != null)
                  builtExpandedFooter(context),
              ],
            ),
          );
        }),
        ExpandingCardState.expanded,
        null,
      ),
    );
    return widget.expandedWrapper != null
        ? widget.expandedWrapper(context, built)
        : built;
  }

  Widget _buildWithGestures(BuildContext context, ExpandingCardState _cardState,
      [Animation<double> animation]) {
    /// We only want gestures when collapsed
    final card = _buildCollapsedCard(_cardState, animation);
    if (_cardState == ExpandingCardState.collapsed) {
      return Tappable(
        pressScale: Tappable.defaultScale,
        duration: 100.ms,
        pressOpacity: null,
        onTap: (context) async {
          final RenderBox ro = context.findRenderObject() as RenderBox;
          final pb = ro.localToGlobal(Offset.zero);
          final dur = (pb.dy / 400.0).clamp(0.8, 1.5);
          log.info("Dur $dur");
          if (widget.onCardTap != null) {
            widget.onCardTap(context, (context) => _buildExpandedPage(context));
          } else {
            _sourceNavigator =
                Navigator.of(context, rootNavigator: widget.useRootNavigator);

            final routeCreator = widget.buildRoute ??
                ((context, child, distance) {
                  return PageRouteBuilder(
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return child(context);
                    },
                    transitionsBuilder: (context, a1, a2, widget) {
                      return widget;
                    },
                    transitionDuration:
                        ExpandingCard.kDefaultTransitionDuration * distance,
                    opaque: false,
                    barrierColor: Colors.black12,
                    fullscreenDialog: false,
                    maintainState: true,
                  );
                });
            final buildExpandedWidget = (BuildContext context) =>
                _expandedPage ??= _buildExpandedPage(context);
            _sourceNavigator.push(
                routeCreator(context, buildExpandedWidget, dur.toDouble()));
          }
        },
        child: card,
      );
    } else {
      return card;
    }
  }

  /// Builds the middle section, which may have padding from the buttons
  Widget _buildBody(BuildContext context, ExpandingCardState _cardState,
      Animation<double> animation) {
    if (animation != null) {
      return Expanded(child: Container());
    }
    final body = _buildMiddleSectionNoInset(context, _cardState);
    final padded = widget.footer != null
        ? Padding(padding: _bottomPadding, child: body)
        : body;
    return _cardState == ExpandingCardState.expanded
        ? Expanded(child: padded)
        : padded;
  }

  double get _headerHeightExpanded {
    final _header = widget.header;
    return _header is HeroBar
        ? _header.expandedSize?.height ?? _header.preferredSize?.height
        : _header?.preferredSize?.height;
  }

  Widget _buildFooter(
      BuildContext context, Animation<double> anim, ExpandingCardState _state) {
    return widget.footer;
  }

  Widget _build(dynamic widgetOrBuilder, BuildContext context) {
    if (widgetOrBuilder == null) return null;
    if (widgetOrBuilder is Widget) {
      return widgetOrBuilder;
    } else {
      return widgetOrBuilder?.call(context) as Widget;
    }
  }

  Widget _buildMiddleSectionNoInset(
      BuildContext context, ExpandingCardState _cardState) {
    switch (_cardState) {
      case ExpandingCardState.collapsed:
        return _collapsed ??= _build(widget.collapsedSection, context);
      case ExpandingCardState.transitioning:
        return _transition ??= const SizedBox(height: 100);
      case ExpandingCardState.expanded:
        return _expanded ??= Container(
          color: widget.backgroundColor,
          child: _build(widget.expandedSection, context),
        );
      default:
        return _transition ??= const SizedBox(height: 100);
    }
  }
}

//extension _WidgetHeroExt on Widget {
//  Widget withAnimation(
//      BuildContext context, Animation<double> anim, ExpandingCardState state) {
//    final self = this;
//    return (self is HeroHints) ? self.buildCard(context, anim, state) : self;
//  }
//}

extension BorderRadiusExt on BorderRadius {
  BorderRadius get top {
    return BorderRadius.only(topLeft: this.topLeft, topRight: this.topRight);
  }

  BorderRadius get bottom {
    return BorderRadius.only(
        bottomLeft: this.bottomLeft, bottomRight: this.bottomRight);
  }
}

extension ExpansionCardStateExt on ExpandingCardState {
  bool get isExpanded {
    return this == ExpandingCardState.expanded;
  }

  bool get isCollapsed {
    return this == ExpandingCardState.collapsed;
  }
}
