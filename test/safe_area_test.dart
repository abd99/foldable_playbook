// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/two_pane.dart';
import 'package:foldable_playbook/widgets/fold_safe_area.dart';

import 'foldables.dart';

/// A window with system insets and one fold, as a status bar and a home
/// indicator would leave it.
Widget insetWindow({
  required Size size,
  required EdgeInsets padding,
  required DisplayFeature fold,
  required Widget child,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size, padding: padding, displayFeatures: [fold]),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: FoldSafeArea(enabled: true, child: child),
    ),
  );
}

void useWindow(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  group('Fold Safe Area Tests', () {
    testWidgets('Testing if the divider stays on the hinge inside it', (
      tester,
    ) async {
      // A plain SafeArea moves the panes 44 dp left of a right-hand status
      // bar but leaves the fold where it was, so the divider lands at 364
      // against a hinge at 408. The fold has to move with the content.
      useWindow(tester, const Size(840, 640));
      await tester.pumpWidget(
        insetWindow(
          size: const Size(840, 640),
          padding: const EdgeInsets.only(right: 44),
          fold: const DisplayFeature(
            bounds: Rect.fromLTRB(408, 0, 432, 640),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
          child: Row(
            children: [
              const SizedBox(width: 80),
              Expanded(
                child: TwoPane(
                  start: const SizedBox.expand(key: Key('start')),
                  end: const SizedBox.expand(key: Key('end')),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(const Key('start'))).right, 408);
      expect(tester.getRect(find.byKey(const Key('end'))).left, 432);
    });

    testWidgets('Testing if a tabletop split survives a top and bottom inset', (
      tester,
    ) async {
      // A status bar above and a home indicator below shift the panes on the
      // other axis. The boundary still belongs on the crease.
      useWindow(tester, fold8Inner.size);
      await tester.pumpWidget(
        insetWindow(
          size: fold8Inner.size,
          padding: const EdgeInsets.only(top: 24, bottom: 34),
          fold: DisplayFeature(
            bounds: fold8Inner.fold,
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
          child: const TabletopPane(
            top: SizedBox.expand(key: Key('top')),
            bottom: SizedBox.expand(key: Key('bottom')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(const Key('top'))).bottom,
        closeTo(fold8Inner.fold.top, 0.5),
      );
    });
  });

  group('Safe Area Toggle Tests', () {
    testWidgets('Testing if the toggle switches the safe area', (tester) async {
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(foldableRoot(fold8Inner));
      await tester.pumpAndSettle();

      bool switchedOn() => tester.widget<Switch>(find.byType(Switch)).value;

      expect(switchedOn(), isTrue);

      await tester.tap(find.byKey(const Key('safe-area-switch')));
      await tester.pumpAndSettle();

      expect(switchedOn(), isFalse);
    });

    testWidgets('Testing if toggling it keeps the same scaffold', (
      tester,
    ) async {
      // The safe area is switched off rather than taken out of the tree, so
      // the scaffold under it is the same object afterwards, not a new one.
      // The screens would survive either way, because go_router keeps them in
      // keyed navigators; the scaffold would not.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(foldableRoot(fold8Book));
      await tester.pumpAndSettle();

      final before = tester.state<ScaffoldState>(find.byType(Scaffold).first);

      await tester.tap(find.byKey(const Key('safe-area-switch')));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold).first),
        same(before),
      );
    });
  });
}
