import 'dart:async';

import 'package:flutter/services.dart';

class Glimage {
  
  static Glimage _instance;
  static Glimage getInstance() {
    if (_instance == null) {
      _instance = new Glimage();
    }
    return _instance;
  }

  static Glimage get instance => getInstance();
  static const MethodChannel _channel = const MethodChannel('glimage');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }


  Future<int> image(String url, double width, double height) async {
    int textureImageId = await _channel.invokeMethod('image', {'width': width, 'height': height, "url": url});
    return textureImageId;
  }

  Future<Null> dispose(int textureId) => _channel.invokeMethod('dispose', {'textureId': textureId});

}
