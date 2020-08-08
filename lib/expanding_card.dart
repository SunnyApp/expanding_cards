import 'package:expanding_cards/drag_to_shrink.dart';
import 'package:expanding_cards/expanding_card_route.dart';
import 'package:expanding_cards/platform_card.dart';
import 'package:expanding_cards/platform_card_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
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

/// Used to decorate the expanded card
typedef ExpandedCardWrapper = Widget Function(
    BuildContext context, Widget child);

/// Displays the trip with an item or something else
///
class ExpandingCard extends StatefulWidget {
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

  /// A list of elements that are always displayed at the top of the card
  final List<Widget> alwaysShown;

  /// A unique id that identifies this card from otherss
  final String discriminator;

  /// A theme for the underlying card.  You can also use a `Provider` to use global
  /// styles
  final PlatformCardTheme theme;

  /// The distance to pull before the card collapses
  final double dragToCloseThreshold;

  /// Whether to show a close button
  final bool showClose;

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

  /// The background of the card
  final Color backgroundColor;

  final bool useRootNavigator;

  const ExpandingCard({
    Key key,
    this.dragToCloseThreshold = 30,
    this.expandedSection,
    this.collapsedSection,
    this.footer,
    this.header,
    this.theme,
    this.discriminator,
    this.onCardTap,
    this.expandedFooterWrapper,
    this.expandedWrapper,
    this.showClose = false,
    this.useRootNavigator = false,
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

class _ExpandingCardState extends State<ExpandingCard>
    with SingleTickerProviderStateMixin {
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
  Widget _builtCollapsedHeader;

  Widget _builtExpandedFooter;
  Widget _builtCollapsedFooter;

  Widget _builtExpandedSticky;
  Widget _builtWithGestures;
  Widget _builtWithGesturesExpanded;
  Widget _builtWithGesturesCollapsed;

  Widget _expandedPage;

  NavigatorState _pushedTo;

  @override
  void initState() {
    super.initState();
    _bottomPadding = widget.footer != null
        ? EdgeInsets.only(bottom: widget.footer.preferredSize.height)
        : EdgeInsets.zero;
    _discriminator = widget.discriminator ?? uuid();
    _controller = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _theme = widget.theme;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme ??= PlatformCardTheme.of(context);
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

  Widget builtExpandedHeader(BuildContext context) {
    return _builtExpandedHeader ??= SliverAppBar(
      pinned: true,
      expandedHeight: _headerHeightExpanded - 44,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: clippedHeader,
        collapseMode: CollapseMode.pin,
        stretchModes: [StretchMode.zoomBackground],
      ),
      automaticallyImplyLeading: widget.showClose,
      onStretchTrigger: () async {
        Future.microtask(() => _pushedTo.pop(true));
      },
      stretchTriggerOffset: widget.dragToCloseThreshold,
      stretch: widget.dragToCloseThreshold != null,
    );
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
    return ClipRRect(
      borderRadius: _theme.borderRadius.top,
      child: widget.header,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) builtCollapsedHeader,
                ...?widget?.alwaysShown,
                _buildBody(context, _cardState, animation),
              ],
            ),
            if (widget.footer != null)
              builtFooter(context, animation, _cardState),
          ]),
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
            for (final headerWidget in widget.alwaysShown.orEmpty())
              if (count++ >= startIndex)
                if (count == 1)
                  ClipRRect(
                      borderRadius: _theme.borderRadius.top,
                      child: Container(
                        color: widget.backgroundColor,
                        child: headerWidget,
                      ))
                else
                  Container(
                    color: widget.backgroundColor,
                    child: headerWidget,
                  ),
          ]),
    );
  }

  Widget _buildExpandedPage(BuildContext context) {
    final built = Material(
      color: Colors.transparent,
      child: DragToShrink(
        child: _wrapHero(
          Builder(builder: (context) {
            return Scaffold(
//                            backgroundColor: widget.backgroundColor,
              backgroundColor: Colors.transparent,
              body: Stack(
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
                    child: CustomScrollView(
                      slivers: [
                        if (widget.header != null) builtExpandedHeader(context),
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
                                    startIndex: 0,
                                    animation: null),
                                _buildMiddleSectionNoInset(
                                    context, ExpandingCardState.expanded),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (builtExpandedFooter != null) builtExpandedFooter(context),
                ],
              ),
            );
          }),
          ExpandingCardState.expanded,
          null,
        ),
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
      return GestureDetector(
        onTap: () {
          if (widget.onCardTap != null) {
            widget.onCardTap(context, (context) => _buildExpandedPage(context));
          } else {
            _pushedTo =
                Navigator.of(context, rootNavigator: widget.useRootNavigator);
            _pushedTo.push(ExpandingCardRoute(
              fullscreenDialog: true,
              maintainState: true,
              builder: (context) {
                return _expandedPage ??= _buildExpandedPage(context);
              },
            ));
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
    if (widget.footer == null) return null;
    return ClipRRect(
      borderRadius: _theme.borderRadius.bottom,
      child: widget.footer,
    );
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

extension _BorderRadiusExt on BorderRadius {
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
