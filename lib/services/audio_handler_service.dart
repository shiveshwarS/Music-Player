import 'package:hertzz/AudioController.dart';

class AudioHandlerService {
  static final AudioHandlerService _instance = AudioHandlerService._internal();
  factory AudioHandlerService() => _instance;
  AudioHandlerService._internal();

  late final MyAudioHandler handler;

  Future<void> init() async {
    handler = await MyAudioHandler.init();
  }

  void dispose() {
    handler.dispose();
  }

  MyAudioHandler get h => handler;
}
