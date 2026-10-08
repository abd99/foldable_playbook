// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/widgets/readout.dart';

/// Explains how the screens in this app are tested without a foldable.
class TestingScreen extends StatelessWidget {
  const TestingScreen({super.key});

  static const routeName = '/testing';

  @override
  Widget build(BuildContext context) {
    return const PageBody(
      title: '05  Testing',
      summary: 'Every layout in this app is checked without a device.',
      children: [
        Note(
          'A fold is a rectangle and a posture. Both can be handed to a '
          'widget test, so any device shape is reproducible on a machine that '
          'has none.',
        ),
        CodeBlock(
          "testWidgets('Splits at the hinge', (tester) async {\n"
          '  await tester.pumpWidget(\n'
          '    foldableApp(const PanesScreen(), device: bookHinge),\n'
          '  );\n'
          '\n'
          '  // Verify that nothing is drawn inside the hinge.\n'
          '  expectClearOfFold(tester, find.text("Crease"), bookHinge);\n'
          '});',
        ),
        Note(
          'The sizes come from real hardware: the Fold 8 inner display at '
          '932.6 x 704 dp opened like a book and 704 x 932.6 turned, the '
          'Ultra at 834.7 x 752, and a book style hinge with a 24 dp gap.',
        ),
        Note(
          'Golden files cover what assertions miss, like text sitting in the '
          'hinge or a rail that never appeared. Run flutter test '
          '--update-goldens after a change, and look at the images.',
        ),
      ],
    );
  }
}
