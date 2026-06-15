import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/utils.dart';

class MusicTile extends StatefulWidget {
  final String name;
  final String subname;
  final String? art;
  final int index;
  final String playlistname;
  final NavigationProvider t;
  final PlayerProvider s;

  const MusicTile({
    super.key,
    required this.name,
    required this.subname,
    required this.art,
    required this.index,
    required this.playlistname,
    required this.s,
    required this.t,
  });

  @override
  State<MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  final MenuController mc = MenuController();
  final box = Hive.box("playlist");

  void addPlaylist(
      String p, String n, String subname, String art, String albumtitle) {
    List before = box.get(p, defaultValue: <String>[]);
    if (before.contains(n)) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Song Already Exists in $p")));
    }
    before.add(n);
    box.put(p, before);
    if (widget.s.PlayListName == widget.t.name) {
      widget.s.songs!
          .add(AudioModel(widget.name, subname, albumtitle, art));
    }
  }

  void _showPlaylistPicker() {
    final names = _getPlaylistNames();
    showAdaptiveDialog(
      context: context,
      builder: (c) {
        return Dialog(
          backgroundColor: Colors.grey.shade900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Select a PlayList :",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
              SizedBox(
                height: (names.length < 5)
                    ? names.length * 31.0 + 31
                    : MediaQuery.of(context).size.height / 4,
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (c, i) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          minWidth: MediaQuery.sizeOf(context).width / 1.5,
                          child: Text(names[i],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13)),
                          onPressed: () {
                            addPlaylist(names[i], widget.name, widget.subname,
                                widget.art!, "");
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  content: Text(
                                      "Song Added to ${names[i]} Successfully"),
                                  duration: const Duration(seconds: 2)));
                            mc.close();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getPlaylistNames() {
    final box = Hive.box("playlistnames");
    List<String> names = [];
    box.toMap().forEach((key, value) {
      names.add(value.toString());
    });
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final handler = AudioHandlerService().h;
    final isCurrent =
        widget.s.PlayListName == widget.playlistname && widget.s.index == widget.index;

    return GestureDetector(
      onTap: () async {
        if (widget.s.index == widget.index &&
            widget.s.PlayListName == widget.playlistname) return;
        var pname = widget.s.PlayListName;
        if (widget.t.playlist || widget.t.extras) {
          widget.s.state = 0;
          widget.s.songs = widget.t.songs;
          widget.s.PlayListName = widget.t.name!;
        } else if (widget.t.tabindex != 2) {
          widget.s.state = 0;
          widget.s.reset();
        }
        handler.pause();
        widget.s.setIndex(widget.index,
            changed: (pname != widget.s.PlayListName), t: widget.t);
        widget.s.notify();
        try {
          widget.s.max =
              await handler.setSource(widget.s.songs![widget.index]);
          handler.play();
        } catch (_) {}
        widget.s.notify();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isCurrent ? Colors.deepOrange.withOpacity(0.08) : Colors.transparent,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 44,
                width: 44,
                child: (widget.art != null)
                    ? Image.network(fixDropboxUrl(widget.art!),
                        fit: BoxFit.cover)
                    : Icon(Icons.music_note_rounded, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? Colors.deepOrange : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subname,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isCurrent && handler.playing)
              SizedBox(
                width: 28,
                height: 28,
                child: LottieBuilder.network(
                  "https://lottie.host/1b7f1b7d-f6ac-467a-8650-817c5ffa5557/hvaWf6ycmf.json",
                  fit: BoxFit.cover,
                ),
              ),
            MenuAnchor(
              controller: mc,
              style: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.grey.shade800),
              ),
              builder: (context, controller, child) {
                return IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.white54, size: 22),
                  onPressed: () {
                    controller.isOpen ? controller.close() : controller.open();
                  },
                );
              },
              menuChildren: [
                GestureDetector(
                  onTap: () {
                    _showPlaylistPicker();
                  },
                  child: Container(
                    color: Colors.grey.shade800,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      (widget.playlistname == "none" || widget.t.extras)
                          ? "Add to PlayList"
                          : "Add to Another PlayList",
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ),
                ),
                if (widget.playlistname != "none" && !widget.t.extras)
                  GestureDetector(
                    onTap: () {
                      removeFromPlaylist();
                      mc.close();
                    },
                    child: Container(
                      color: Colors.grey[800],
                      padding: const EdgeInsets.all(5),
                      child: Text("Remove From Playlist",
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void removeFromPlaylist() async {
    var p = Hive.box("playlist");
    List<String> temp = p.get(widget.playlistname);
    temp.removeAt(widget.index);
    p.put(widget.playlistname, temp);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Song Removed Successfully"),
        duration: const Duration(seconds: 2)));

    if (widget.s.PlayListName == widget.t.name &&
        widget.s.index == widget.index) {
      widget.s.songs!.removeAt(widget.index);
      widget.s.setIndex(widget.index);
      if (widget.t.songs!.isEmpty) {
        widget.t.extras = widget.t.playlist = false;
        widget.t.notify();
      }
      await AudioHandlerService().h.stop();
      try {
        await AudioHandlerService()
            .h
            .setSource(widget.s.songs![widget.index]);
        AudioHandlerService().h.play();
      } catch (_) {}
      widget.s.recalcshuff();
    } else if (widget.s.PlayListName == widget.t.name) {
      widget.s.songs!.removeAt(widget.index);
      if (widget.index < widget.s.index!) {
        widget.s.index = widget.s.index! - 1;
      }
      widget.s.recalcshuff();
    } else {
      widget.t.songs!.removeAt(widget.index);
    }
    widget.s.notify();
    if (widget.t.songs!.isEmpty) {
      widget.t.extras = widget.t.playlist = false;
      widget.t.notify();
    }
  }
}
