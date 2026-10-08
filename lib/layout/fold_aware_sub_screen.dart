// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:foldable_playbook/layout/posture.dart';

/// Keeps [child] on the first side of any fold or hinge, flat or not.
///
/// Flutter's `DisplayFeatureSubScreen`, which every dialog route uses, only
/// avoids a fold that has a gap or is half opened. A crease lying flat, which
/// is all a Galaxy Z Fold 8 ever reports, is ignored, so a dialog is centred
/// across it. Wrap the dialog in this to treat every fold as a boundary.
///
/// ```dart
/// showDialog<void>(
///   context: context,
///   builder: (context) => FoldAwareSubScreen(child: AlertDialog(...)),
/// );
/// ```
class FoldAwareSubScreen extends StatelessWidget {
  const FoldAwareSubScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final folds = foldsOf(context);
    if (folds.isEmpty) return child;

    final fold = folds.first;
    final media = MediaQuery.of(context);
    final size = media.size;

    // The side before the fold: left of a vertical one, above a horizontal
    // one. Bounds are in window coordinates, which is what a dialog route
    // fills, so no inset correction is needed here.
    final side = fold.isVertical
        ? Rect.fromLTRB(
            0,
            0,
            math.max(0.0, math.min(fold.bounds.left, size.width)),
            size.height,
          )
        : Rect.fromLTRB(
            0,
            0,
            size.width,
            math.max(0.0, math.min(fold.bounds.top, size.height)),
          );

    return Padding(
      padding: EdgeInsets.only(
        right: size.width - side.right,
        bottom: size.height - side.bottom,
      ),
      child: MediaQuery(
        data: media.removeDisplayFeatures(side).copyWith(size: side.size),
        child: child,
      ),
    );
  }
}
