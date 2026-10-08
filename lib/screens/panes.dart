// Copyright 2026 Abdullah Deshmukh. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:foldable_playbook/layout/posture.dart';
import 'package:foldable_playbook/layout/two_pane.dart';

/// Two sample layouts, because a fold is easier to see in an app than in a
/// diagram.
///
/// The reader is a list and detail pair, which is what a vertical fold is for.
/// The player is the other posture: bend the device with the crease across the
/// window and the video stays above it while the controls come down.
class PanesScreen extends StatefulWidget {
  const PanesScreen({super.key});

  static const routeName = '/panes';

  @override
  State<PanesScreen> createState() => _PanesScreenState();
}

enum _Sample { reader, player }

class _PanesScreenState extends State<PanesScreen> {
  _Sample _sample = _Sample.reader;
  TwoPaneMode? _mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<_Sample>(
              segments: const [
                ButtonSegment(
                  value: _Sample.reader,
                  icon: Icon(Icons.menu_book_outlined),
                  label: Text('Reader'),
                ),
                ButtonSegment(
                  value: _Sample.player,
                  icon: Icon(Icons.play_circle_outline),
                  label: Text('Player'),
                ),
              ],
              selected: {_sample},
              onSelectionChanged: (selection) =>
                  setState(() => _sample = selection.first),
            ),
          ),
        ),
        // Above the sample, not below it. A line under the panes would inset
        // them from the bottom of the window, and TabletopPane works out where
        // the crease falls by comparing its own height to the window's.
        _LayoutLine(sample: _sample, mode: _mode),
        Expanded(
          child: switch (_sample) {
            _Sample.reader => _Reader(
              onModeChanged: (mode) {
                if (mode != _mode && mounted) setState(() => _mode = mode);
              },
            ),
            _Sample.player => const _Player(),
          },
        ),
      ],
    );
  }
}

/// What the layout decided, in one line, so the rule can be read off the
/// screen while the device moves.
class _LayoutLine extends StatelessWidget {
  const _LayoutLine({required this.sample, required this.mode});

  final _Sample sample;
  final TwoPaneMode? mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fold = separatingFoldOf(context);

    final text = switch (sample) {
      _Sample.player => switch (fold) {
        null =>
          'Stacked. No crease to work around, so the video keeps its own '
              'aspect ratio and the controls sit under it.',
        final f when f.isVertical =>
          'Split at the crease. The video takes one half of the book and the '
              'controls take the other.',
        _ =>
          'Tabletop. The crease runs across the window, so the video stays '
              'above it and the controls sit below.',
      },
      _Sample.reader => switch (mode) {
        TwoPaneMode.fold =>
          'Split at the fold. The divider is the hinge, and nothing is drawn '
              'in it.',
        TwoPaneMode.flex =>
          'Split by width. Wide enough for two panes, but no vertical fold to '
              'use.',
        TwoPaneMode.single => 'One pane. Too narrow to show both.',
        null => 'Measuring.',
      },
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        // The switcher centres whatever it is handed, so the line has to take
        // the full width or it drifts into the middle as the posture changes.
        child: SizedBox(
          key: ValueKey(text),
          width: double.infinity,
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
      ),
    );
  }
}

/// A shelf and a reading pane: the list and detail case.
class _Reader extends StatefulWidget {
  const _Reader({required this.onModeChanged});

