import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/utils.dart';

Color? _colorScheme = Colors.grey.shade900;

class PlayBar extends StatefulWidget {
  const PlayBar({super.key});

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  bool isopen = false;
  StateSetter? ss;
  PageController? _controller;
  bool isloading = false;
  Duration? buff;
  bool seeking = false;
  bool skipchange = false;
  IconData play = Icons.pause_rounded;
  Box playlists = Hive.box("favourite");
  int? lastind;

  String FormatTime(Duration n) {
    String td(int n) => n.toString().padLeft(2, '0');
    return "${td(n.inMinutes)}:${td(n.inSeconds.remainder(60))}";
  }

  void like(String name, {bool liked = true}) {
    var s = Provider.of<PlayerProvider>(context, listen: false);
    List names = (playlists.get(0, defaultValue: <String>[]));
    if (liked) {
      names.add(name);
      playlists.put(0, names);
      if (s.PlayListName == "Favourites") {
        s.remove = false;
      }
    } else {
      if (s.PlayListName == "Favourites") {
        s.setdel(name, playlists, 0);
        s.remove = true;
      } else {
        names.remove(name);
        playlists.put(0, names);
      }
    }
    s.notify();
  }

  Future<void> loadnext(int? ind) async {
    PlayerProvider s =
        Provider.of<PlayerProvider>(context, listen: false);
    AudioHandlerService handler = AudioHandlerService();
    try {
      if (s.state == 2) {
        ind = s.index!;
        handler.h.seek(Duration.zero);
        return;
      } else if (s.state == 1) {
        ind = s.shuffeindex[(s.shufind++) % s.songs!.length];
      } else if (ind != null) {
        ind = ind % s.songs!.length;
      } else {
        ind = (s.index! + 1) % s.songs!.length;
      }
      bool r = s.remove;
      s.setIndex(ind,
          t: Provider.of<NavigationProvider>(context, listen: false));
      if (r && s.index! < ind) {
        ind--;
      }
      s.notify();
      if (ss != null && isopen) {
        ss!(() {});
      }
      if (isloading) {
        lastind = ind;
        return;
      }
      isloading = true;
      handler.h.pause();
      final dur = await handler.h.setSource(s.songs![s.index!]);
      if (s.index == ind % s.songs!.length && dur > Duration.zero) {
        handler.h.play();
      }
      isloading = false;
      s.notify();
    } catch (_) {
      isloading = false;
      s.notify();
    }
  }

  void _attachListeners(BuildContext context) {
    var handler = AudioHandlerService().h;
    handler.durationStream.listen((d) {
      var s = Provider.of<PlayerProvider>(context, listen: false);
      s.max = d ?? Duration.zero;
      s.notify();
    });
    handler.playingStream.listen((onData) {
      if (onData == true) {
        play = Icons.pause_rounded;
        isloading = false;
      } else {
        play = Icons.play_arrow_rounded;
      }
      if (ss != null && isopen) {
        ss!(() {});
      }
      Provider.of<PlayerProvider>(context, listen: false).notify();
    });
    handler.bufferedPositionStream.listen((b) {
      buff = b;
    });
    handler.playerstatestream.listen((stat) async {
      var s = Provider.of<PlayerProvider>(context, listen: false);
      if (stat == ProcessingState.loading) {
        if (!handler.playing) {
          isloading = true;
        }
        if (isopen && ss != null) {
          ss!(() {});
        }
      } else if (stat == ProcessingState.ready) {
        if (lastind == null) {
          var palette = (await PaletteGenerator.fromImageProvider(
              NetworkImage(s.currart!)));
          s.color = palette.darkVibrantColor?.color ??
              palette.darkVibrantColor?.color ??
              Colors.grey.shade900;
        }
        isloading = false;
        if (lastind != null) {
          var last = lastind;
          lastind = null;
          await handler.setSource(s.songs![last!]);
          handler.play();
        }
        if (isopen && ss != null) {
          ss!(() {});
        }
      }
      if (stat == ProcessingState.completed) {
        skipchange = true;
        loadnext(null);
        if (_controller != null && isopen) {
          if (s.state == 0 && !background) {
            _controller!.animateToPage(s.index ?? 0,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn);
          } else if (s.state == 1 || background) {
            _controller!.jumpToPage(s.index ?? 0);
          }
        }
      }
    });
    handler.positionStream.listen((d) async {
      if (seeking) return;
      isloading = false;
      if (mounted) {
        Provider.of<PlayerProvider>(context, listen: false).curr = d;
        if (isopen && ss != null) {
          ss!(() {});
        }
      }
    });
  }

