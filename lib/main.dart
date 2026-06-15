import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hertzz/services/hive_service.dart';
import 'package:hertzz/services/audio_handler_service.dart';
import 'package:hertzz/views/app.dart';

void main() async {
  WidgetsBinding w = WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: w);
  }

  await AudioHandlerService().init();

  final designSize = kIsWeb
      ? Size(
          w.platformDispatcher.views.first.physicalSize.width /
              w.platformDispatcher.views.first.devicePixelRatio,
          w.platformDispatcher.views.first.physicalSize.height /
              w.platformDispatcher.views.first.devicePixelRatio,
        )
      : const Size(360, 690);

  runApp(
    ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: designSize,
      builder: (context, child) {
        ScreenUtil.configure(data: MediaQuery.of(context));
        return const App();
      },
    ),
  );
}
