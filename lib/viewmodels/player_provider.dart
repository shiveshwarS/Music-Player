import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hertzz/models/song_model.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';

class PlayerProvider extends ChangeNotifier {
  String? currart;
  String? curname, curartist;
  Duration curr = Duration.zero;
  Duration max = Duration.zero;
  bool isliked = false;
  bool remove = false;
  List<AudioModel>? songs;
  List<AudioModel>? temp;
  Color? color = Colors.grey.shade900;
  List<int> shuffeindex = [];
  int shufind = 0;
  int state = 0;
  int? index;
  String PlayListName = "none";

  void setsongs(List<AudioModel> s) {
    songs = s;
  }

  void reset() {
    songs = temp;
    PlayListName = "none";
  }

  List<List<String>>? Artist;

  String? delname;
  dynamic hive;
  dynamic? key;

  void setdel(String d, dynamic box, dynamic key) {
    delname = d;
    hive = box;
    this.key = key;
  }

  void recalcshuff() {
    shufind = 1;
    shuffeindex.clear();
    shuffeindex.addAll(List.generate(songs!.length, (i) => i)..shuffle());
    int i = shuffeindex.indexOf(index! % songs!.length);
    int temp = shuffeindex[i];
    shuffeindex[i] = shuffeindex[0];
    shuffeindex[0] = temp;
  }

  void setIndex(int ind, {bool changed = false, NavigationProvider? t}) async {
    if (!changed && remove) {
      songs!.removeAt(index!);
      if (index! < ind) {
        ind--;
      }
      if (songs!.isNotEmpty) {
        ind = ind % songs!.length;
        recalcshuff();
      }
    }
    if (remove && hive != null) {
      try {
        List<String> names = (hive!.get(key, defaultValue: <String>[]));
        names.remove(delname);
        hive!.put(key, names);
        hive = null;
      } catch (e, a) {
        print("$e $a");
      }
    }

    remove = false;

    if (songs!.isEmpty) {
      reset();
      t!.extras = false;
      t.notify();
    }

    index = ind % songs!.length;
    curname = songs![index!].name;
    curartist = songs![index!].author;
    curr = Duration.zero;
    currart = songs![index!].albumlink!;
    final fav = Hive.box("favourite").get(0, defaultValue: <String>[]);
    isliked = fav is List ? fav.cast<String>().contains(curname!) : false;
  }

  void notify() {
    notifyListeners();
  }
}
