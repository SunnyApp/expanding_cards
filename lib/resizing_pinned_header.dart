import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef SizedWidgetBuilder = Widget Function(
    double height, double ratio, Widget? child);
typedef ShouldRebuild = bool Function(
    double extent, double ratio, bool overlapsContent);

class ResizingPinnedHeader extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  final Widget? child;
  @override
  final double minExtent;
  final SizedWidgetBuilder builder;
  final String? debugLabel;

  /// Whether we've exceeded our shouldRebuild
  bool isExceeded = false;

  Widget? _lastBuilt;
  final ShouldRebuild shouldRebuildFn;
  final OverScrollHeaderStretchConfiguration? stretchConfiguration;
  ResizingPinnedHeader(
      {required this.expandedHeight,
      this.debugLabel,
      this.child,
      this.stretchConfiguration,
      this.minExtent = kToolbarHeight,
      ShouldRebuild? shouldRebuildFn,
      required this.builder})
      : shouldRebuildFn = shouldRebuildFn ??
            ((extent, ratio, overlapsContent) => ratio > 0 && ratio < 1.5);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final currExtent = (expandedHeight - shrinkOffset)
        .clamp(minExtent, expandedHeight)
        .toDouble();
    final rem = currExtent - minExtent;
    final ratio = rem == 0 ? 0.0 : rem / (expandedHeight - minExtent);
    var shouldRebuild = shouldRebuildFn(currExtent, ratio, overlapsContent);
    if (_lastBuilt == null || shouldRebuild) {
      isExceeded = false;
//      print("${debugLabel ?? 'test'}: "
//          "extent: $currExtent; rem: ${currExtent - minExtent}; "
//          "ratio: $ratio; shrink: $shrinkOffset; "
//          "overlap: $overlapsContent");
      /// i changed the min to always be at least as large as the max
      _lastBuilt = FlexibleSpaceBar.createSettings(
        toolbarOpacity: 1,
        minExtent: minExtent.roundToDouble(),
        maxExtent:
            max(minExtent.roundToDouble(), expandedHeight - shrinkOffset),
        currentExtent: currExtent,
        child: builder(currExtent, ratio, child),
      );
    } else if (!shouldRebuild && !isExceeded) {
      /// i changed the min to always be at least as large as the max
      _lastBuilt = FlexibleSpaceBar.createSettings(
        toolbarOpacity: 1,
        minExtent: minExtent.roundToDouble(),
        maxExtent:
            max(minExtent.roundToDouble(), expandedHeight - shrinkOffset),
        currentExtent: currExtent,
        child: builder(currExtent, ratio, child),
      );
      isExceeded = true;
    }
    return _lastBuilt!;
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class FixedPinnedHeader extends SliverPersistentHeaderDelegate {
  final double fixedHeight;
  final Widget child;

  const FixedPinnedHeader({required this.fixedHeight, required this.child});

  FixedPinnedHeader.ofPreferredSize({required PreferredSizeWidget child})
      : child = child,
        fixedHeight = child.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => fixedHeight;

  @override
  double get minExtent => fixedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
