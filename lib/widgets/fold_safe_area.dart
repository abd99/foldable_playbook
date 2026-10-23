// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A [SafeArea] that takes the fold with it.
///
/// [SafeArea] moves its child away from the status bar and the camera, but
/// display features stay in window coordinates. Anything below that compares
/// the fold with its own position, like a pane split, then misses the crease
/// by exactly the inset: 44 dp on a right-hand status bar.
///
/// So inside, the safe area is treated as the window. The size shrinks to it
/// and the fold is shifted by the same amount the content was.
class FoldSafeArea extends StatelessWidget {
  const FoldSafeArea({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final insets = enabled ? MediaQuery.paddingOf(context) : EdgeInsets.zero;

    // Both widgets are always here, switched off rather than removed. Taking
    // them out would change the shape of the tree and rebuild the scaffold
    // below from scratch. go_router happens to carry its screens across that
    // in keyed navigators, but nothing else under here would be so lucky.
    return SafeArea(
      left: enabled,
      top: enabled,
      right: enabled,
      bottom: enabled,
      child: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          final shift = Offset(insets.left, insets.top);

          return MediaQuery(
            data: media.copyWith(
              size: Size(
                media.size.width - insets.horizontal,
                media.size.height - insets.vertical,
              ),
              displayFeatures: [
                for (final feature in media.displayFeatures)
                  DisplayFeature(
                    bounds: feature.bounds.shift(-shift),
                    type: feature.type,
                    state: feature.state,
                  ),
              ],
            ),
            child: child,
          );
        },
      ),
    );
  }
}
