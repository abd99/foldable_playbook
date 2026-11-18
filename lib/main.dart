// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:duo_kit/debug.dart';
import 'package:duo_kit/duo_kit.dart';
import 'package:flutter/material.dart';
import 'package:foldable/foldable.dart';
import 'package:foldable_playbook/models/layout_settings.dart';
import 'package:foldable_playbook/models/notepad.dart';
import 'package:foldable_playbook/screens/coherence.dart';
import 'package:foldable_playbook/screens/duo.dart';
import 'package:foldable_playbook/screens/panes.dart';
import 'package:foldable_playbook/screens/posture.dart';
import 'package:foldable_playbook/screens/testing.dart';
import 'package:foldable_playbook/widgets/adaptive_nav.dart';
import 'package:foldable_playbook/widgets/fold_bridge_switch.dart';
import 'package:foldable_playbook/widgets/fold_safe_area.dart';
import 'package:foldable_playbook/widgets/strip_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const PlaybookApp());
}

const destinations = [
  Destination(
    label: 'Posture',
    icon: Icons.phone_android_outlined,
    selectedIcon: Icons.phone_android,
  ),
  Destination(
    label: 'Panes',
    icon: Icons.vertical_split_outlined,
    selectedIcon: Icons.vertical_split,
  ),
  Destination(
    label: 'Coherence',
    icon: Icons.sync_alt_outlined,
    selectedIcon: Icons.sync_alt,
  ),
  Destination(
    label: 'Duo',
    icon: Icons.phone_iphone_outlined,
    selectedIcon: Icons.phone_iphone,
  ),
  Destination(
    label: 'Testing',
    icon: Icons.science_outlined,
    selectedIcon: Icons.science,
  ),
];

GoRouter router() {
  return GoRouter(
    routes: [
      // An indexed stack keeps every branch alive, so moving between screens,
      // or folding the device, does not throw away what is on them.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final settings = context.watch<LayoutSettings>();

          // A strip only exists on iPhone Duo: the inset along one side that
          // holds the camera and the status cluster. duo_kit finds it from the
          // padding alone, and on Android it never looks.
          final strip = settings.stripNavigation
              ? FoldGeometry.of(context).strip
              : null;

          // The inset strips the safe area leaves behind are painted the same
          // colour as the app, so turning it on reads as the content moving
          // in rather than as black bars appearing.
          return ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: strip == null
                ? FoldSafeArea(
                    enabled: settings.safeArea,
                    child: AdaptiveNavScaffold(
                      destinations: destinations,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: navigationShell.goBranch,
                      body: navigationShell,
                    ),
                  )
                // The navigation moves into the strip, and the body gets the
                // rest of the window. Rotating the inner display moves the
                // strip in and out, and the screens survive the swap because
                // go_router keeps them in keyed navigators.
                : FoldScaffold(
                    body: StripBody(
                      strip: strip,
                      child: Scaffold(
                        body: FoldSafeArea(
                          enabled: settings.safeArea,
                          child: navigationShell,
                        ),
                      ),
                    ),
                    navigationBuilder: (context, placement) => StripNavigation(
                      placement: placement,
                      destinations: destinations,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: navigationShell.goBranch,
                    ),
                  ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: PostureScreen.routeName,
                builder: (context, state) => const PostureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: PanesScreen.routeName,
                builder: (context, state) => const PanesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CoherenceScreen.routeName,
                builder: (context, state) => const CoherenceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DuoScreen.routeName,
                builder: (context, state) => const DuoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TestingScreen.routeName,
                builder: (context, state) => const TestingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class PlaybookApp extends StatelessWidget {
  const PlaybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Notepad>(create: (context) => Notepad()),
        ChangeNotifierProvider<LayoutSettings>(
          create: (context) => LayoutSettings(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Foldable Playbook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
        ),
        // Every screen below reads the fold from MediaQuery, which Flutter
        // fills in on Android and not on iOS. Two plugins can put the iPhone
        // Duo's fold there, and both run here so they can be compared on the
        // device: duo_kit's FoldBridge adds its features itself, the foldable package
        // only reports, and FoldBridgeSwitch decides which reaches the screens.
        // They sit inside MaterialApp because they republish the MediaQuery
        // the routes read, and on Android all three stand aside.
        builder: (context, child) {
          final settings = context.watch<LayoutSettings>();

          return FoldBridge(
            child: FoldableProvider(
              bridgeMode: DisplayFeatureBridgeMode.none,
              child: FoldBridgeSwitch(
                bridge: settings.bridge,
                // Over everything, because the geometry is in window
                // coordinates.
                child: FoldGeometryOverlay(
                  enabled: settings.geometryOverlay,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        routerConfig: router(),
      ),
    );
  }
}
