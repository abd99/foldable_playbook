// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show DisplayFeature;

import 'package:duo_kit/duo_kit.dart';
import 'package:flutter/material.dart';
import 'package:foldable_playbook/widgets/adaptive_nav.dart';

/// Cuts the window down to the part the body covers once the navigation has
/// moved into the strip.
///
/// FoldScaffold takes the strip's padding away from the body but leaves the
/// window size alone, so a body beside a right-hand strip still reads 951 dp
/// on an iPhone Duo while it is 867 dp wide. TwoPane works out where it sits
/// from that difference and would put the divider 84 dp short of the fold.
/// Here the window ends where the strip begins, and on a left-hand strip the
/// fold moves over with the body, the same way FoldSafeArea treats an inset.
class StripBody extends StatelessWidget {
  const StripBody({super.key, required this.strip, required this.child});

  final FoldStrip strip;
  final Widget child;

  /// The strip beside the body, while the navigation sits in it.
  ///
  /// The body cannot find it from MediaQuery, since FoldScaffold took the
  /// strip's padding away from it.
  static FoldStrip? stripOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StripScope>()?.strip;

  @override
  Widget build(BuildContext context) {
    return _StripScope(strip: strip, child: _resized(context));
  }

  Widget _resized(BuildContext context) {
    final media = MediaQuery.of(context);
    final shift = Offset(strip.side == FoldStripSide.left ? strip.width : 0, 0);

    return MediaQuery(
      data: media.copyWith(
        size: Size(media.size.width - strip.width, media.size.height),
        displayFeatures: [
          for (final feature in media.displayFeatures)
            DisplayFeature(
              bounds: feature.bounds.shift(-shift),
              type: feature.type,
              state: feature.state,
            ),
        ],
      ),
      child: child,
    );
  }
}

class _StripScope extends InheritedWidget {
  const _StripScope({required this.strip, required super.child});

  final FoldStrip strip;

  @override
  bool updateShouldNotify(_StripScope oldWidget) => strip != oldWidget.strip;
}

/// The destinations stacked in the strip iPhone Duo keeps along one side of
/// the window, under its camera and status cluster.
///
/// duo_kit's FoldScaffold decides where the strip is and hands this the
/// padding of that spot: the camera and the status cluster above, the home
/// indicator below. The SafeArea here is what keeps the items clear of them.
class StripNavigation extends StatelessWidget {
  const StripNavigation({
    super.key,
    required this.placement,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final FoldNavigationPlacement placement;
  final List<Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final rail = SafeArea(
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        groupAlignment: 0,
        destinations: [
          for (final destination in destinations)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              // The strip is 84 dp, narrower than a rail likes to be, and
              // "Coherence" broke over two lines. Shrinking the longest label
              // beats wrapping it.
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(destination.label, maxLines: 1),
              ),
            ),
        ],
      ),
    );

    // The divider goes on the edge that faces the content.
    const divider = VerticalDivider(width: 1);
    return Row(
      children: placement == FoldNavigationPlacement.left
          ? [Expanded(child: rail), divider]
          : [divider, Expanded(child: rail)],
    );
  }
}
