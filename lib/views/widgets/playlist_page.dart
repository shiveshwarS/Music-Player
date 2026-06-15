import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/views/widgets/music_tile.dart';
import 'package:hertzz/utils.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  double _opacity = 1;

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<PlayerProvider>(context, listen: false);
    var t = Provider.of<NavigationProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (d, r) async {
        var t = Provider.of<NavigationProvider>(context, listen: false);
        if (t.extras) {
          t.extras = false;
        } else {
          t.playlist = false;
        }
        t.notify();
      },
      child: (t.songs == null)
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.grey[900],
                  expandedHeight: 200,
                  centerTitle: true,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      double opacity =
                          ((constraints.maxHeight / 200)).clamp(0.0, 1.0);
                      _opacity = opacity;
                      return Opacity(
                        opacity: opacity,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Image.network(
                                (t.link != null)
                                    ? fixDropboxUrl(t.link!)
                                    : fixDropboxUrl(
                                        t.songs![0].albumlink!),
                                fit: BoxFit.contain,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded &&
                                      frame == null) {
                                    return child;
                                  }
                                  return AnimatedOpacity(
                                    opacity: (frame != null) ? 1 : 0,
                                    duration: const Duration(
                                        milliseconds: 500),
                                    child: child,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(t: t, s: s),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 28),
                  sliver: Consumer<PlayerProvider>(
                    builder: (context, value, child) => (t.extras &&
                            t.name != "Favourites")
                        ? SliverList.builder(
                            itemCount: t.songs!.length,
                            itemBuilder: (context, index) {
                              return MusicTile(
                                name: t.songs![index].name!,
                                subname: t.songs![index].author!,
                                art: t.songs![index].albumlink,
                                index: index,
                                playlistname: t.name!,
                                s: s,
                                t: t,
                              );
                            })
                        : SliverReorderableList(
                            proxyDecorator: (child, index, animation) {
                              return Transform.scale(
                                scale: 0.7,
                                child: child,
                              );
                            },
                            itemCount: t.songs!.length,
                            onReorder: (oldIndex, newIndex) {
                              _swap(t, s, newIndex, oldIndex);
                            },
                            itemBuilder: (context, index) {
                              return ReorderableDelayedDragStartListener(
                                index: index,
                                key: Key("$index"),
                                child: MusicTile(
                                  name: t.songs![index].name!,
                                  subname: t.songs![index].author!,
                                  art: t.songs![index].albumlink,
                                  index: index,
                                  playlistname: t.name!,
                                  s: s,
                                  t: t,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  void _swap(NavigationProvider t, PlayerProvider s, int n, int o) {
    if (n > o) n--;
    var item = t.songs!.removeAt(o);
    t.songs!.insert(n, item);
    if (t.name == s.PlayListName) {
      s.songs = t.songs;
      if (s.index == o) {
        s.index = n;
      } else if (s.index! <= n && s.index! > o) {
        s.index = s.index! - 1;
      } else if (s.index! < o && s.index! >= n) {
        s.index = s.index! + 1;
      }
    }
    _saveOrder(t);
  }

  void _saveOrder(NavigationProvider t) {
    List<String> temp = List.generate(t.songs!.length, (i) => t.songs![i].name!);
    if (t.name != "Favourites") {
      Hive.box("playlist").put(t.name, temp);
    } else {
      Hive.box("favourite").put(0, temp);
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final NavigationProvider t;
  final PlayerProvider s;
  _StickyHeaderDelegate({required this.t, required this.s});

  Future<void> loadlist() async {
    s.state = 0;
    s.songs = t.songs;
    int index = Random().nextInt(t.songs!.length);
    s.PlayListName = t.name!;
    AudioHandlerService().h.pause();
    s.setIndex(index);
    s.notify();
    try {
      s.max = await AudioHandlerService().h.setSource(s.songs![index]);
      AudioHandlerService().h.play();
    } catch (_) {}
    s.notify();
  }

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double off = shrinkOffset / maxExtent;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        color: Color.lerp(
            Colors.grey[900],
            const Color.fromARGB(255, 189, 62, 23),
            off),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.name!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'robo',
                        ),
                      ),
                      if (t.extras && t.name == "Favourites")
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.favorite_rounded,
                              color: Colors.deepOrange, size: 25),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PlayerProvider>(
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, 20 * off),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade900,
                      border: Border.all(
                          width: 3,
                          color: const Color.fromARGB(255, 189, 62, 23)),
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (t.name != s.PlayListName) {
                            loadlist();
                          } else if (AudioHandlerService().h.playing) {
                            AudioHandlerService().h.pause();
                          } else {
                            AudioHandlerService().h.play();
                          }
                        },
                        icon: Icon(
                          (AudioHandlerService().h.playing &&
                                  t.name == s.PlayListName)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 30,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
