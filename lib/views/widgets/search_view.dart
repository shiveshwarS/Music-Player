import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/views/widgets/music_tile.dart';

class SearchView extends StatefulWidget {
  final List<AudioModel>? songs;
  const SearchView({super.key, required this.songs});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _tec = TextEditingController();
  List<AudioModel>? _result;
  List<int>? _indices;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _tec.addListener(() {
      if (_tec.text.isNotEmpty) {
        _fetchSongs(_tec.text.toLowerCase());
      } else {
        setState(() {
          _count = 0;
          _result = null;
          _indices = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tec.dispose();
    super.dispose();
  }

  Future<void> _fetchSongs(String text) async {
    _indices = [];
    _result = [];
    for (int i = 0; i < widget.songs!.length; i++) {
      if (widget.songs![i].name!.toLowerCase().contains(text)) {
        _indices!.add(i);
        _result!.add(widget.songs![i]);
      }
    }
    setState(() {
      _count = _result!.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<PlayerProvider>(context);
    final t = Provider.of<NavigationProvider>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _tec,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.white54),
              filled: true,
              fillColor: const Color.fromARGB(200, 255, 255, 255),
              hintText: "Search a Song",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: _count,
            itemBuilder: (context, index) {
              return MusicTile(
                name: _result![index].name!,
                subname: _result![index].author!,
                art: _result![index].albumlink,
                index: _indices![index],
                playlistname: "none",
                s: s,
                t: t,
              );
            },
          ),
        ),
      ],
    );
  }
}
