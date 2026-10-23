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
          TwoPane(start: const Text('List'), end: const Text('Detail')),
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
          TwoPane(start: const Text('List'), end: const Text('Detail')),
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
          TwoPane(start: const Text('List'), end: const Text('Detail')),
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
          TwoPane(start: const Text('List'), end: const Text('Detail')),
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

  group('Panes Beside Navigation Tests', () {
    testWidgets('Testing if the split lands on the hinge next to a rail', (
      tester,
    ) async {
      // The panes sit to the right of the navigation rail, so the left edge
      // of the pane is not the left edge of the window. Display features are
      // reported in window coordinates, and forgetting that puts the divider
      // a rail's width past the hinge.
      useSurface(tester, bookHinge);
      await tester.pumpWidget(foldableRoot(bookHinge, halfOpened: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Panes'));
      await tester.pumpAndSettle();

      expectClearOfFold(
        tester,
        find.widgetWithText(ListTile, 'Moby-Dick'),
        bookHinge,
      );
    });
  });

  group('Draggable Divider Tests', () {
    testWidgets('Testing if a flex split can be dragged', (tester) async {
      // A Fold 8 lying flat reports a crease with no thickness, which does
      // not separate, so the reader falls back to a width split. That one is
      // the user's to move.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      final shelf = find.widgetWithText(ListTile, 'Moby-Dick');
      final before = tester.getRect(shelf).width;

      // The first few pixels of any drag are eaten by the touch slop, so the
      // pane grows by a little less than the gesture.
      await tester.drag(
        find.byKey(const Key('pane-handle')),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(shelf).width, greaterThan(before + 80));
    });

    testWidgets('Testing if a split at the fold cannot be dragged', (
      tester,
    ) async {
      // Bend the same device and the divider becomes the hinge. The hardware
      // decides where that goes, so there is no handle to grab.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book, halfOpened: true),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pane-handle')), findsNothing);
    });
  });

  group('Posture Transition Tests', () {
    testWidgets('Testing if the divider slides onto the crease when bent', (
      tester,
    ) async {
      // Flat, the reader splits on width at 0.4. Bent, the crease at 466.3
      // takes over. The divider should travel between the two, not teleport.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      final shelf = find.widgetWithText(ListTile, 'Moby-Dick');
      final flat = tester.getRect(shelf).width;

      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book, halfOpened: true),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));

      final midFlight = tester.getRect(shelf).width;
      expect(midFlight, greaterThan(flat));
      expect(midFlight, lessThan(466.3));

      await tester.pumpAndSettle();
      expect(tester.getRect(shelf).width, closeTo(466.3, 1));
    });

    testWidgets('Testing if the picture glides into the top half when bent', (
      tester,
    ) async {
      // What the YouTube app does when you stand the device up: the picture
      // is still playing, so it moves and resizes into the half above the
      // crease. It is never replaced, because two copies of a playing video
      // crossing over would be the bug.
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Inner),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final picture = find.byKey(const Key('video-surface'));
      final flat = tester.getRect(picture);

      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Inner, halfOpened: true),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));

      // One picture, mid-journey: moved, not swapped.
      expect(picture, findsOneWidget);

      final midFlight = tester.getRect(picture);
      expect(midFlight.bottom, lessThan(flat.bottom));
      expect(midFlight.bottom, greaterThan(466.3));

      // And it comes to rest exactly on the crease.
      await tester.pumpAndSettle();
      expect(tester.getRect(picture).bottom, closeTo(466.3, 1));
    });

    testWidgets('Testing if the tabletop split slides into place', (
      tester,
    ) async {
      // A 120 dp header stands in for whatever sits above the pane, so the
      // middle of the pane and the crease are not the same line.
      Widget app({required bool bent}) => foldableApp(
        Column(
          children: const [
            SizedBox(height: 120),
            Expanded(
              child: TabletopPane(
                top: SizedBox.expand(key: Key('up')),
                bottom: SizedBox.expand(key: Key('down')),
              ),
            ),
          ],
        ),
        device: fold8Inner,
        halfOpened: bent,
      );

      useSurface(tester, fold8Inner);
      await tester.pumpWidget(app(bent: false));
      await tester.pumpAndSettle();

      final flat = tester.getRect(find.byKey(const Key('up'))).height;

      await tester.pumpWidget(app(bent: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));

      final midFlight = tester.getRect(find.byKey(const Key('up'))).height;
      expect(midFlight, lessThan(flat));
      expect(midFlight, greaterThan(346.3));

      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('up'))).height,
        closeTo(346.3, 1),
      );
    });
  });

  group('Panes Screen Widget Tests', () {
    testWidgets('Testing if picking a book changes the reading pane', (
      tester,
    ) async {
      useSurface(tester, bookHinge);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: bookHinge, halfOpened: true),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Call me Ishmael'), findsOneWidget);

      await tester.tap(find.text('Frankenstein'));
      await tester.pumpAndSettle();

      expect(find.textContaining('You will rejoice'), findsOneWidget);
      expect(find.textContaining('Call me Ishmael'), findsNothing);
    });

    testWidgets('Testing if the player puts its controls below the crease', (
      tester,
    ) async {
      // The Fold 8 crease runs across the window, which is the tabletop case:
      // the video belongs in the half the user looks at, the controls in the
      // half they reach.
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Inner, halfOpened: true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final video = find.byKey(const Key('video-surface'));
      final controls = find.byKey(const Key('player-controls'));

      expectClearOfFold(tester, video, fold8Inner);
      expectClearOfFold(tester, controls, fold8Inner);
      expect(
        tester.getRect(video).bottom,
        lessThanOrEqualTo(tester.getRect(controls).top),
      );
    });

    testWidgets('Testing if a wide window still leaves room for the controls', (
      tester,
    ) async {
      // 16:9 across 932 dp wants 524 dp of height, which used to push the
      // controls off the bottom of a 704 dp window.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final controls = tester.getRect(find.byKey(const Key('player-controls')));

      expect(controls.height, greaterThan(180));
      expect(controls.bottom, lessThanOrEqualTo(fold8Book.size.height));
    });

    testWidgets('Testing if the picture keeps 16:9 on a wide window', (
      tester,
    ) async {
      // The surface takes the shape the posture gives it. The picture inside
      // keeps its ratio and the rest is letterbox.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final picture = tester.getRect(
        find
            .descendant(
              of: find.byKey(const Key('video-surface')),
              matching: find.byType(AspectRatio),
            )
            .first,
      );

      expect(picture.width / picture.height, closeTo(16 / 9, 0.01));
    });

    testWidgets('Testing if the title clears the scrubber', (tester) async {
      // Both sit along the bottom of the picture, so the title steps up while
      // the controls are showing.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final title = tester.getRect(find.text('Beyond Breakpoints'));
      final scrubber = tester.getRect(find.byKey(const Key('scrubber')));

      expect(title.bottom, lessThanOrEqualTo(scrubber.top));
    });

    testWidgets('Testing if tapping the picture hides the controls', (
      tester,
    ) async {
      // With no second half to put them in, the controls live on the video,
      // and the video gets out of their way on a tap.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      double opacity() => tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(const Key('player-controls')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;

      expect(opacity(), 1);

      await tester.tapAt(
        tester.getTopLeft(find.byKey(const Key('video-surface'))) +
            const Offset(24, 24),
      );
      await tester.pumpAndSettle();

      expect(opacity(), 0);
    });

    testWidgets('Testing if the player splits at a crease down the window', (
      tester,
    ) async {
      // Open like a book and the crease runs down the middle instead. The
      // video takes one half and the controls take the other.
      useSurface(tester, fold8Book);
      await tester.pumpWidget(
        foldableApp(const PanesScreen(), device: fold8Book, halfOpened: true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Player'));
      await tester.pumpAndSettle();

      final video = find.byKey(const Key('video-surface'));
      final controls = find.byKey(const Key('player-controls'));

      expectClearOfFold(tester, video, fold8Book);
      expectClearOfFold(tester, controls, fold8Book);
      expect(
        tester.getRect(video).right,
        lessThanOrEqualTo(tester.getRect(controls).left),
      );
    });
  });
}
