import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/services/api_service.dart';
import 'package:hertzz/utils.dart';

class ArtistCard extends StatefulWidget {
  final List<List<String>> names;

  const ArtistCard({super.key, required this.names});

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
  Future<void> loadPlaylist(String name, int ind, {bool play = false}) async {
    var t = Provider.of<NavigationProvider>(context, listen: false);
    List<AudioModel> res;

    if (name == "Favourites") {
      List<String>? names;
      await Hive.openBox(name);
      final raw2 = Hive.box("favourite").get(0);
      names = raw2 is List ? List<String>.from(raw2) : null;
      res = await AudioService.fetchlPlayList(names!);
      res.sort((a, b) {
        return names!.indexOf(a.name!).compareTo(names.indexOf(b.name!));
      });
    } else {
      res = await AudioService.fetchArtistSongs(name);
    }
    t.extras = true;
    Provider.of<NavigationProvider>(context, listen: false).set(
        name, res,
        (name != "Favourites")
            ? (widget.names[ind][1].isEmpty)
                ? null
                : widget.names[ind][1]
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: widget.names.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              loadPlaylist(widget.names[index][0], index);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        child: (widget.names[index][0] == "Favourites")
                            ? Image.asset("assets/fav_img.png",
                                fit: BoxFit.contain)
                            : Image.network(
                                fixDropboxUrl(widget.names[index][1]),
                                fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            widget.names[index][0],
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.names[index][0] == "Favourites")
                          const Icon(Icons.favorite_rounded,
                              color: Colors.red, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
