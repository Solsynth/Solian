#import "FlutterCallkeepPlugin.h"
#include "CallKeep.h"

@implementation FlutterCallkeepPlugin
{
    CallKeep *_callKeep;
}

static id _instance;

+ (FlutterCallkeepPlugin *)sharedInstance {
    return _instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (_instance == nil) {
        FlutterMethodChannel* channel = [FlutterMethodChannel
                                         methodChannelWithName:@"FlutterCallKeep.Method"
                                         binaryMessenger:[registrar messenger]];
        UIViewController *viewController = (UIViewController *)registrar.messenger;
        _instance = [[FlutterCallkeepPlugin alloc] initWithChannel:channel
                                                         registrar:registrar
                                                         messenger:[registrar messenger]
                                                    viewController:viewController
                                                      withTextures:[registrar textures]];
        [registrar addMethodCallDelegate:_instance channel:channel];
    }
}


- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger
                 viewController:(UIViewController *)viewController
                   withTextures:(NSObject<FlutterTextureRegistry> *)textures {
    
#ifdef DEBUG
    NSLog(@"[FlutterCallkeepPlugin][init]");
#endif
    if (self = [super init]) {
        _callKeep = [CallKeep allocWithZone: nil];
        _callKeep.eventChannel = [FlutterMethodChannel
                                  methodChannelWithName:@"FlutterCallKeep.Event"
                                  binaryMessenger:[registrar messenger]];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"[FlutterCallkeepPlugin][dealloc]");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _callKeep = nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (![_callKeep handleMethodCall:call result:result]) {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
    return [CallKeep application:application
                        continueUserActivity:userActivity
                        restorationHandler:restorationHandler];
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return NO;
}

@end
