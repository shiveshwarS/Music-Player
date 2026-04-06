import 'dart:math';

import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:hive/hive.dart';
import './AudioService.dart';

class SongProvider extends ChangeNotifier{

  SongProvider(var song,var artist){
    Artist = artist;
    songs = song;
    temp = songs;
  }

  String? currart;
  String? curname,curartist;
  Duration curr = Duration.zero;
  Duration max = Duration.zero;
  bool isliked = false;
  bool remove = false;
  List<AudioModel>? songs;
  List<AudioModel>? temp;
  Color? color = Colors.grey.shade900;
  List<int> shuffeindex= [];
  int shufind = 0;
  int state = 0;

  void recalcshuff(){
    shufind = 1;
    shuffeindex.clear();
    shuffeindex.addAll(List.generate(songs!.length, (i)=>i)..shuffle());
    int i = shuffeindex.indexOf(index!%songs!.length);
    print(shuffeindex[i]);
    int temp = shuffeindex[i];
    shuffeindex[i] = shuffeindex[0];
    shuffeindex[0] = temp;
  }

  List<List<String>>? Artist;

  int? index;
  String PlayListName = "none";

  void setsongs(List<AudioModel> s){
    songs = s;
  }

  void reset(){
    songs = temp;
    PlayListName = "none";
  }


  String? delname;
  Box? hive;
  dynamic? key;

  void setdel(String d, Box box, dynamic key){
    delname = d;
    hive = box;
    this.key = key;
  }

  void setIndex(int ind,{bool changed = false, tabProvider? t})async{
    if(!changed && remove){
      songs!.removeAt(index!);
      if(index! < ind){
        ind--;
      }
      if(songs!.isNotEmpty){
        ind = ind%songs!.length;
        recalcshuff();
      }
    }
    if(remove && hive != null){
      try{
      List<String> names = (hive!.get(key,defaultValue: <String>[]));
      names.remove(delname);
      hive!.put(key, names);
      hive = null;
      }catch(e,a){
        print("$e $a");
      }
    }

    remove = false;

    if(songs!.isEmpty){
      reset();
      t!.extras = false;
      t.notify();
    }

    index = ind%songs!.length;
    curname = songs![index!].name;
    curartist = songs![index!].author;
    curr = Duration.zero;
    currart = songs![index!].albumlink!;
    isliked = (Hive.box("favourite").get(0,defaultValue: <String>[]) as List<String>).contains(curname!);
  }

  void notify(){
    notifyListeners();
  }

}

class tabProvider extends ChangeNotifier{
  int tabindex = 1;
  bool extras = false;
  bool playlist = false;
  List<AudioModel>? songs;
  String? name;
  String? link;

  void set(var name, var songs,[var l]){
    link = l;
    this.name = name;
    this.songs = songs;
    notifyListeners();
  }

  void notify(){
    notifyListeners();
  }
}