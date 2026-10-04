// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/two_pane.dart';
import 'package:foldable_playbook/widgets/readout.dart';

/// A list and detail pair that splits at the hinge when there is one.
class PanesScreen extends StatefulWidget {
  const PanesScreen({super.key});

  static const routeName = '/panes';

  @override
  State<PanesScreen> createState() => _PanesScreenState();
}

class _PanesScreenState extends State<PanesScreen> {
  static const _postures = [
    ('Hinge', 'A gap in the hardware. Nothing readable can go here.'),
    ('Crease', 'No gap, but the screen bends. Text across it is hard to read.'),
    ('Tabletop', 'Folded halfway, hinge across. Content up, controls down.'),
    ('Book', 'Folded halfway, hinge down. One pane per half.'),
    ('Flat', 'A fold the platform reports, with nothing to avoid.'),
  ];

  int _selected = 0;
  TwoPaneMode? _mode;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      children: [
        for (var i = 0; i < _postures.length; i++)
          ListTile(
            title: Text(_postures[i].$1),
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
      ],
    );

    final detail = PageBody(
      title: _postures[_selected].$1,
      summary: _postures[_selected].$2,
      children: [Note(_modeDescription)],
    );

    return TwoPane(
      start: list,
      end: detail,
      onModeChanged: (mode) {
        if (mode != _mode && mounted) setState(() => _mode = mode);
      },
    );
  }

  String get _modeDescription => switch (_mode) {
    TwoPaneMode.fold =>
      'Split at the fold. The hinge is the divider, and nothing is drawn in '
          'it.',
    TwoPaneMode.flex =>
      'Wide enough for two panes, but there is no fold to split on.',
    TwoPaneMode.single => 'Too narrow for two panes.',
    null => 'Measuring.',
  };
}
