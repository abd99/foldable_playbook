// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:foldable_playbook/widgets/readout.dart';

/// Shows what the first screen reports when the same build runs on iOS.
class DuoScreen extends StatelessWidget {
  const DuoScreen({super.key});

  static const routeName = '/duo';

  @override
  Widget build(BuildContext context) {
    final features = MediaQuery.displayFeaturesOf(context);

    return PageBody(
      title: '04  iPhone Duo',
      summary: 'The same call, answered differently on each platform.',
      children: [
        Readout(
          values: {
            'platform': _platformName,
            'displayFeatures': '${features.length}',
          },
        ),
        const SizedBox(height: 20),
        const Note(
          'MediaQuery.displayFeatures is filled in from Jetpack WindowManager '
          'on Android. The iOS embedder never fills it, so on an iPhone Duo '
          'this list is empty no matter how the device is held.',
        ),
        const Note(
          'Apple reports the fold as a reserved region, a division, which is '
          'separate from the hinge API. The hinge API is for interactions, '
          'not layout.',
        ),
        const Note(
          'Until Flutter bridges them, a plugin can. The foldable package '
          'reads the platform APIs and, if you opt in with bridgeMode, puts '
          'the result back into displayFeatures, so layout code written for '
          'Android keeps working. The default is none, so adding the '
          'dependency alone changes nothing.',
        ),
        const CodeBlock(
          'FoldableProvider(\n'
          '  child: FoldAwareBuilder(\n'
          '    builder: (context, constraints, fold) => fold.isPartiallyOpen\n'
          '        ? const TwoPaneLayout()\n'
          '        : const SinglePaneLayout(),\n'
          '  ),\n'
          ')',
        ),
        const Note(
          'Issue 192515 proposes doing this in the framework, and pull '
          'request 193025 implements it in the Darwin embedder. Abdallah '
          'Shaban confirmed on 29 September 2026 that the team is looking at '
          'the Apple safe areas and the hinge APIs.',
        ),
      ],
    );
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }
}
