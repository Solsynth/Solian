#import <Flutter/Flutter.h>

@interface FlutterCallkeepPlugin : NSObject<FlutterPlugin>
+ (instancetype _Nullable)sharedInstance;
+ (BOOL)application:(UIApplication * _Nullable)application
            openURL:(NSURL * _Nullable)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nullable)options NS_AVAILABLE_IOS(9_0);
- (BOOL)application:(UIApplication * _Nullable)application
    continueUserActivity:(NSUserActivity * _Nullable)userActivity
      restorationHandler:(void (^  __nullable)(NSArray *_Nullable))restorationHandler;
@end
