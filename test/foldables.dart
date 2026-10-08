// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_playbook/main.dart';
import 'package:foldable_playbook/models/notepad.dart';
import 'package:provider/provider.dart';

/// A device to run a widget test on.
///
/// The sizes are measured from the hardware, not rounded, because the rounding
/// is where the bugs are. A Fold 8 Ultra is 834.7 dp wide, which is 5.3 dp
/// short of the Material expanded breakpoint.
class Foldable {
  const Foldable({
    required this.name,
    required this.size,
    required this.pixelRatio,
    this.fold = Rect.zero,
  });

  final String name;
  final Size size;
  final double pixelRatio;

  /// Where the fold sits, in the same logical pixels as [size]. A device
  /// without one leaves this empty.
  final Rect fold;

  bool get hasFold => fold != Rect.zero;
  bool get foldIsVertical => fold.height > fold.width;
}

/// Galaxy Z Fold 8, inner display, turned a quarter from how it opens.
///
/// 704 dp wide, so Material calls it medium, and the crease runs across the
/// window. See [fold8Book] for the way the device opens.
const fold8Inner = Foldable(
  name: 'Fold 8 inner',
  size: Size(704, 932.6),
  pixelRatio: 2.625,
  fold: Rect.fromLTRB(0, 466.3, 704, 466.3),
);

/// Galaxy Z Fold 8, inner display, opened like a book.
///
/// The orientation the device opens in: 932.6 dp wide with the crease running
/// down the middle, so Material calls it expanded. The same phone is medium
/// when turned (see [fold8Inner]), which is the point. Measured with
/// posture_probe on 22 August: 2448 x 1848 px at 2.625.
const fold8Book = Foldable(
  name: 'Fold 8 book',
  size: Size(932.6, 704),
  pixelRatio: 2.625,
  fold: Rect.fromLTRB(466.3, 0, 466.3, 704),
);

/// Galaxy Z Fold 8, cover display. No fold, but there is a camera cutout.
const fold8Cover = Foldable(
  name: 'Fold 8 cover',
  size: Size(475.4, 751.2),
  pixelRatio: 2.625,
);

/// Galaxy Z Fold 8 Ultra, inner display, held in landscape.
const fold8Ultra = Foldable(
  name: 'Fold 8 Ultra inner',
  size: Size(834.7, 752),
  pixelRatio: 3,
  fold: Rect.fromLTRB(0, 376, 834.7, 376),
);

/// Pixel 10 Pro Fold, inner display.
///
/// 851.7 dp wide, so this one clears the expanded breakpoint that the Ultra
/// misses. The crease runs down the middle of the window and
/// has no thickness, which means it only separates once the device is bent.
const pixelFoldInner = Foldable(
  name: 'Pixel Fold inner',
  size: Size(851.7, 882.9),
  pixelRatio: 2.4375,
  fold: Rect.fromLTRB(425.8, 0, 425.8, 882.9),
);

/// A book style foldable with a 24 dp gap between the halves.
const bookHinge = Foldable(
  name: 'Book hinge',
  size: Size(840, 640),
  pixelRatio: 2,
  fold: Rect.fromLTRB(408, 0, 432, 640),
);

const allFoldables = [
  fold8Book,
  fold8Inner,
  fold8Cover,
  fold8Ultra,
  pixelFoldInner,
  bookHinge,
];

/// The camera cutout on the Fold 8 cover display.
///
/// Useful for checking that layout code filters display features by type
/// instead of counting them.
const cameraCutout = DisplayFeature(
  bounds: Rect.fromLTRB(224.4, 0, 251, 39.6),
  type: DisplayFeatureType.cutout,
  state: DisplayFeatureState.unknown,
);

/// Wraps [child] in the app's providers and a MediaQuery describing [device].
///
/// Pass [halfOpened] to report the fold as bent rather than flat, and
/// [cutout] to add the camera.
Widget foldableApp(
  Widget child, {
  required Foldable device,
  bool halfOpened = false,
  bool cutout = false,
}) {
  final features = [
    if (device.hasFold)
      DisplayFeature(
        bounds: device.fold,
        type: DisplayFeatureType.fold,
        state: halfOpened
            ? DisplayFeatureState.postureHalfOpened
            : DisplayFeatureState.postureFlat,
      ),
    if (cutout) cameraCutout,
  ];

  return MediaQuery(
    data: MediaQueryData(
      size: device.size,
      devicePixelRatio: device.pixelRatio,
      displayFeatures: features,
    ),
    child: ChangeNotifierProvider<Notepad>(
      create: (context) => Notepad(),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

/// Sets the test surface to [device], so goldens come out at its shape.
void useSurface(WidgetTester tester, Foldable device) {
  tester.view.devicePixelRatio = device.pixelRatio;
  tester.view.physicalSize = device.size * device.pixelRatio;
  addTearDown(tester.view.reset);
}

/// Runs [body] once for every device in [devices].
void testEveryFoldable(
  String description,
  Future<void> Function(WidgetTester tester, Foldable device) body, {
  List<Foldable> devices = allFoldables,
}) {
  for (final device in devices) {
    testWidgets('$description on the ${device.name}', (tester) async {
      useSurface(tester, device);
      await body(tester, device);
    });
  }
}

/// Half a logical pixel, which is less than a crease and less than the error
/// in a layout that lands exactly on one.
///
/// A fold with no thickness makes "clear of the fold" mean "ends at exactly
/// this coordinate", and a pane that does precisely that can still come out a
/// fraction over. A real overlap is tens of pixels, so this tolerance cannot
/// hide one.
const _foldTolerance = 0.5;

/// Fails if the widget [finder] points at overlaps the hinge.
///
/// This is the check that catches the real bug. Content near a hinge is fine.
/// Content inside one is split in half by hardware.
void expectClearOfFold(
  WidgetTester tester,
  Finder finder,
  Foldable device,
) {
  if (!device.hasFold) return;

  final rect = tester.getRect(finder);
  final overlaps = device.foldIsVertical
      ? rect.right > device.fold.left + _foldTolerance &&
            rect.left < device.fold.right - _foldTolerance
      : rect.bottom > device.fold.top + _foldTolerance &&
            rect.top < device.fold.bottom - _foldTolerance;

  expect(
    overlaps,
    isFalse,
    reason: '$rect overlaps the fold at ${device.fold}',
  );
}

/// Wraps the whole app, for tests that move between screens.
Widget foldableRoot(Foldable device, {bool halfOpened = false}) {
  return MediaQuery(
    data: MediaQueryData(
      size: device.size,
      devicePixelRatio: device.pixelRatio,
      displayFeatures: [
        if (device.hasFold)
          DisplayFeature(
            bounds: device.fold,
            type: DisplayFeatureType.fold,
            state: halfOpened
                ? DisplayFeatureState.postureHalfOpened
                : DisplayFeatureState.postureFlat,
          ),
      ],
    ),
    child: const PlaybookApp(),
  );
}
