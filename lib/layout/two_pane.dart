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
class TwoPane extends StatefulWidget {
  const TwoPane({
    super.key,
    required this.start,
    required this.end,
    this.startFlex = 0.4,
    this.minWidth = 600,
    this.onModeChanged,
    this.onStartFlexChanged,
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

  /// Called while the divider is dragged, with the new share for [start].
  ///
  /// Only a flex split can be dragged. When the divider is the hinge, the
  /// hardware decides where it goes, so there is nothing to drag.
  final ValueChanged<double>? onStartFlexChanged;

  @override
  State<TwoPane> createState() => _TwoPaneState();
}

class _TwoPaneState extends State<TwoPane> {
  // A drag should track the finger, so the split only animates when something
  // else moves it: a fold arriving, or the device being bent.
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final fold = separatingFoldOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < widget.minWidth) {
          _report(TwoPaneMode.single);
          return widget.start;
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
            return _Split(
              startExtent: splitAt,
              gap: SizedBox(width: fold.thickness),
              animate: !_dragging,
              start: widget.start,
              end: widget.end,
            );
          }
        }

        _report(TwoPaneMode.flex);
        final startWidth = width * widget.startFlex;

        return _Split(
          startExtent: startWidth,
          animate: !_dragging,
          gap: widget.onStartFlexChanged == null
              ? const VerticalDivider(width: 1)
              : _DragHandle(
                  onStart: () => setState(() => _dragging = true),
                  onEnd: () => setState(() => _dragging = false),
                  onDelta: (dx) => widget.onStartFlexChanged!(
                    ((startWidth + dx) / width).clamp(0.25, 0.65),
                  ),
                ),
          start: widget.start,
          end: widget.end,
        );
      },
    );
  }

  void _report(TwoPaneMode mode) {
    if (widget.onModeChanged == null) return;
    // The mode is decided during layout, so tell the listener after the frame.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onModeChanged!(mode),
    );
  }
}

/// Two panes with a divider between them, animating when the divider moves on
/// its own.
///
/// Folding the device is a layout change, not a jump cut. Sliding the divider
/// onto the crease also makes it obvious, from the back of a room, that the
/// hardware moved it.
class _Split extends StatelessWidget {
  const _Split({
    required this.startExtent,
    required this.gap,
    required this.animate,
    required this.start,
    required this.end,
    this.axis = Axis.horizontal,
  });

  /// The width of [start] across a vertical fold, or its height under a
  /// horizontal one.
  final double startExtent;
  final Widget gap;
  final bool animate;
  final Widget start;
  final Widget end;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: startExtent, end: startExtent),
      duration: animate ? const Duration(milliseconds: 260) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, extent, child) {
        final first = axis == Axis.horizontal
            ? SizedBox(width: extent, child: start)
            : SizedBox(height: extent, child: start);
        final children = [first, gap, Expanded(child: end)];

        return axis == Axis.horizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}

/// The divider of a flex split, with enough width to grab.
///
/// A one pixel line is a fine divider and a terrible target, so the line keeps
/// its weight and the hit area around it does the work.
class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.onDelta,
    required this.onStart,
    required this.onEnd,
  });

  final ValueChanged<double> onDelta;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: const Key('pane-handle'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => onStart(),
        onHorizontalDragUpdate: (details) => onDelta(details.delta.dx),
        onHorizontalDragEnd: (_) => onEnd(),
        onHorizontalDragCancel: onEnd,
        child: SizedBox(
          width: 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const VerticalDivider(width: 1),
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // The same correction as TwoPane, on the other axis. An app bar above
        // this pane means its top edge is not the top of the window.
        final inset = MediaQuery.sizeOf(context).height - height;

        // With no crease to work around, halve it. Going through the same
        // split either way means bending the device slides the boundary from
        // the middle onto the crease instead of jumping there.
        var splitAt = height / 2;
        var gap = 0.0;

        if (fold != null && !fold.isVertical) {
          final at = fold.bounds.top - inset;
          if (at > 0 && at + fold.thickness < height) {
            splitAt = at;
            gap = fold.thickness;
          }
        }

        return _Split(
          axis: Axis.vertical,
          startExtent: splitAt,
          gap: SizedBox(height: gap),
          animate: true,
          start: top,
          end: bottom,
        );
      },
    );
  }
}
