// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Where the fold in `MediaQuery.displayFeatures` comes from on iOS, where the
/// engine itself reports nothing.
enum FoldBridgeChoice {
  /// Nothing, which is what Flutter does on its own.
  none('none'),

  /// The foldable package. It publishes the fold once Apple marks the region
  /// active, which on a real iPhone Duo is about 300 ms after the hinge stops
  /// moving.
  foldable('foldable'),

  /// LeanCode's duo_kit, through its FoldBridge. It publishes the fold as soon
  /// as the hinge reads partly open, and keeps publishing the camera and the
  /// status cluster while the device is closed.
  duoKit('duo_kit');

  const FoldBridgeChoice(this.label);

  final String label;
}

/// App-wide layout switches, so the effect of each can be seen on a device.
class LayoutSettings extends ChangeNotifier {
  bool _safeArea = true;
  FoldBridgeChoice _bridge = FoldBridgeChoice.foldable;
  bool _stripNavigation = true;
  bool _geometryOverlay = false;

  /// Whether the app keeps its content clear of the status bar, the camera
  /// and the home indicator.
  bool get safeArea => _safeArea;

  /// Which plugin's fold the screens see on iOS. Android ignores it.
  FoldBridgeChoice get bridge => _bridge;

  /// Whether the navigation moves into the strip iPhone Duo keeps beside the
  /// window, where there is one.
  bool get stripNavigation => _stripNavigation;

  /// Whether duo_kit paints the strip, the fold and the occlusions it found
  /// over the app.
  bool get geometryOverlay => _geometryOverlay;

  void toggleSafeArea() {
    _safeArea = !_safeArea;
    notifyListeners();
  }

  void selectBridge(FoldBridgeChoice bridge) {
    if (bridge == _bridge) return;
    _bridge = bridge;
    notifyListeners();
  }

  void toggleStripNavigation() {
    _stripNavigation = !_stripNavigation;
    notifyListeners();
  }

  void toggleGeometryOverlay() {
    _geometryOverlay = !_geometryOverlay;
    notifyListeners();
  }
}
