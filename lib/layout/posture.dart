// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Material 3 window size classes, by width in logical pixels.
///
/// The Fold 8 inner display is [expanded] when opened like a book (932.6 dp)
/// and [medium] when turned (704 dp). The Ultra is 834.7 dp in landscape,
/// which misses [expanded] by 5.3 dp. The size class follows the window, not
/// the device, so the same phone can be either.
enum WindowSizeClass {
  compact('Compact', 0, 600),
  medium('Medium', 600, 840),
  expanded('Expanded', 840, 1200),
  large('Large', 1200, 1600),
  extraLarge('Extra-large', 1600, double.infinity);

  const WindowSizeClass(this.label, this.minWidth, this.maxWidth);

  final String label;
  final double minWidth;
  final double maxWidth;

  /// The size class for the window [context] is being built in.
  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static WindowSizeClass fromWidth(double width) {
    for (final sizeClass in values) {
      if (width >= sizeClass.minWidth && width < sizeClass.maxWidth) {
        return sizeClass;
      }
    }
    return extraLarge;
  }
}

/// A fold or hinge, with the two properties Flutter leaves out.
class FoldInfo {
  const FoldInfo(this.feature);

  final DisplayFeature feature;

  Rect get bounds => feature.bounds;

  /// Whether the fold runs top to bottom, splitting the window left and right.
  ///
  /// Jetpack reports this as `FoldingFeature.orientation`, but it does not
  /// cross over to Flutter, so work it out from the bounds instead.
  bool get isVertical => bounds.height > bounds.width;

  /// How much of the screen the fold covers. A hinge has a real gap, a crease
  /// is zero.
  double get thickness => isVertical ? bounds.width : bounds.height;

  bool get isHalfOpened =>
      feature.state == DisplayFeatureState.postureHalfOpened;

  /// Whether the fold actually divides the window into two parts.
  ///
  /// Jetpack reports this as `FoldingFeature.isSeparating`. A hinge with a gap
  /// always separates, and so does a half opened device. A crease lying flat
  /// under the display does not, and splitting a layout around it leaves the
  /// user with two narrow panes on a screen they are holding as one.
  bool get isSeparating => thickness > 0 || isHalfOpened;
}

/// The folds and hinges in [context], ignoring everything else.
///
/// `displayFeatures` is not a list of folds. A camera cutout is reported in
/// the same list, so code like `if (displayFeatures.isNotEmpty) split()` ends
/// up splitting the layout around a 27 x 40 dp hole.
List<FoldInfo> foldsOf(BuildContext context) {
  return [
    for (final feature in MediaQuery.displayFeaturesOf(context))
      if (feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge)
        FoldInfo(feature),
  ];
}

/// The first fold in [context] that layout should work around, if any.
FoldInfo? separatingFoldOf(BuildContext context) {
  for (final fold in foldsOf(context)) {
    if (fold.isSeparating) return fold;
  }
  return null;
}
