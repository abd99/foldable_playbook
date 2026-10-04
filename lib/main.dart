// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/models/notepad.dart';
import 'package:foldable_playbook/screens/coherence.dart';
import 'package:foldable_playbook/screens/duo.dart';
import 'package:foldable_playbook/screens/panes.dart';
import 'package:foldable_playbook/screens/posture.dart';
import 'package:foldable_playbook/screens/testing.dart';
import 'package:foldable_playbook/widgets/adaptive_nav.dart';
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
          return AdaptiveNavScaffold(
            title: const Text('Foldable Playbook'),
            destinations: destinations,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            body: navigationShell,
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
    return ChangeNotifierProvider<Notepad>(
      create: (context) => Notepad(),
      child: MaterialApp.router(
        title: 'Foldable Playbook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
        ),
        routerConfig: router(),
      ),
    );
  }
}
