import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/services/api_service.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/views/widgets/hover_boxes.dart';
import 'package:hertzz/utils.dart';

class PlaylistGrid extends StatefulWidget {
  const PlaylistGrid({super.key});

  @override
  State<PlaylistGrid> createState() => _PlaylistGridState();
}

class _PlaylistGridState extends State<PlaylistGrid> {
  final TextEditingController _tc = TextEditingController();
  List<String> _playlistNames = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylistNames();
  }

  void _loadPlaylistNames() {
    final box = Hive.box("playlistnames");
    _playlistNames = box.toMap().values.map((v) => v.toString()).toList();
  }

  Future<void> loadPlaylist(String name, {bool play = false}) async {
    var t = Provider.of<NavigationProvider>(context, listen: false);
    var s = Provider.of<PlayerProvider>(context, listen: false);
    if (play && s.PlayListName == name) return;
    List<String>? names;
    await Hive.openBox(name);
    final raw = Hive.box("playlist").get(name);
    names = raw is List ? List<String>.from(raw) : null;
    if (names == null || names.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PlayList is Empty"),
              duration: const Duration(seconds: 3)));
      return;
    }
    List<AudioModel> res = await AudioService.fetchlPlayList(names);
    res.sort((a, b) {
      return names!.indexOf(a.name!).compareTo(names.indexOf(b.name!));
    });
    if (play) {
      Provider.of<NavigationProvider>(context, listen: false).set(name, res);
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
    } else {
      Provider.of<NavigationProvider>(context, listen: false).playlist = true;
      Provider.of<NavigationProvider>(context, listen: false).set(name, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<PlayerProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.zero,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: _playlistNames.length + 1,
        itemBuilder: (itemBuilder, i) {
          String? link;
          if (i != 0) {
            List list = Hive.box("playlist").get(_playlistNames[i - 1], defaultValue: []);
            if (list.isNotEmpty) {
              link = Provider.of<PlayerProvider>(context)
                  .temp!
                  .firstWhere((s) => s.name == list[0])
                  .albumlink;
            }
          }
          return (i == 0)
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      showAdaptiveDialog(
                        context: context,
                        builder: (builder) {
                          return Dialog(
                            backgroundColor: Colors.grey.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _tc,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: MaterialButton(
                                      color: Colors.grey.shade900,
                                      onPressed: () {
                                        if (_tc.text.isNotEmpty) {
                                          if (_playlistNames.contains(_tc.text)) {
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Playlist with Name ${_tc.text} Already Exists")));
                                            return;
                                          }
                                          Hive.box("playlistnames").add(_tc.text);
                                          setState(() {
                                            _loadPlaylistNames();
                                          });
                                          Navigator.of(context).pop();
                                          _tc.clear();
                                        }
                                      },
                                      child: const FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text("Create",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(Icons.add,
                            size: 35, color: Colors.white54),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await loadPlaylist(_playlistNames[i - 1]);
                        },
                        child: hoverbox(
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 0.7,
                                child: (link != null)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                            fixDropboxUrl(link),
                                            fit: BoxFit.cover))
                                    : const FittedBox(
                                        fit: BoxFit.contain,
                                        child: Icon(
                                            Icons.music_note_rounded,
                                            size: 180)),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: double.infinity,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(128),
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(5)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      _playlistNames[i - 1],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'robo',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await loadPlaylist(_playlistNames[i - 1], play: true);
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Transform.translate(
                            offset: const Offset(15, 20),
                            child: FittedBox(
                              child: SizedBox(
                                height: 60,
                                width: 60,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        (s.PlayListName == _playlistNames[i - 1])
                                            ? Icons.pause_circle_rounded
                                            : Icons.play_circle_rounded,
                                        size: 55,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: MenuAnchor(
                          style: MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Colors.grey.shade800),
                          ),
                          controller: MenuController(),
                          builder: (context, controller, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(5)),
                                color: Colors.black.withAlpha(102),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.more_horiz,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  controller.isOpen
                                      ? controller.close()
                                      : controller.open();
                                },
                              ),
                            );
                          },
                          menuChildren: [
                            MenuItemButton(
                              onPressed: () {
                                _deletePlaylist(i - 1);
                              },
                              child: Text("Delete",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  void _deletePlaylist(int i) {
    try {
      Hive.box("playlistnames").deleteAt(i);
      Hive.box("playlist").delete(_playlistNames[i]);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${_playlistNames[i]} Removed Successfully")));
      setState(() {
        _loadPlaylistNames();
      });
    } catch (e, a) {
      print("$e $a");
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }
}
