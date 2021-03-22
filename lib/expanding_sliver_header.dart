import 'package:flutter/material.dart';

/// The delegate that is provided to [ExpandingSliverPersistentHeader].
abstract class ExpandingSliverPersistentHeaderDelegate {
  double get maxExtent;
  double get minExtent;

  /// This acts exactly like `SliverPersistentHeaderDelegate.build()` but with
  /// the difference that `shrinkOffset` might be negative, in which case,
  /// this widget exceeds `maxExtent`.
  Widget build(BuildContext context, double shrinkOffset);
}

// /// Pretty much the same as `SliverPersistentHeader` but when the user
// /// continues to drag down, the header grows in size, exceeding `maxExtent`.
// class ExpandingSliverPersistentHeader extends SingleChildRenderObjectWidget {
//   final SliverPersistentHeaderDelegate delegate;
//   ExpandingSliverPersistentHeader({
//     Key key,
//     this.delegate,
//   }) : super(key: key, child: _ElSliverPersistentHeaderDelegateWrapper(delegate: delegate));
//
//   @override
//   _ElPersistentHeaderRenderSliver createRenderObject(BuildContext context) {
//     return _ElPersistentHeaderRenderSliver(delegate.maxExtent, delegate.minExtent);
//   }
// }
//
// class _ElSliverPersistentHeaderDelegateWrapper extends StatelessWidget {
//   final SliverPersistentHeaderDelegate delegate;
//
//   _ElSliverPersistentHeaderDelegateWrapper({Key key, this.delegate}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
//         final height = constraints.maxHeight;
//         return delegate.build(context, delegate.maxExtent - height, false);
//       });
// }
//
// class _ElPersistentHeaderRenderSliver extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {
//   final double maxExtent;
//   final double minExtent;
//
//   _ElPersistentHeaderRenderSliver(this.maxExtent, this.minExtent);
//
//   @override
//   bool hitTestChildren(SliverHitTestResult result,
//       {@required double mainAxisPosition, @required double crossAxisPosition}) {
//     if (child != null) {
//       return child.hitTest(result as BoxHitTestResult, position: Offset(crossAxisPosition, mainAxisPosition));
//     }
//     return false;
//   }
//
//   @override
//   void performLayout() {
//     /// The amount of scroll that extends the theoretical limit.
//     /// I.e.: when the user drags down the list, although it already hit the
//     /// top.
//     ///
//     /// This seems to be a bit of a hack, but I haven't found a way to get this
//     /// information in another way.
//     final overScroll = constraints.viewportMainAxisExtent - constraints.remainingPaintExtent;
//
//     /// The actual Size of the widget is the [maxExtent] minus the amount the
//     /// user scrolled, but capped at the [minExtent] (we don't want the widget
//     /// to become smaller than that).
//     /// Additionally, we add the [overScroll] here, since if there *is*
//     /// "over scroll", we want the widget to grow in size and exceed
//     /// [maxExtent].
//     final actualSize = math.max(maxExtent - constraints.scrollOffset + overScroll, minExtent);
//
//     /// Now layout the child with the [actualSize] as `maxExtent`.
//     child.layout(constraints.asBoxConstraints(maxExtent: actualSize));
//
//     /// We "clip" the `paintExtent` to the `maxExtent`, otherwise the list
//     /// below stops moving when reaching the border.
//     ///
//     /// Tbh, I'm not entirely sure why that is.
//     final paintExtent = math.min(actualSize, maxExtent);
//
//     /// For the layout to work properly (i.e.: the following slivers to
//     /// scroll behind this sliver), the `layoutExtent` must not be capped
//     /// at [minExtent], otherwise the next sliver will "stop" scrolling when
//     /// [minExtent] is reached,
//     final layoutExtent = math.max(maxExtent - constraints.scrollOffset, 0.0);
//
//     geometry = SliverGeometry(
//       scrollExtent: maxExtent,
//       paintExtent: paintExtent,
//       layoutExtent: layoutExtent,
//       maxPaintExtent: maxExtent,
//     );
//   }
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     if (child != null) {
//       /// This sliver is always displayed at the top.
//       context.paintChild(child, Offset(0.0, 0.0));
//     }
//   }
//
//   void applyPaintTransform(RenderObject child, Matrix4 transform) {
//     assert(child.parent == this);
//   }
// }
