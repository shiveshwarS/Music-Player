import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/viewmodels/library_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/utils.dart';
import 'package:hertzz/views/mobile_layout.dart';
import 'package:hertzz/views/web_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lib = context.read<LibraryProvider>();
      final player = context.read<PlayerProvider>();
      await lib.load();
      player.Artist = lib.artists;
      player.temp = lib.allSongs;
      player.songs = lib.allSongs;
      lib.notify();
      player.notify();
      if (!kIsWeb) {
        FlutterNativeSplash.remove();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      background = true;
    }
    if (state == AppLifecycleState.resumed) {
      background = false;
    }
    if (state == AppLifecycleState.detached) {
      AudioHandlerService().h.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return const WebLayout();
        }
        return const MobileLayout();
      },
    );
  }
}
