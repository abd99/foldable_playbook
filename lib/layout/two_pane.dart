// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/posture.dart';

/// How a [TwoPane] decided to lay itself out.
enum TwoPaneMode {
  /// Not enough width for two panes, so only the start pane is shown.
  single,

  /// Two panes, split on [TwoPane.startFlex] because there is no fold to use.
  flex,

  /// Two panes, split at the fold, with the hinge left empty.
  fold,
}

/// Shows [start] and [end] side by side, putting the divider on the hinge when
/// the window has one.
///
/// On a device with a real hinge gap, the space between the panes is where the
/// hardware already is, so nothing is lost. On a crease the gap keeps text off
/// the part of the screen that bends.
class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.start,
    required this.end,
    this.startFlex = 0.4,
    this.minWidth = 600,
    this.onModeChanged,
  });

  final Widget start;
  final Widget end;

  /// The share of the width given to [start] when there is no fold.
  final double startFlex;

  /// The narrowest window that still gets two panes. Defaults to the Material
  /// medium breakpoint, which both Samsung foldables clear when unfolded.
  final double minWidth;

  /// Called with the layout decision. Used by the demo to show what happened,
  /// and by tests to assert on it.
  final ValueChanged<TwoPaneMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    final fold = separatingFoldOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < minWidth) {
          _report(TwoPaneMode.single);
          return start;
        }

        // Only a vertical fold maps onto a list and detail split. A horizontal
        // one means the device is in tabletop, which is a different layout.
        if (fold != null && fold.isVertical) {
          _report(TwoPaneMode.fold);
          return Row(
            children: [
              SizedBox(width: fold.bounds.left, child: start),
              SizedBox(width: fold.thickness),
              Expanded(child: end),
            ],
          );
        }

        _report(TwoPaneMode.flex);
        return Row(
          children: [
            SizedBox(width: width * startFlex, child: start),
            const VerticalDivider(width: 1),
            Expanded(child: end),
          ],
        );
      },
    );
  }

  void _report(TwoPaneMode mode) {
    if (onModeChanged == null) return;
    // The mode is decided during layout, so tell the listener after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => onModeChanged!(mode));
  }
}

/// Stacks [top] and [bottom] around a horizontal fold.
///
/// This is the tabletop layout: the device is stood up like a laptop, so the
/// top half is what the user looks at and the bottom half is where they reach.
class TabletopPane extends StatelessWidget {
  const TabletopPane({super.key, required this.top, required this.bottom});

  final Widget top;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    final fold = separatingFoldOf(context);

    if (fold == null || fold.isVertical) {
      return Column(
        children: [
          Expanded(child: top),
          Expanded(child: bottom),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(height: fold.bounds.top, child: top),
        SizedBox(height: fold.thickness),
        Expanded(child: bottom),
      ],
    );
  }
}