  final ValueChanged<TwoPaneMode> onModeChanged;

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> {
  int _selected = 0;

  // Only used when there is no fold to split on. A crease is not negotiable.
  double _flex = 0.4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = _books[_selected];

    final shelf = ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(_books[i].title),
        subtitle: Text(_books[i].author),
        selected: i == _selected,
        onTap: () => setState(() => _selected = i),
      ),
    );

    final page = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: ListView(
        key: ValueKey(_selected),
        padding: const EdgeInsets.all(24),
        children: [
          // A wide pane is not a reason for ninety character lines. Reading
          // measure is the same on a foldable as it is anywhere else.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.chapter.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(book.title, style: theme.textTheme.headlineSmall),
                  Text(book.author, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  for (final paragraph in book.opening) ...[
                    Text(
                      paragraph,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return TwoPane(
      start: shelf,
      end: page,
      startFlex: _flex,
      onModeChanged: widget.onModeChanged,
      onStartFlexChanged: (flex) => setState(() => _flex = flex),
    );
  }
}

/// A video above, its controls below. Nothing streams; the point is where the
/// two halves land when the device is bent.
class _Player extends StatefulWidget {
  const _Player();

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> with SingleTickerProviderStateMixin {
  // Paused on arrival, so a widget test can settle and a golden is stable.
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(minutes: 2, seconds: 48),
  );

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_progress.isAnimating) {
        _progress.stop();
      } else {
        _progress.forward();
      }
    });
  }

  // The overlay starts visible, the way a player looks the moment you open it.
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final fold = separatingFoldOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Where the two boxes go, for this posture. A crease down the window
        // puts the picture in one half of the book; a crease across it is
        // tabletop, picture above and the rest below; with no crease the
        // picture keeps 16:9 and the list sits under it.
        var videoRect = Rect.zero;
        var panelRect = Rect.zero;
        var onVideo = false;

        // Where the crease falls inside this pane, if it falls inside it at
        // all. Bounds are in window coordinates, so take off whatever sits
        // between the window edge and here.
        double? splitAt;
        var gap = 0.0;
        var vertical = false;

        if (fold != null) {
          vertical = fold.isVertical;
          final at = vertical
              ? fold.bounds.left - (MediaQuery.sizeOf(context).width - width)
              : fold.bounds.top - (MediaQuery.sizeOf(context).height - height);
          final limit = vertical ? width : height;

          if (at > 0 && at + fold.thickness < limit) {
            splitAt = at;
            gap = fold.thickness;
          }
        }

        if (splitAt != null && vertical) {
          final after = splitAt + gap;
          videoRect = Rect.fromLTWH(0, 0, splitAt, height);
          panelRect = Rect.fromLTWH(after, 0, width - after, height);
        } else if (splitAt != null) {
          final after = splitAt + gap;
          videoRect = Rect.fromLTWH(0, 0, width, splitAt);
          panelRect = Rect.fromLTWH(0, after, width, height - after);
        } else {
          final videoHeight = math.min(width * 9 / 16, height * 0.62);
          videoRect = Rect.fromLTWH(0, 0, width, videoHeight);
          panelRect = Rect.fromLTWH(
            0,
            videoHeight,
            width,
            height - videoHeight,
          );
          onVideo = true;
        }

        // One surface, moved. Swapping one layout for another would fade
        // between two copies of the picture, which is exactly what a player
        // must never do: it is still playing. So the same box glides and
        // resizes into the half it belongs in, the way YouTube does when you
        // stand the device up.
        const motion = Duration(milliseconds: 320);

        return Stack(
          children: [
            AnimatedPositioned.fromRect(
              rect: videoRect,
              duration: motion,
              curve: Curves.easeOutCubic,
              child: _video(withOverlay: onVideo),
            ),
            AnimatedPositioned.fromRect(
              rect: panelRect,
              duration: motion,
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: onVideo
                    ? const _UpNext()
                    : _Controls(progress: _progress, onToggle: _toggle),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The black surface, with the picture held at 16:9 inside it.
  ///
  /// The surface takes whatever shape the posture gives it. The picture keeps
  /// its own ratio and the rest is letterbox, which is what a video does
  /// everywhere else and what the old version got wrong on a wide window.
  Widget _video({bool withOverlay = false}) {
    final theme = Theme.of(context);

    final picture = AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF151A20)),
          if (withOverlay)
            AnimatedOpacity(
              opacity: _showOverlay ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: !_showOverlay,
                child: _OverlayControls(progress: _progress, onToggle: _toggle),
              ),
            ),
          Center(
            child: Icon(
              Icons.movie_outlined,
              size: 56,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          // The scrubber lives along the bottom of the picture, so the title
          // steps up out of its way while the controls are showing, and drops
          // back when they go.
          AnimatedPositioned(
            left: 20,
            right: 20,
            bottom: withOverlay && _showOverlay ? 52 : 16,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Text(
              'Beyond Breakpoints',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: withOverlay
          ? () => setState(() => _showOverlay = !_showOverlay)
          : null,
      child: Container(
        key: const Key('video-surface'),
        color: const Color(0xFF0B0E12),
        child: Center(child: picture),
      ),
    );
  }
}

/// Controls drawn on the video, for when there is no second half to put them
/// in. Tap the picture to show or hide them.
class _OverlayControls extends StatelessWidget {
  const _OverlayControls({required this.progress, required this.onToggle});

  final AnimationController progress;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('player-controls'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0x99000000)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: _PlayButton(
              progress: progress,
              onToggle: onToggle,
              onDark: true,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 14,
            child: AnimatedBuilder(
              key: const Key('scrubber'),
              animation: progress,
              builder: (context, child) => Row(
                children: [
                  Text(
                    _clock(progress.value),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress.value,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '2:48',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What is next, under the picture, when the controls are on the video.
class _UpNext extends StatelessWidget {
  const _UpNext();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      children: [
        Text('Up next', style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        for (final (title, length) in const [
          ('Reading the fold', '4:12'),
          ('Testing without a device', '3:30'),
          ('Preparing for iPhone Duo', '5:05'),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.play_circle_outline),
            title: Text(title),
            trailing: Text(length, style: theme.textTheme.labelSmall),
          ),
      ],
    );
  }
}

/// Play and pause, with the icon swapped rather than cut.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.progress,
    required this.onToggle,
    this.onDark = false,
  });

  final AnimationController progress;
  final VoidCallback onToggle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        progress.isAnimating ? Icons.pause : Icons.play_arrow,
        key: ValueKey(progress.isAnimating),
      ),
    );

    if (onDark) {
      return IconButton.filled(
        onPressed: onToggle,
        iconSize: 36,
        style: IconButton.styleFrom(
          minimumSize: const Size(72, 72),
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
        ),
        icon: icon,
      );
    }

    return IconButton.filled(
      onPressed: onToggle,
      iconSize: 32,
      style: IconButton.styleFrom(minimumSize: const Size(64, 64)),
      icon: icon,
    );
  }
}

String _clock(double value) {
  final seconds = (value * 168).round();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// The transport, sized for a thumb and centred in whatever half it is given.
class _Controls extends StatelessWidget {
  const _Controls({required this.progress, required this.onToggle});

  final AnimationController progress;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('player-controls'),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        // Controls that stretch to the full width of a 900 dp pane look like a
        // mistake. They stay a thumb's width apart whatever the window does.
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: progress,
              builder: (context, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: progress.value),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _clock(progress.value),
                        style: theme.textTheme.labelSmall,
                      ),
                      Text('2:48', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.closed_caption_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                ),
                _PlayButton(progress: progress, onToggle: onToggle),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Up next', style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(
              'Reading the fold · Testing without a device',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Four openings in the public domain, short enough to read from the back of
/// a room.
class _Book {
  const _Book(this.title, this.author, this.chapter, this.opening);

  final String title;
  final String author;
  final String chapter;
  final List<String> opening;
}

const _books = [
  _Book('Moby-Dick', 'Herman Melville', 'Chapter 1 · Loomings', [
    'Call me Ishmael. Some years ago, never mind how long precisely, having '
        'little or no money in my purse, and nothing particular to interest '
        'me on shore, I thought I would sail about a little and see the '
        'watery part of the world.',
    'It is a way I have of driving off the spleen and regulating the '
        'circulation.',
  ]),
  _Book(
    'Alice in Wonderland',
    'Lewis Carroll',
    'Chapter 1 · Down the Rabbit-Hole',
    [
      'Alice was beginning to get very tired of sitting by her sister on the '
          'bank, and of having nothing to do: once or twice she had peeped '
          'into the book her sister was reading, but it had no pictures or '
          'conversations in it.',
      '"And what is the use of a book," thought Alice, "without pictures or '
          'conversations?"',
    ],
  ),
  _Book('Pride and Prejudice', 'Jane Austen', 'Chapter 1', [
    'It is a truth universally acknowledged, that a single man in possession '
        'of a good fortune, must be in want of a wife.',
    'However little known the feelings or views of such a man may be on his '
        'first entering a neighbourhood, this truth is so well fixed in the '
        'minds of the surrounding families, that he is considered as the '
        'rightful property of some one or other of their daughters.',
  ]),
  _Book('Frankenstein', 'Mary Shelley', 'Letter 1', [
    'You will rejoice to hear that no disaster has accompanied the '
        'commencement of an enterprise which you have regarded with such evil '
        'forebodings.',
    'I arrived here yesterday, and my first task is to assure my dear sister '
        'of my welfare and increasing confidence in the success of my '
        'undertaking.',
  ]),
];
