import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'glimage.dart';

typedef Widget ImageWidgetBuilder(BuildContext context, ImageProvider imageProvider);
typedef Widget PlaceholderWidgetBuilder(BuildContext context, String url);
typedef Widget LoadingErrorWidgetBuilder(BuildContext context, String url, dynamic error);

class FlutterImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  /// Optional builder to further customize the display of the image.
  final ImageWidgetBuilder imageBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final PlaceholderWidgetBuilder placeholder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final LoadingErrorWidgetBuilder errorWidget;

  FlutterImage(
      {Key key,
      this.imageUrl,
      this.width = double.infinity,
      this.height = double.infinity,
      this.placeholder,
      this.errorWidget,
      this.imageBuilder})
      : assert(imageUrl != null),
        super(key: key);

  @override
  _FlutterImage createState() => _FlutterImage();
}

class _FlutterImage extends State<FlutterImage> {
  static int LOADING = 0;
  static int SUCCESS = 1;
  static int FAIL = 2;

  num textureImageId;
  EventChannel eventChannel;
  int status = LOADING;
  Object error;


  GlobalKey _containerKey = GlobalKey();
  _getContainerSize() {
    final RenderBox containerRenderBox = _containerKey.currentContext.findRenderObject();
    final containerSize = containerRenderBox.size;
    print("size is "+containerSize.width.toString()+" "+containerSize.height.toString());
    init(containerSize);
  }



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onBuildCompleted);
  }
  _onBuildCompleted(Duration timestamp) {
    _getContainerSize();
  }

  @override
  void dispose() {
    if (textureImageId != null) {
      Glimage.instance.dispose(textureImageId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      width: widget.width,
      height: widget.height,
      child: _getImage(),
    );
  }

  Future<Null> init(Size size) async {
    textureImageId = await Glimage.instance.image(widget.imageUrl, size.width, size.height);
    eventChannel = EventChannel("flutter.io/image/imageEvevts" + textureImageId.toString());
    eventChannel.receiveBroadcastStream().listen((event) {
      print(event);
      status = event["event"];
      error = event["error"];
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _placeholder(BuildContext context) {
    return widget.placeholder != null
        ? widget.placeholder(context, widget.imageUrl)
        : SizedBox(
            width: widget.width,
            height: widget.height,
          );
  }

  Widget _errorWidget(BuildContext context, Object error) {
    return widget.errorWidget != null ? widget.errorWidget(context, widget.imageUrl, error) : _placeholder(context);
  }

  Widget _getImage() {
    if (status == SUCCESS) {
      print("SUCCESS  lallala");
      return Texture(textureId: textureImageId);
    } else if (status == FAIL) {
      return _errorWidget(context, error);
    } else {
      return _placeholder(context);
    }
  }
}
