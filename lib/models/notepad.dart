// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Holds what the user typed and tapped, so the Coherence screen can show that
/// folding the device does not reset it.
class Notepad extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();

  int _taps = 0;
  int get taps => _taps;

  void tap() {
    _taps++;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
