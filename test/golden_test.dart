// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Goldens are rendered by the host machine, so the images in this repo are
// the ones a Mac produces. Tagging them keeps CI from comparing a Linux
// rendering against them and failing on a pixel nobody can see.
@Tags(['golden'])
library;

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

    testEveryFoldable('Player', (tester, device) async {
      await tester.pumpWidget(
        foldableApp(
          const PanesScreen(),
          device: device,
          halfOpened: device.hasFold,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PanesScreen),
        matchesGoldenFile('goldens/player_${_fileName(device)}.png'),
      );
    });

    testWidgets('Player, flat, on a wide window', (tester) async {
      // The one case the sweep above cannot reach: wide, and no fold to use,
      // so the controls are drawn on the picture.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PanesScreen),
        matchesGoldenFile('goldens/player_flat_wide.png'),
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
