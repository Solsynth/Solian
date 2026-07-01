#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CallKeepPushDelegate <NSObject>

- (nullable NSDictionary*)mapPushPayload:(NSDictionary* _Nonnull)payload;

@optional
- (void)onCallEvent:(NSString* _Nonnull)event withCallData:(NSDictionary* _Nonnull)callData;

@end

NS_ASSUME_NONNULL_END
