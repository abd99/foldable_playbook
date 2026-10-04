// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/posture.dart';
import 'package:foldable_playbook/models/notepad.dart';
import 'package:foldable_playbook/widgets/readout.dart';
import 'package:provider/provider.dart';

/// Shows that folding the device does not reset the screen, and that dialogs
/// can be kept off the hinge.
class CoherenceScreen extends StatelessWidget {
  const CoherenceScreen({super.key});

  static const routeName = '/coherence';

  @override
  Widget build(BuildContext context) {
    final notepad = context.watch<Notepad>();

    return PageBody(
      title: '03  Coherence',
      summary: 'Type something, then fold the device.',
      children: [
        TextField(
          controller: notepad.controller,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: notepad.tap,
              child: const Text('Count a tap'),
            ),
            const SizedBox(width: 16),
            Text('${notepad.taps}'),
          ],
        ),
        const SizedBox(height: 20),
        const Note(
          'The navigation changes from a bar to a rail when the device '
          'unfolds, but the screen behind it is the same widget, so the text '
          'and the count are still here.',
        ),
        const Note(
          'Dialogs are the other half. Flutter routes them through '
          'DisplayFeatureSubScreen, which keeps them out of the hinge, but '
          'only for widgets it places itself.',
        ),
        OutlinedButton(
          onPressed: () => _showDialog(context),
          child: const Text('Open a dialog'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _showDialog(context, anchor: Offset.zero),
          child: const Text('Open it on the first half'),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, {Offset? anchor}) {
    final fold = separatingFoldOf(context);

    showDialog<void>(
      context: context,
      anchorPoint: anchor,
      builder: (context) => AlertDialog(
        title: const Text('Placed around the hinge'),
        content: Text(
          fold == null
              ? 'This window has no separating fold, so the dialog is '
                    'centred as usual.'
              : 'The fold is ${fold.thickness.toStringAsFixed(0)} dp thick, '
                    'so Flutter put this dialog on one side of it instead of '
                    'across the middle. Pass an anchorPoint to choose which '
                    'side.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
