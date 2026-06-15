import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/views/widgets/music_tile.dart';
import 'package:hertzz/views/widgets/artist_card.dart';

class HomeContent extends StatelessWidget {
  final List<AudioModel>? songs;

  const HomeContent({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final l = Hive.box("favourite").get(0, defaultValue: <String>[]) ?? [];
    final s = Provider.of<PlayerProvider>(context);
    final t = Provider.of<NavigationProvider>(context, listen: false);
    final favList = (l as List).cast<String>();
    final hasFavourites = favList.isNotEmpty && !(favList.length == 1 && s.remove);

    return Padding(
      padding: EdgeInsets.zero,
      child: ListView.builder(
        itemCount: songs!.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    "Artists",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "robo",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ArtistCard(names: s.Artist!),
              ],
            );
          } else if (index == 1) {
            return hasFavourites
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          "Favourites",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "robo",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ArtistCard(names: const [["Favourites", '']]),
                    ],
                  )
                : const SizedBox.shrink();
          } else {
            return MusicTile(
              name: songs![index - 2].name!,
              subname: songs![index - 2].author!,
              art: songs![index - 2].albumlink,
              index: index - 2,
              playlistname: "none",
              s: s,
              t: t,
            );
          }
        },
      ),
    );
  }
}
