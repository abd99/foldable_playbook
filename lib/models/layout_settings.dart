// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// App-wide layout switches, so the effect of each can be seen on a device.
class LayoutSettings extends ChangeNotifier {
  bool _safeArea = true;

  /// Whether the app keeps its content clear of the status bar, the camera
  /// and the home indicator.
  bool get safeArea => _safeArea;

  void toggleSafeArea() {
    _safeArea = !_safeArea;
    notifyListeners();
  }
}
