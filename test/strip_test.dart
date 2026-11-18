// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:duo_kit/duo_kit.dart';
import 'package:duo_kit/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/layout/two_pane.dart';
import 'package:foldable_playbook/widgets/strip_navigation.dart';

void main() {
  group('Strip Tests', () {
    testWidgets('Testing if the divider stays on the fold beside the strip', (
      tester,
    ) async {
      // iPhone Duo half open like a book, as duo_kit measured it: a 40 dp
      // fold at 455.5 and the strip down the right edge. With the navigation
      // in the strip the body is 867 dp wide but the window still says 951,
      // and without StripBody the divider lands at 371.5, 84 dp short.
      final pose = FoldTestPose.duoHalfOpenedLandscape.data;
      final strip = FoldGeometry.fromMediaQuery(pose, detectStrip: true).strip!;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = pose.size;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        // What FoldScaffold hands its body: the strip's padding gone, the
        // size untouched.
        MediaQuery(
          data: pose.removePadding(removeRight: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: pose.size.width - strip.width,
                child: StripBody(
                  strip: strip,
                  child: TwoPane(
                    start: const SizedBox.expand(key: Key('start')),
                    end: const SizedBox.expand(key: Key('end')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(const Key('start'))).right, 455.5);
      expect(tester.getRect(find.byKey(const Key('end'))).left, 495.5);
    });

    testWidgets('Testing if a left-hand strip moves the fold with the body', (
      tester,
    ) async {
      // The cover display in landscape puts the strip on the left. The body
      // starts 84 dp in, so the fold has to move over by the same amount.
      final pose = FoldTestPose.duoCoverLandscapeLeft.data;
      final strip = FoldGeometry.fromMediaQuery(pose, detectStrip: true).strip!;
      late MediaQueryData seen;

      await tester.pumpWidget(
        MediaQuery(
          data: pose.copyWith(
            displayFeatures: const [
              DisplayFeature(
                bounds: Rect.fromLTWH(300, 0, 40, 466),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ],
          ),
          child: StripBody(
            strip: strip,
            child: Builder(
              builder: (context) {
                seen = MediaQuery.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(seen.size, Size(pose.size.width - 84, pose.size.height));
      expect(seen.displayFeatures.single.bounds.left, 216);
    });
  });
}
