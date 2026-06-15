import 'package:flutter/material.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/services/api_service.dart';

class LibraryProvider extends ChangeNotifier {
  List<AudioModel>? allSongs;
  List<List<String>>? artists;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    allSongs = await AudioService.retrieveAudios();
    allSongs!.shuffle();
    artists = await AudioService.fetchArtistNames();
    loading = false;
  }

  void notify() {
    notifyListeners();
  }

  List<AudioModel> search(String query) {
    if (query.isEmpty || allSongs == null) return [];
    final q = query.toLowerCase();
    return allSongs!.where((s) => s.name!.toLowerCase().contains(q)).toList();
  }
}
