// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
import 'package:foldable_playbook/widgets/fold_safe_area.dart';
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

          // The inset strips the safe area leaves behind are painted the same
          // colour as the app, so turning it on reads as the content moving
          // in rather than as black bars appearing.
          return ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: FoldSafeArea(
              enabled: settings.safeArea,
              child: AdaptiveNavScaffold(
                destinations: destinations,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: navigationShell.goBranch,
                body: navigationShell,
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
        // fills in on Android and not on iOS. This puts the iPhone Duo's
        // reserved regions into the same place, so none of that code has to
        // know which platform it is running on. It sits inside MaterialApp
        // because it republishes the MediaQuery the routes read, and it stands
        // aside on Android, where the engine already provides the features.
        builder: (context, child) => FoldableProvider(
          bridgeMode: DisplayFeatureBridgeMode.full,
          child: child ?? const SizedBox.shrink(),
        ),
        routerConfig: router(),
      ),
    );
  }
}
