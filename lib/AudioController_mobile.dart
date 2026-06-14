import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'AudioService.dart' as ads;
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler{


    void dispose(){
      _audioPlayer.dispose();
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
      return await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidStopForegroundOnPause: false,
          androidNotificationIcon: 'drawable/notif',
          androidNotificationChannelId: 'com.hertzz.player',
          androidNotificationChannelName: 'Music Playback',
        ),
      );
    }

    MyAudioHandler(){
      _audioPlayer.playerStateStream.map((s)=>s.processingState).distinct().listen((onData){
          playerState.add(onData);
      });

      _audioPlayer.playbackEventStream.listen((event) {
  final playing = _audioPlayer.playing;
  final processingState = {
    ProcessingState.idle: AudioProcessingState.idle,
    ProcessingState.loading: AudioProcessingState.loading,
    ProcessingState.buffering: AudioProcessingState.buffering,
    ProcessingState.ready: AudioProcessingState.ready,
    ProcessingState.completed: AudioProcessingState.completed,
  }[_audioPlayer.processingState]!;

  playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: null,
    ),
  );
});
    }

    Future<Duration> setSource(ads.AudioModel m)async{
      try{
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(await ads.AudioService.fetch(m.name!))));
      mediaItem.add(
        MediaItem(
          id: m.name!,
          title: m.name!,
          artist: m.author,
          artUri: Uri.parse(m.albumlink!),
          duration: _audioPlayer.duration??Duration.zero
        )
        );
      }catch(_){
      }
        return Future.delayed(Duration(milliseconds: 100),(){return _audioPlayer.duration ?? Duration.zero;});
    }

    @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  void p() => _audioPlayer.pause();

  @override
  Future<void> seek(Duration position) async{
    await  _audioPlayer.seek(position);
    playbackState.add(playbackState.value.copyWith(
      updatePosition: _audioPlayer.position
    ));
  }

  @override
  Future<void> rewind() async{
  await  _audioPlayer.seek(Duration(seconds: 0));
  }

  @override
  Future<void> stop() => _audioPlayer.stop();

  void s() async{
    await _audioPlayer.stop();
  }

  @override
  Future<void> skipToNext() async{
    if(_next!=null){
      await _next!();
    }
  }

  @override
  Future<void> skipToPrevious() async{
    if(_prev!=null){
      _prev!();
    }
  }

}