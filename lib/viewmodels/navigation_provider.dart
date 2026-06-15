import 'package:flutter/material.dart';

import '../models/song_model.dart';

class NavigationProvider extends ChangeNotifier {
  int tabindex = 1;
  bool extras = false;
  bool playlist = false;
  List<AudioModel>? songs;
  String? name;
  String? link;

  void set(name, songs, [l]) {
    link = l;
    this.name = name;
    this.songs = songs;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
