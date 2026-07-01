//
//  CallKeep.h
//  CallKeep
//
//  Copyright 2016-2019 The CallKeep Authors (see the AUTHORS file)
//  SPDX-License-Identifier: ISC, MIT
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>
#import <Intents/Intents.h>
#import <PushKit/PushKit.h>
#import "CallKeepPushDelegate.h"

static NSString *_Nonnull const CallKeepHandleStartCallNotification = @"CallKeepHandleStartCallNotification";
static NSString *_Nonnull const CallKeepDidReceiveStartCallAction = @"CallKeepDidReceiveStartCallAction";
static NSString *_Nonnull const CallKeepPerformAnswerCallAction = @"CallKeepPerformAnswerCallAction";
static NSString *_Nonnull const CallKeepPerformEndCallAction = @"CallKeepPerformEndCallAction";
static NSString *_Nonnull const CallKeepDidActivateAudioSession = @"CallKeepDidActivateAudioSession";
static NSString *_Nonnull const CallKeepDidDeactivateAudioSession = @"CallKeepDidDeactivateAudioSession";
static NSString *_Nonnull const CallKeepDidDisplayIncomingCall = @"CallKeepDidDisplayIncomingCall";
static NSString *_Nonnull const CallKeepDidFailCallAction = @"CallKeepDidFailCallAction";
static NSString *_Nonnull const CallKeepDidPerformSetMutedCallAction = @"CallKeepDidPerformSetMutedCallAction";
static NSString *_Nonnull const CallKeepPerformPlayDTMFCallAction = @"CallKeepDidPerformDTMFAction";
static NSString *_Nonnull const CallKeepDidToggleHoldAction = @"CallKeepDidToggleHoldAction";
static NSString *_Nonnull const CallKeepProviderReset = @"CallKeepProviderReset";
static NSString *_Nonnull const CallKeepCheckReachability = @"CallKeepCheckReachability";
static NSString *_Nonnull const CallKeepDidLoadWithEvents = @"CallKeepDidLoadWithEvents";
static NSString *_Nonnull const CallKeepPushKitToken = @"CallKeepPushKitToken";
static NSString *_Nonnull const CallKeepActionAnswer = @"CallKeepActionAnswer";
static NSString *_Nonnull const CallKeepActionEnd = @"CallKeepActionEnd";

@interface CallKeep: NSObject<CXProviderDelegate, PKPushRegistryDelegate>
@property (nonatomic, strong, nullable) CXCallController *callKeepCallController;
@property (nonatomic, strong, nullable) CXProvider *callKeepProvider;
@property (nonatomic, strong, nullable) FlutterMethodChannel* eventChannel;

- (BOOL)handleMethodCall:(FlutterMethodCall* _Nonnull)call result:(FlutterResult _Nonnull )result;

+ (BOOL)application:(UIApplication * _Nonnull)application
            openURL:(NSURL * _Nonnull)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nonnull)options NS_AVAILABLE_IOS(9_0);

+ (BOOL)application:(UIApplication * _Nonnull)application
continueUserActivity:(NSUserActivity * _Nonnull)userActivity
  restorationHandler:(void(^ _Nonnull)(NSArray<id<UIUserActivityRestoring>> * _Nonnull restorableObjects))restorationHandler;

+ (void)setDelegate:(NSObject<CallKeepPushDelegate>* _Nullable)delegate;
+ (void)ensureVoipRegistration;

+ (void)reportNewIncomingCall:(NSString * _Nonnull)uuidString
                       handle:(NSString * _Nonnull)handle
                   handleType:(NSString * _Nonnull)handleType
                     hasVideo:(BOOL)hasVideo
                   callerName:(NSString * _Nullable)callerName
                  fromPushKit:(BOOL)fromPushKit
                      payload:(NSDictionary * _Nullable)payload;

+ (void)reportNewIncomingCall:(NSString * _Nonnull)uuidString
                       handle:(NSString * _Nonnull)handle
                   handleType:(NSString * _Nonnull)handleType
                     hasVideo:(BOOL)hasVideo
                   callerName:(NSString * _Nullable)callerName
                  fromPushKit:(BOOL)fromPushKit
                      payload:(NSDictionary * _Nullable)payload
        withCompletionHandler:(void (^_Nullable)(void))completion;

+ (void)endCallWithUUID:(NSString * _Nonnull)uuidString
                 reason:(int)reason;

+ (BOOL)isCallActive:(NSString * _Nonnull)uuidString;

@end
