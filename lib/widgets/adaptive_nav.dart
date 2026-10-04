// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/posture.dart';

/// A destination shown in the bar, the rail and the drawer.
class Destination {
  const Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Which navigation widget suits a given width.
enum NavigationKind {
  bar,
  rail,
  drawer;

  static NavigationKind forWidth(double width) {
    return switch (WindowSizeClass.fromWidth(width)) {
      WindowSizeClass.compact => bar,
      WindowSizeClass.medium || WindowSizeClass.expanded => rail,
      WindowSizeClass.large || WindowSizeClass.extraLarge => drawer,
    };
  }
}

/// Swaps between a bottom bar, a navigation rail and a drawer as the window
/// changes size.
///
/// [body] is the same widget in all three branches. Build a different body per
/// layout and unfolding the device throws away the state in it.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
  });

  final List<Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final kind = NavigationKind.forWidth(MediaQuery.sizeOf(context).width);

    return switch (kind) {
      NavigationKind.bar => Scaffold(
        appBar: AppBar(title: title),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
      NavigationKind.rail => Scaffold(
        appBar: AppBar(title: title),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
      NavigationKind.drawer => Scaffold(
        appBar: AppBar(title: title),
        body: Row(
          children: [
            NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              children: [
                for (final destination in destinations)
                  NavigationDrawerDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    };
  }
}
