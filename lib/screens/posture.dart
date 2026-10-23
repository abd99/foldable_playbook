// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/posture.dart';
import 'package:foldable_playbook/models/layout_settings.dart';
import 'package:foldable_playbook/widgets/adaptive_nav.dart';
import 'package:foldable_playbook/widgets/readout.dart';
import 'package:provider/provider.dart';

/// Shows what this window reports about its own shape.
class PostureScreen extends StatelessWidget {
  const PostureScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final features = MediaQuery.displayFeaturesOf(context);
    final separating = separatingFoldOf(context);
    final sizeClass = WindowSizeClass.of(context);

    return PageBody(
      title: '01  Posture',
      summary: 'Read from MediaQuery as the device moves.',
      children: [
        Readout(
          values: {
            'window':
                '${size.width.toStringAsFixed(1)} x '
                '${size.height.toStringAsFixed(1)} dp',
            'size class': sizeClass.label,
            'navigation': NavigationKind.forWidth(size.width).name,
            // Every display feature is listed underneath with its type and
            // state, so counting them here only invited the question of what
            // a "fold" was counting that displayFeatures was not.
            'separating': separating == null ? 'none' : _summarise(separating),
          },
        ),
        // The one setting in the app, kept next to the numbers it changes.
        // With it on, the window above is the safe area, and the fold below
        // is measured from the safe area's corner rather than the screen's.
        ReadoutSwitch(
          key: const Key('safe-area-switch'),
          label: 'safe area',
          value: context.watch<LayoutSettings>().safeArea,
          onChanged: (_) => context.read<LayoutSettings>().toggleSafeArea(),
        ),
        const SizedBox(height: 20),
        Text('displayFeatures', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (features.isEmpty)
          const Note(
            'No display features. Either this window has no fold, or the '
            'platform does not report one. See screen 04.',
          )
        else
          for (final feature in features) _FeatureTile(feature: feature),
        const SizedBox(height: 8),
        const Note(
          'displayFeatures is not a list of folds. Cutouts arrive in the same '
          'list, so checking whether it is empty will split a layout around '
          'the selfie camera. Filter on the type.',
        ),
      ],
    );
  }

  String _summarise(FoldInfo fold) {
    final direction = fold.isVertical ? 'vertical' : 'horizontal';
    final posture = fold.isHalfOpened ? 'half opened' : 'flat';
    return '$direction, ${fold.thickness.toStringAsFixed(0)} dp, $posture';
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final DisplayFeature feature;

  @override
  Widget build(BuildContext context) {
    final bounds = feature.bounds;
    final isCutout = feature.type == DisplayFeatureType.cutout;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(isCutout ? Icons.circle_outlined : Icons.horizontal_rule),
        title: Text('${feature.type.name}, ${feature.state.name}'),
        subtitle: Text(
          'left ${bounds.left.toStringAsFixed(0)}  '
          'top ${bounds.top.toStringAsFixed(0)}  '
          '${bounds.width.toStringAsFixed(0)} x '
          '${bounds.height.toStringAsFixed(0)}',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
