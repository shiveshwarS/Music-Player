package com.hertzz.player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log


class MainActivity : FlutterActivity()
{
    
    private val CHANNEL = "flutter.temp.channel"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onStop() {
        super.onStop()
        Log.i("=== MainActivity ===", "onStop")
        methodChannel?.invokeMethod("destroy", null)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("=== MainActivity ===", "onDestroy")
        methodChannel?.invokeMethod("destroy", null)
    }
}
