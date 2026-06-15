import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song_model.dart';

class AudioService {
  static const String link = "https://hon-florette-shiveshwars-5f981264.koyeb.app/";
  static const String meta = "metadata";
  static const String sonli = "song";
  static const String play = "playlist";
  static const String album = "albums";
  static const String albums = "artist";

  static Future<List<AudioModel>> retrieveAudios() async {
    var result = await http.get(Uri.parse("$link$meta"));
    List<AudioModel> res = [];
    for (var doc in jsonDecode(result.body)) {
      AudioModel temp = AudioModel(
        doc['name'],
        doc['author'],
        doc['albumtitle'],
        doc['albumlink'],
      );
      res.add(temp);
    }
    return res;
  }

  static Future<List<List<String>>> fetchArtistNames() async {
    var result = await http.get(Uri.parse("$link$album"));
    List<List<String>> names = [];
    for (var val in jsonDecode(result.body)) {
      names.add([val['artist'], val['link'] ?? '']);
    }
    return names;
  }

  static Future<List<AudioModel>> fetchArtistSongs(String name) async {
    var result = await http.get(Uri.parse("$link$albums?author=${Uri.encodeComponent(name)}"));
    List<AudioModel> res = [];
    for (var doc in jsonDecode(result.body)) {
      AudioModel temp = AudioModel(
        doc['name'],
        doc['author'],
        doc['albumtitle'],
        doc['albumlink'],
      );
      res.add(temp);
    }
    return res;
  }

  static Future<List<AudioModel>> fetchlPlayList(List<String> names) async {
    var result = await http.post(
      Uri.parse("$link${Uri.encodeComponent(play)}"),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"names": names}),
    );
    List<AudioModel> res = [];
    for (var doc in jsonDecode(result.body)) {
      AudioModel temp = AudioModel(
        doc['name'],
        doc['author'],
        doc['albumtitle'],
        doc['albumlink'],
      );
      res.add(temp);
    }
    return res;
  }

  static Future<String> fetch(String name) async {
    var result = await http.get(Uri.parse("$link$sonli?name=${Uri.encodeComponent(name)}"));
    return jsonDecode(result.body)['link'];
  }
}
