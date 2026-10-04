// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/screens/panes.dart';

import 'foldables.dart';

// Goldens catch the mistakes an expect call does not think to look for, like
// a line of text sitting in the hinge. Run flutter test --update-goldens
// after an intentional change, then look at the images before committing.
void main() {
  group('Golden Tests', () {
    testEveryFoldable('Panes', (tester, device) async {
      await tester.pumpWidget(
        foldableApp(
          const PanesScreen(),
          device: device,
          halfOpened: device.hasFold,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PanesScreen),
        matchesGoldenFile('goldens/panes_${_fileName(device)}.png'),
      );
    });

    testEveryFoldable('Navigation', (tester, device) async {
      await tester.pumpWidget(foldableRoot(device));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/navigation_${_fileName(device)}.png'),
      );
    });
  });
}

String _fileName(Foldable device) =>
    device.name.toLowerCase().replaceAll(' ', '_');
