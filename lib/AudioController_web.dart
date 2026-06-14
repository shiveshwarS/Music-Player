import 'dart:async';

import 'AudioService.dart' as ads;
import 'package:just_audio/just_audio.dart';

class MyAudioHandler {

    void dispose(){
      _audioPlayer.dispose();
      playerState.close();
    }

    List<ads.AudioModel>? songs;
    final _audioPlayer = AudioPlayer();

    Function? _next;
    Function? _prev;

    setPlayList(var songs){
      this.songs = songs;
    }

    setnext(Function next){
      _next = next;
    }

    setprev(Function prev){
      _prev = prev;
    }

    Stream<Duration?> get durationStream  => _audioPlayer.durationStream;
    Stream<Duration> get positionStream => _audioPlayer.positionStream;
    Stream<bool> get playingStream => _audioPlayer.playingStream;
    Stream<Duration> get bufferedPositionStream => _audioPlayer.bufferedPositionStream;
    bool get playing => _audioPlayer.playing;

    final playerState = StreamController<ProcessingState>.broadcast();
    Stream<ProcessingState> get playerstatestream => playerState.stream;

    static Future<MyAudioHandler> init() async {
      return MyAudioHandler();
    }

    MyAudioHandler(){
      _audioPlayer.playerStateStream.map((s)=>s.processingState).distinct().listen((onData){
          playerState.add(onData);
      }, onError: (_){});

      _audioPlayer.playbackEventStream.listen((_){}, onError: (_){});
    }

    Future<Duration> setSource(ads.AudioModel m)async{
      try{
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(await ads.AudioService.fetch(m.name!))));
      }catch(_){
      }
        return Future.delayed(Duration(milliseconds: 100),(){return _audioPlayer.duration ?? Duration.zero;});
    }

  Future<void> play() => _audioPlayer.play();

  Future<void> pause() => _audioPlayer.pause();

  void p() => _audioPlayer.pause();

  Future<void> seek(Duration position) async{
    await  _audioPlayer.seek(position);
  }

  Future<void> rewind() async{
  await  _audioPlayer.seek(Duration(seconds: 0));
  }

  Future<void> stop() => _audioPlayer.stop();

  void s() async{
    await _audioPlayer.stop();
  }

  Future<void> skipToNext() async{
    if(_next!=null){
      await _next!();
    }
  }

  Future<void> skipToPrevious() async{
    if(_prev!=null){
      _prev!();
    }
  }

}