import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:glimage/glimage.dart';
import 'package:glimage/flutter_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  var images = {
    0: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790452308&di=e461f1fd43aa67086364ccb7f6812085&imgtype=0&src=http%3A%2F%2Fpic.kekenet.com%2F2013%2F0522%2F46061369189999.jpg',
    1: "https://tiqmgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594731096956&di=47dc6f7a3077fa10c7e21c8e83b2c096&imgtype=0&src=http%3A%2F%2Fimg1001.pocoimg.cn%2Fimage%2Fpoco%2Fworks%2F38%2F2012%2F0715%2F18%2F190755412012071518144802_19075541.jpg",
    2: 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2673831645,421410337&fm=26&gp=0.jpg',
    3: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790452308&di=e461f1fd43aa67086364ccb7f6812085&imgtype=0&src=http%3A%2F%2Fpic.kekenet.com%2F2013%2F0522%2F46061369189999.jpg',
    4: 'https://ss0.bqdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2976939798,1355048254&fm=26&gp=0.jpg',
    5: 'https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3987622218,1684614982&fm=26&gp=0.jpg',
    6: 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=335940438,3350525794&fm=26&gp=0.jpg',
    7: 'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3728185531,84166138&fm=26&gp=0.jpg',
    8: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790646806&di=61d2d9a13773078a8242235d9e2515b3&imgtype=0&src=http%3A%2F%2Fwww.newagebd.com%2Ffiles%2Frecords%2Fnews%2F201902%2F65304_13.jpg',
    9: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=4191397697,300274189&fm=26&gp=0.jpg',
    10: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2879688894,2633096424&fm=26&gp=0.jpg',
    11: 'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2076568531,3765541260&fm=26&gp=0.jpg',
    12: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790712494&di=b18dcd8f9ac6bb6f2525f8edbb1db37f&imgtype=0&src=http%3A%2F%2Fpic1.zhimg.com%2Fv2-d1e3b0e40bc910e02d8c4893f9a94bfe_1200x500.jpg',
    13: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790742725&di=c87eeb06000f44259bf08d43ea8c557b&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201202%2F24%2F20120224154155_sFEWS.jpg',
    14: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2867691760,498559252&fm=26&gp=0.jpg',
    15: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790823364&di=41f25f3fd43eb25bcc6d9d0d762c50a9&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20180106%2F3470555112e44479beed9127d462a16a.jpeg',
    16: 'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=620364305,650707636&fm=26&gp=0.jpg',
    17: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790858947&di=8a43e6377142dcf3455b23305172c9ab&imgtype=0&src=http%3A%2F%2Fimg.zxxk.com%2F2013-8%2FZXXKCOM201308081322040099643.jpg',
    18: 'https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1258484961,2037325107&fm=26&gp=0.jpg',
    19: 'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2904826298,3473634569&fm=26&gp=0.jpg',
    20: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1960048067,4099992025&fm=26&gp=0.jpg',
    21: 'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2847624867,1888066750&fm=26&gp=0.jpg',
    22: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=111929972,3791579280&fm=26&gp=0.jpg',
    23: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1969629798,637492094&fm=26&gp=0.jpg',
    24: 'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1990999002,2867668542&fm=26&gp=0.jpg',
    25: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790971101&di=0db8cea52f23e4b89bbf9ed93ed1683a&imgtype=0&src=http%3A%2F%2Fdimg02.c-ctrip.com%2Fimages%2Ftg%2F812%2F568%2F621%2F0c161d01db2742c78d73d564f9677951_R_710_10000.jpg',
    26: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790971089&di=4b10daac1bdf704f701d0ba01dab500e&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fphotoblog%2F1202%2F13%2Fc8%2F10420644_10420644_1329139414500.jpg',
    27: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790452308&di=e461f1fd43aa67086364ccb7f6812085&imgtype=0&src=http%3A%2F%2Fpic.kekenet.com%2F2013%2F0522%2F46061369189999.jpg',
    28: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594790452308&di=e461f1fd43aa67086364ccb7f6812085&imgtype=0&src=http%3A%2F%2Fpic.kekenet.com%2F2013%2F0522%2F46061369189999.jpg',
  };
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
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
      showPerformanceOverlay:true,
      debugShowCheckedModeBanner: true,

      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: ListView.builder(
            itemCount: 25,
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: 200,
              height: 200,
              child: CachedNetworkImage(
                imageUrl:images[index],
                width:200,
                height:200,
                errorWidget: (context, url, error) {
                  return Icon(Icons.error);
                },
                placeholder: (context, url) {
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    new TextViewController._(id).setText("hello android");
  }
}

class TextViewController {
  TextViewController._(int id) : _channel = new MethodChannel('plugins.felix.angelov/textview_$id');

  final MethodChannel _channel;

  Future<void> setText(String text) async {
    assert(text != null);
    return _channel.invokeMethod('setText', text);
  }
}
