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

        // Display features are reported in window coordinates, and this pane
        // does not always start at the left edge of the window. Beside a
        // navigation rail it starts a rail's width in, so measure that gap
        // and take it off the fold. Forgetting this puts the divider past
        // the hinge, which looks right in a test that fills the window and
        // wrong on a device.
        final inset = MediaQuery.sizeOf(context).width - width;

        // Only a vertical fold maps onto a list and detail split. A horizontal
        // one means the device is in tabletop, which is a different layout.
        if (fold != null && fold.isVertical) {
          final splitAt = fold.bounds.left - inset;

          // The fold has to actually fall inside this pane. A rail wider than
          // the first half would otherwise push the divider off the left edge.
          if (splitAt > 0 && splitAt + fold.thickness < width) {
            _report(TwoPaneMode.fold);
            return Row(
              children: [
                SizedBox(width: splitAt, child: start),
                SizedBox(width: fold.thickness),
                Expanded(child: end),
              ],
            );
          }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // The same correction as TwoPane, on the other axis. An app bar above
        // this pane means its top edge is not the top of the window.
        final inset = MediaQuery.sizeOf(context).height - height;
        final splitAt = fold.bounds.top - inset;

        if (splitAt <= 0 || splitAt + fold.thickness >= height) {
          return Column(
            children: [
              Expanded(child: top),
              Expanded(child: bottom),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(height: splitAt, child: top),
            SizedBox(height: fold.thickness),
            Expanded(child: bottom),
          ],
        );
      },
    );
  }
}
