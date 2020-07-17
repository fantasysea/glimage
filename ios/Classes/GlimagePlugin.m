#import "GlimagePlugin.h"
#import "FluttetrImage.h"


 NSObject<FlutterBinaryMessenger> *mybinaryMessenger;
 NSObject<FlutterTextureRegistry> *textures;
@implementation GlimagePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"glimage"
            binaryMessenger:[registrar messenger]];
  GlimagePlugin* instance = [[GlimagePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  textures = [registrar textures];
  mybinaryMessenger =[registrar messenger];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if([call.method isEqualToString:@"image"]){
    NSString *imageurl = call.arguments[@"url"];
    CGFloat width = [call.arguments[@"width"] floatValue]*[UIScreen mainScreen].scale;
    CGFloat height = [call.arguments[@"height"] floatValue]*[UIScreen mainScreen].scale;

      __block int64_t textureId = 10;
        FluttetrImage *fluttetrImage = [[FluttetrImage alloc] initWithUrl:imageurl width:width height:height binaryMessenger:mybinaryMessenger frameUpdateCallback:^{
                   [textures textureFrameAvailable:textureId];
               }];
      textureId = [textures registerTexture:fluttetrImage];
      [fluttetrImage addchannel:textureId];
       
       result(@(textureId));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
