import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox("playlistnames");
    await Hive.openBox("playlist");
    await Hive.openBox("favourite");
  }

  Box get _favourite => Hive.box("favourite");
  Box get _playlist => Hive.box("playlist");
  Box get _playlistNames => Hive.box("playlistnames");

  // Favourites
  List<String> getFavourites() {
    return List<String>.from(_favourite.get(0, defaultValue: <String>[]) ?? []);
  }

  void addFavourite(String name) {
    final list = getFavourites();
    list.add(name);
    _favourite.put(0, list);
  }

  void removeFavourite(String name) {
    final list = getFavourites();
    list.remove(name);
    _favourite.put(0, list);
  }

  void setFavourites(List<String> names) {
    _favourite.put(0, names);
  }

  bool isFavourite(String name) {
    return getFavourites().contains(name);
  }

  // Playlist names
  List<String> getPlaylistNames() {
    List<String> names = [];
    _playlistNames.toMap().forEach((key, value) {
      names.add(value.toString());
    });
    return names;
  }

  void addPlaylistName(String name) {
    _playlistNames.add(name);
  }

  void deletePlaylistName(int index) {
    _playlistNames.deleteAt(index);
  }

  // Playlist songs
  List<String> getPlaylistSongs(String playlistName) {
    final raw = _playlist.get(playlistName);
    return raw is List ? List<String>.from(raw) : [];
  }

  void addToPlaylist(String playlistName, String songName) {
    final list = getPlaylistSongs(playlistName);
    list.add(songName);
    _playlist.put(playlistName, list);
  }

  void removeFromPlaylist(String playlistName, int index) {
    final list = getPlaylistSongs(playlistName);
    list.removeAt(index);
    _playlist.put(playlistName, list);
  }

  void setPlaylistSongs(String playlistName, List<String> songs) {
    _playlist.put(playlistName, songs);
  }

  void deletePlaylist(String name) {
    _playlist.delete(name);
  }

  // Currently playing song indicator
  bool isPlaylistEmpty(String name) {
    return getPlaylistSongs(name).isEmpty;
  }
}
