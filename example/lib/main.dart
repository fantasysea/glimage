import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:glimage/glimage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Glimage _controller = new Glimage();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initializeController(); 
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Glimage.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new Center(
        child: new Container(
          width: 200,
          height: 200,
          child: _controller.isInitialized ? new Texture(textureId: _controller.textureId) : null,
        ),
      ),
    ));
  }

  Future<Null> initializeController() async {
    await _controller.initialize(200, 200);
    setState(() {});
  }
}
