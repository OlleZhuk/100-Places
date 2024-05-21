package com.example.favorite_places_13

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    MapKitFactory.setApiKey("e0551ba3-0ace-4156-bcfd-a46d7fa04144") // Your generated API key
    super.configureFlutterEngine(flutterEngine)
  }

}