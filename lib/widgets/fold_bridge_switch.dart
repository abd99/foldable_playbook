// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show DisplayFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:foldable/foldable.dart';
import 'package:foldable_playbook/models/layout_settings.dart';

/// Decides which bridge's fold the screens below see.
///
/// Both plugins stay mounted above this the whole time. duo_kit's FoldBridge adds its
/// features to `MediaQuery` itself, and the foldable package runs with
/// `bridgeMode: none`, so it only reports, through `DuoMediaQuery`. Taking a
/// plugin in or out of the tree would rebuild everything under it, so the
/// choice is made here instead, and flipping it on the device loses nothing.
class FoldBridgeSwitch extends StatefulWidget {
  const FoldBridgeSwitch({
    super.key,
    required this.bridge,
    required this.child,
  });

  final FoldBridgeChoice bridge;
  final Widget child;

  @override
  State<FoldBridgeSwitch> createState() => _FoldBridgeSwitchState();
}

class _FoldBridgeSwitchState extends State<FoldBridgeSwitch> {
  List<DisplayFeature> _fromFoldable = const [];

  /// `MediaQuery` tells its dependents that the display features changed by
  /// comparing the lists by identity. A fresh list on every update would
  /// rebuild every layout that splits at the fold, so the previous one is
  /// handed back while nothing in it has changed.
  List<DisplayFeature> _keep(List<DisplayFeature> next) {
    if (!listEquals(next, _fromFoldable)) _fromFoldable = next;
    return _fromFoldable;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // Android, or an iPhone without a hinge: whatever the engine reported.
    final features = !DuoMediaQuery.isFoldableOf(context)
        ? media.displayFeatures
        : switch (widget.bridge) {
            FoldBridgeChoice.none => const <DisplayFeature>[],
            // The same rules FoldableProvider applies in full mode, run on
            // what it reports.
            FoldBridgeChoice.foldable => _keep(
              DisplayFeatureBridge.build(
                mode: DisplayFeatureBridgeMode.full,
                regions: DuoMediaQuery.regionsOf(context),
                status: DuoMediaQuery.statusOf(context),
              ),
            ),
            // Already added above this by duo_kit's FoldBridge.
            FoldBridgeChoice.duoKit => media.displayFeatures,
          };

    // Always a MediaQuery here, whichever branch, so the tree keeps its shape.
    return MediaQuery(
      data: media.copyWith(displayFeatures: features),
      child: widget.child,
    );
  }
}
