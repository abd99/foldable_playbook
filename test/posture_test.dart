// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/posture.dart';
import 'package:foldable_playbook/screens/posture.dart';

import 'foldables.dart';

void main() {
  group('Window Size Class Tests', () {
    test('Testing the Material breakpoints', () {
      expect(WindowSizeClass.fromWidth(360), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
    });

    test('Testing both Samsung foldables land in medium', () {
      // The Ultra is 5.3 dp short of expanded. An app that only checks for an
      // expanded window shows its phone layout on both of these.
      expect(WindowSizeClass.fromWidth(704), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(834.7), WindowSizeClass.medium);
    });
  });

  group('Fold Info Tests', () {
    test('Testing a hinge with a gap separates', () {
      const hinge = DisplayFeature(
        bounds: Rect.fromLTRB(408, 0, 432, 640),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureFlat,
      );

      const fold = FoldInfo(hinge);

      expect(fold.isVertical, isTrue);
      expect(fold.thickness, 24);
      expect(fold.isSeparating, isTrue);
    });

    test('Testing a flat crease does not separate', () {
      // Nothing to lay out around: the screen is flat and the crease has no
      // thickness.
      const crease = DisplayFeature(
        bounds: Rect.fromLTRB(0, 466.3, 704, 466.3),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      );

      expect(const FoldInfo(crease).isSeparating, isFalse);
    });

    test('Testing the same crease separates once the device is bent', () {
      const crease = DisplayFeature(
        bounds: Rect.fromLTRB(0, 466.3, 704, 466.3),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      );

      expect(const FoldInfo(crease).isSeparating, isTrue);
    });
  });

  group('Posture Screen Widget Tests', () {
    testWidgets('Testing if the fold is reported when the device is bent', (
      tester,
    ) async {
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(
        foldableApp(
          const PostureScreen(),
          device: fold8Inner,
          halfOpened: true,
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
      expect(find.textContaining('half opened'), findsOneWidget);
    });

    testWidgets('Testing if a cutout is counted as a fold', (tester) async {
      // The cover display has a camera but no fold. Counting display features
      // instead of filtering them would report one here.
      useSurface(tester, fold8Cover);
      await tester.pumpWidget(
        foldableApp(const PostureScreen(), device: fold8Cover, cutout: true),
      );

      expect(find.text('cutout, unknown'), findsOneWidget);
      expect(find.text('none'), findsOneWidget);
    });
  });
}
