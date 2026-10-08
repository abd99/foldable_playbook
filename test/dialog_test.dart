// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/screens/coherence.dart';

import 'foldables.dart';

/// The visible dialog, not the whole area its route covers.
Rect _dialogSurface(WidgetTester tester) {
  return tester.getRect(
    find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Material),
        )
        .first,
  );
}

Future<void> _open(WidgetTester tester, String button) async {
  await tester.ensureVisible(find.text(button));
  await tester.tap(find.text(button));
  await tester.pumpAndSettle();
}

void main() {
  final crease = fold8Book.fold.left;

  group('Dialog Widget Tests', () {
    testWidgets('Testing if a dialog crosses a flat crease', (tester) async {
      // What a Fold 8 always reports: a fold with no thickness, lying flat.
      // DisplayFeatureSubScreen only avoids a fold with a gap or a bent one,
      // so the dialog is centred across the crease.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const CoherenceScreen(), device: fold8Book),
      );
      await _open(tester, 'Open a dialog');

      final rect = _dialogSurface(tester);
      expect(rect.left, lessThan(crease));
      expect(rect.right, greaterThan(crease));
    });

    testWidgets('Testing if a dialog avoids a bent fold', (tester) async {
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(
          const CoherenceScreen(),
          device: fold8Book,
          halfOpened: true,
        ),
      );
      await _open(tester, 'Open a dialog');

      expect(_dialogSurface(tester).right, lessThanOrEqualTo(crease));
    });

    testWidgets('Testing if the fold aware dialog avoids a flat crease', (
      tester,
    ) async {
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const CoherenceScreen(), device: fold8Book),
      );
      await _open(tester, 'Keep it off any fold');

      expect(_dialogSurface(tester).right, lessThanOrEqualTo(crease));
    });
  });
}
