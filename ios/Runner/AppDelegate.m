#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Device Token = %@", [self getDeviceTokenFromData:deviceToken]);
    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (nullable NSString *)getDeviceTokenFromData:(NSData *)deviceToken {
    NSUInteger dataLength = deviceToken.length;
    if (dataLength == 0) {
        return nil;
    }
    const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

@end
