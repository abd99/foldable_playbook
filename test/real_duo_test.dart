// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/posture.dart';

/// The fold a book-shaped iPhone Duo reports: 40 dp wide, top to bottom of
/// the 951 x 669 dp inner display in landscape.
const _bookFold = DisplayFeature(
  bounds: Rect.fromLTWH(455.5, 0, 40, 669),
  type: DisplayFeatureType.fold,
  state: DisplayFeatureState.postureHalfOpened,
);

Future<FoldInfo?> _separatingFoldIn(WidgetTester tester, Size window) async {
  late FoldInfo? found;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: window, displayFeatures: const [_bookFold]),
      child: Builder(
        builder: (context) {
          found = separatingFoldOf(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return found;
}

void main() {
  group('Real iPhone Duo Tests', () {
    testWidgets('Testing if a fold left over from a rotation is ignored', (
      tester,
    ) async {
      // Turned from book to tabletop half open, the Duo reports the fold in
      // its new orientation before Flutter resizes the window. Logged on the
      // device: a 669 dp vertical fold in a window still 951 dp tall, for
      // 130 to 150 ms. It does not cross that window, so it splits nothing.
      expect(await _separatingFoldIn(tester, const Size(669, 951)), isNull);

      // The same fold in the window it belongs to.
      expect(await _separatingFoldIn(tester, const Size(951, 669)), isNotNull);
    });
  });
}
