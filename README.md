# Foldable Playbook

Sample app for *Beyond Breakpoints: Flutter Apps for the Foldable Era*,
FlutterCon Berlin, 8 October 2026.

It reads the fold from `MediaQuery` and lays itself out around it, so you can
open the app on a foldable, bend the device, and watch the numbers and the
layout change.

```sh
flutter run
flutter test
```

## Screens

| | Screen | What it covers |
| --- | --- | --- |
| 01 | Posture | What `displayFeatures` reports, and what it leaves out |
| 02 | Panes | A list and detail split that lands on the hinge |
| 03 | Coherence | State and dialogs across a fold |
| 04 | Duo | Why the same code reports nothing on iOS |
| 05 | Testing | How the layouts here are tested without a device |

## Code

- `lib/layout/posture.dart` reads the window. `WindowSizeClass` for the
  Material breakpoints, `FoldInfo` for the fold itself, and `foldsOf` to keep
  camera cutouts out of the way.
- `lib/layout/two_pane.dart` splits at a vertical fold, or by width when there
  is no fold to use. `TabletopPane` handles the horizontal case.
- `lib/widgets/adaptive_nav.dart` moves between a bar, a rail and a drawer,
  with the same body widget in each.

Three things are easy to miss. `displayFeatures` holds cutouts as well as
folds, so filter it by type. Flutter drops `orientation` and `isSeparating`
from Jetpack's `FoldingFeature`, so both have to be worked out from the
bounds. And the bounds are in **window** coordinates: a pane sitting beside a
navigation rail has to subtract its own offset, or the divider lands a rail's
width past the hinge. That one only shows up on a device, unless the test
pumps the whole app instead of the pane on its own.

## Sizes

Measured on hardware, not rounded:

| Device | Window | Size class |
| --- | --- | --- |
| Fold 8 inner | 704 x 932.6 dp | Medium |
| Fold 8 cover | 475.4 x 751.2 dp | Compact |
| Fold 8 Ultra inner | 834.7 x 752 dp | Medium |
| Pixel 10 Pro Fold inner | 851.7 x 882.9 dp | Expanded |

The Ultra is 5.3 dp short of the expanded breakpoint. Code that only asks
whether the window is expanded shows its phone layout on both of Samsung's
foldables, and its tablet layout on the Pixel 17 dp further along. The Pixel
sizes come from the emulator; the Samsung ones from the handsets.

## Tests

`test/foldables.dart` holds the device sizes and the helpers: `foldableApp`
for a single screen, `foldableRoot` for the whole app, `testEveryFoldable` to
repeat a test across devices, and `expectClearOfFold` to fail when a widget
overlaps a hinge.

Five devices run in every sweep. Between them they cover a horizontal fold, a
cover screen with a cutout and no fold, a window that just misses the expanded
breakpoint, a vertical crease with no gap, and a hinge with a real 24 dp one.

Goldens live in `test/goldens`. Update them with
`flutter test --update-goldens`, and look at the images before committing.

They are rendered by the host machine, so the images here are the ones a Mac
produces. They are tagged `golden`, and CI runs `flutter test --exclude-tags
golden` rather than comparing a Linux rendering against them. Run them
yourself with `flutter test --tags golden`.

## iPhone Duo

`MediaQuery.displayFeatures` is only filled in on Android. On iOS it stays
empty, so an iPhone Duo looks like a slab phone to Flutter. Screen 04 shows
that, and points at
[flutter#192515](https://github.com/flutter/flutter/issues/192515) and
[#193025](https://github.com/flutter/flutter/pull/193025), which propose
filling it from Apple's reserved regions. The
[foldable](https://pub.dev/packages/foldable) package does it today over a
platform channel.
