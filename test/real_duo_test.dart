// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/posture.dart';

import 'foldables.dart';

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

    testWidgets('Testing if the rail stays below a tabletop fold', (
      tester,
    ) async {
      // Centred over the whole height, the middle destination sat on the
      // crease. In tabletop the rail belongs on the half lying flat.
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(foldableRoot(fold8Inner, halfOpened: true));
      await tester.pumpAndSettle();

      final icons = find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byType(Icon),
      );
      expect(icons, findsWidgets);
      for (final icon in icons.evaluate()) {
        expect(
          tester.getRect(find.byWidget(icon.widget)).top,
          greaterThanOrEqualTo(fold8Inner.fold.bottom),
        );
      }
    });

    testWidgets('Testing if the rail stays centred while the device is flat', (
      tester,
    ) async {
      // Flat, the crease separates nothing, so nothing moves.
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(foldableRoot(fold8Inner));
      await tester.pumpAndSettle();

      final icons = find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byType(Icon),
      );
      final tops = [
        for (final icon in icons.evaluate())
          tester.getRect(find.byWidget(icon.widget)).top,
      ];
      expect(tops.first, lessThan(fold8Inner.fold.top));
    });
  });
}
