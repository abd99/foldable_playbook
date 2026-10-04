// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/two_pane.dart';
import 'package:foldable_playbook/screens/panes.dart';

import 'foldables.dart';

void main() {
  group('Two Pane Widget Tests', () {
    testWidgets('Testing if a narrow window keeps one pane', (tester) async {
      useSurface(tester, fold8Cover);
      await tester.pumpWidget(
        foldableApp(
          TwoPane(
            start: const Text('List'),
            end: const Text('Detail'),
          ),
          device: fold8Cover,
        ),
      );

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets('Testing if a wide window splits', (tester) async {
      useSurface(tester, bookHinge);
      await tester.pumpWidget(
        foldableApp(
          TwoPane(
            start: const Text('List'),
            end: const Text('Detail'),
          ),
          device: bookHinge,
          halfOpened: true,
        ),
      );

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
    });

    testWidgets('Testing if the split lands on the hinge', (tester) async {
      useSurface(tester, bookHinge);
      await tester.pumpWidget(
        foldableApp(
          TwoPane(
            start: const Text('List'),
            end: const Text('Detail'),
          ),
          device: bookHinge,
          halfOpened: true,
        ),
      );

      // Neither pane may reach into the 24 dp gap between the halves.
      expectClearOfFold(tester, find.text('List'), bookHinge);
      expectClearOfFold(tester, find.text('Detail'), bookHinge);
    });

    testWidgets('Testing if the panes meet on a crease with no gap', (
      tester,
    ) async {
      // There is nothing to leave empty on the Pixel Fold, so the two panes
      // should touch along the crease instead of straddling it.
      useSurface(tester, pixelFoldInner);
      await tester.pumpWidget(
        foldableApp(
          TwoPane(
            start: const Text('List'),
            end: const Text('Detail'),
          ),
          device: pixelFoldInner,
          halfOpened: true,
        ),
      );

      expectClearOfFold(tester, find.text('List'), pixelFoldInner);
      expectClearOfFold(tester, find.text('Detail'), pixelFoldInner);
    });

    testWidgets('Testing if a tabletop fold is left to the other layout', (
      tester,
    ) async {
      // The Fold 8 fold runs across the window, which is a tabletop layout,
      // not a list and detail one. TwoPane should split on width instead.
      useSurface(tester, fold8Inner);
      late TwoPaneMode mode;

      await tester.pumpWidget(
        foldableApp(
          TwoPane(
            start: const Text('List'),
            end: const Text('Detail'),
            onModeChanged: (value) => mode = value,
          ),
          device: fold8Inner,
          halfOpened: true,
        ),
      );
      await tester.pump();

      expect(mode, TwoPaneMode.flex);
    });
  });

  group('Panes Screen Widget Tests', () {
    testWidgets('Testing if selecting an item changes the detail pane', (
      tester,
    ) async {
      useSurface(tester, bookHinge);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: bookHinge, halfOpened: true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tabletop'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Content up, controls down'), findsOneWidget);
    });
  });
}