  bool done = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void startup() {
    var handler = AudioHandlerService().h;
    handler.setnext(() {
      skipchange = true;
      loadnext(
          Provider.of<PlayerProvider>(context, listen: false).index! + 1);
      if (_controller != null && isopen) {
        _controller!.animateToPage(
            Provider.of<PlayerProvider>(context, listen: false).index ?? 0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }
    });

    handler.setprev(() {
      skipchange = true;
      loadnext(
          Provider.of<PlayerProvider>(context, listen: false).index! - 1);
      if (_controller != null && isopen) {
        _controller!.animateToPage(
            Provider.of<PlayerProvider>(context, listen: false).index ?? 0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        PlayerProvider s =
            Provider.of<PlayerProvider>(context, listen: false);
        s.setIndex(0);
        await handler.setSource(s.songs![0]);
      } catch (_) {}
      if (mounted) {
        isloading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startup();
    _controller = PageController(initialPage: 0);
    _attachListeners(context);
  }

  void playpause() {
    var handler = AudioHandlerService().h;
    if (handler.playing) {
      handler.pause();
    } else {
      handler.play();
    }
    isloading = false;
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    PlayerProvider s = Provider.of<PlayerProvider>(context, listen: true);

    return GestureDetector(
      onTap: () async {
        isopen = true;
        await showModalBottomSheet(
          useSafeArea: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          isScrollControlled: true,
          elevation: 0,
          context: context,
          builder: (c) {
            return StatefulBuilder(builder: (c, l) {
              ss = l;
              _controller = PageController(initialPage: s.index!);
              final maxSec = s.max.inSeconds.toDouble();
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          s.color!,
                          Colors.grey.shade900,
                        ],
                        stops: const [0, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: PageView.builder(
                              physics: s.state == 0
                                  ? const AlwaysScrollableScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: Provider.of<PlayerProvider>(
                                      context,
                                      listen: false)
                                  .songs!
                                  .length,
                              controller: _controller,
                              onPageChanged: (value) {
                                if (!skipchange &&
                                    1 == (value - s.index!).abs()) {
                                  if (s.remove) {
                                    _controller!.jumpToPage(value - 1);
                                  }
                                  loadnext(value);
                                } else {
                                  skipchange = false;
                                }
                              },
                              itemBuilder: (context, index) {
                                return Center(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 320,
                                      width: 320,
                                      child: s.currart != null
                                          ? Image.network(
                                              fixDropboxUrl(s
                                                  .songs![index]
                                                  .albumlink!),
                                              fit: BoxFit.contain,
                                              frameBuilder: (context,
                                                  child,
                                                  frame,
                                                  wasSynchronouslyLoaded) {
                                                return wasSynchronouslyLoaded &&
                                                        frame != null
                                                    ? child
                                                    : AnimatedOpacity(
                                                        opacity: frame ==
                                                                null
                                                            ? 0
                                                            : 1,
                                                        duration: const Duration(
                                                            milliseconds:
                                                                500),
                                                        child: child,
                                                      );
                                              },
                                            )
                                          : const Icon(
                                              Icons.music_note_rounded,
                                              size: 350),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                s.curname ?? "Select",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.curartist ?? "Select",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    activeTrackColor: Colors.deepOrange,
                                    inactiveTrackColor:
                                        const Color.fromARGB(115, 75, 75, 75),
                                    thumbColor: Colors.deepOrange,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6),
                                    overlayShape: SliderComponentShape
                                        .noOverlay,
                                  ),
                                  child: Slider(
                                    max: maxSec > 0 ? maxSec : 1,
                                    onChanged: (c) {
                                      ss!(() {
                                        seeking = true;
                                        s.curr = Duration(
                                            seconds: c.toInt());
                                      });
                                    },
                                    onChangeEnd: (c) {
                                      seeking = false;
                                      AudioHandlerService()
                                          .h
                                          .seek(s.curr);
                                    },
                                    value: s.curr.inSeconds
                                        .clamp(0, maxSec.toInt())
                                        .toDouble(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        FormatTime(s.curr),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        FormatTime(s.max),
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 280,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                _controlIcon(
                                  s.state == 0
                                      ? Icons.shuffle_rounded
                                      : s.state == 1
                                          ? Icons.shuffle_on_rounded
                                          : Icons.repeat_rounded,
                                  () {
                                    s.state = (s.state + 1) % 3;
                                    if (s.state == 1) s.recalcshuff();
                                    ss!(() {});
                                  },
                                  color: s.state != 0
                                      ? Colors.deepOrange
                                      : Colors.white,
                                ),
                                _controlIcon(
                                    Icons.skip_previous_rounded, () {
                                  skipchange = true;
                                  loadnext(s.index! - 1);
                                  if (_controller != null && isopen) {
                                    if (s.state == 0) {
                                      _controller!.animateToPage(
                                          Provider.of<PlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .index!,
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.fastOutSlowIn);
                                    } else {
                                      _controller!.jumpToPage(
                                          Provider.of<PlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .index!);
                                    }
                                  }
                                }),
                                SizedBox(
                                  height: 64,
                                  width: 64,
                                  child: isloading
                                      ? const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3),
                                        )
                                      : IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(play,
                                              color: Colors.white,
                                              size: 48),
                                          onPressed: () => playpause(),
                                        ),
                                ),
                                _controlIcon(
                                    Icons.skip_next_rounded, () {
                                  skipchange = true;
                                  loadnext(s.index! + 1);
                                  if (_controller != null && isopen) {
                                    if (s.state == 0) {
                                      _controller!.animateToPage(
                                          Provider.of<PlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .index!,
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.fastOutSlowIn);
                                    } else {
                                      _controller!.jumpToPage(
                                          Provider.of<PlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .index!);
                                    }
                                  }
                                }),
                                _controlIcon(
                                  Icons.favorite_outline,
                                  () {
                                    ss!(() {
                                      s.isliked = !s.isliked;
                                      like(s.curname!,
                                          liked: s.isliked);
                                    });
                                  },
                                  color: s.isliked
                                      ? Colors.deepOrange
                                      : Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
            });
          },
        );
        isopen = false;
      },
      child: Container(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: (s.currart != null)
                      ? Image.network(fixDropboxUrl(s.currart!),
                          fit: BoxFit.cover)
                      : const Icon(Icons.music_note_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.curname ?? "Select",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      s.curartist ?? "Select",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(play, color: Colors.white, size: 32),
                onPressed: () => playpause(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlIcon(IconData icon, VoidCallback onTap,
      {Color color = Colors.white}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 28, color: color),
    );
  }
}
