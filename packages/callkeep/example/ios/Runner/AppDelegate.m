#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <CallKeep.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    [CallKeep setDelegate:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (nullable NSDictionary *)mapPushPayload:(NSDictionary * _Nonnull)payload {
    NSLog(@"Mapper called with %@", [payload description]);
    return payload;
}

- (void)onCallEvent:(NSString *)event withCallData:(NSDictionary *)callData {
    NSLog(@"Delegate called on %@ with %@", event, [callData description]);
}

@end
