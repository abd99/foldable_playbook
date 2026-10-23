// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/main.dart';
import 'package:foldable_playbook/widgets/adaptive_nav.dart';

import 'foldables.dart';

void main() {
  group('Navigation Widget Tests', () {
    testWidgets('Testing if a phone sized window uses a bar', (tester) async {
      useSurface(tester, fold8Cover);
      await tester.pumpWidget(foldableRoot(fold8Cover));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Testing if an unfolded device uses a rail', (tester) async {
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(foldableRoot(fold8Inner));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('Bottom Bar Tests', () {
    // Slim at the default text size, Material's full height once the user has
    // asked for larger text, because 64 dp only has room for one line of
    // label.
    for (final (scale, height) in [(1.0, 64.0), (1.3, 80.0)]) {
      testWidgets('Testing the bar height at text scale $scale', (
        tester,
      ) async {
        useSurface(tester, fold8Cover);
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: fold8Cover.size,
              textScaler: TextScaler.linear(scale),
            ),
            child: MaterialApp(
              home: AdaptiveNavScaffold(
                destinations: destinations,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                body: const SizedBox(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(NavigationBar)).height, height);
      });
    }
  });

  group('State Across A Fold Tests', () {
    testWidgets('Testing if notes and taps survive unfolding', (tester) async {
      // Start on the cover display and leave something on the screen.
      useSurface(tester, fold8Cover);
      await tester.pumpWidget(foldableRoot(fold8Cover));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Coherence'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Written before folding');
      await tester.tap(find.text('Count a tap'));
      await tester.pumpAndSettle();

      // Unfold. The window gets wider and the navigation changes shape.
      useSurface(tester, fold8Inner);
      await tester.pumpWidget(foldableRoot(fold8Inner));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Written before folding'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
