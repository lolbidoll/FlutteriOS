#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Smartech/Smartech.h>
#import <SmartPush/SmartPush.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import "SmartechBasePlugin.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate, SmartechDelegate> {
    
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
    [[Smartech sharedInstance] setDebugLevel:SMTLogLevelVerbose];
    [[Smartech sharedInstance] initSDKWithDelegate:self withLaunchOptions:launchOptions];
    [[Smartech sharedInstance] trackAppInstallUpdateBySmartech];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"[SMT-APP] Device Token = %@", [self getDeviceTokenFromData:deviceToken]);
    
    [[SmartPush sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
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

#pragma mark - UNUserNotificationCenter Delegate Methods

/* The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    NSLog(@"[SMT-APP] willPresentNotification");
    if ([[SmartPush sharedInstance] isNotificationFromSmartech:notification.request.content.userInfo]) {
        NSLog(@"[SMT-APP] willPresentNotification Smartech Push Notification");
        [[SmartPush sharedInstance] willPresentForegroundNotification:notification];
        completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
    }
    NSLog(@"[SMT-APP] willPresentNotification Before calling Super");
    [super userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

/* The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"[SMT-APP] didReceiveNotificationResponse");
    if ([[SmartPush sharedInstance] isNotificationFromSmartech:response.notification.request.content.userInfo]) {
        NSLog(@"[SMT-APP] didReceiveNotificationResponse Smartech Push Notification");
        [[SmartPush sharedInstance] didReceiveNotificationResponse:response];
        completionHandler();
    }
    NSLog(@"[SMT-APP] didReceiveNotificationResponse Before calling Super");
    [super userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    
}

- (void)handleDeeplinkActionWithURLString:(NSString *)deeplinkURLString andNotificationPayload:(NSDictionary *)notificationPayload {
    NSLog(@"[SMT-APP] handleDeeplinkActionWithURLString Passing notification data to base flutter plugin");
    [SmartechBasePlugin handleDeeplinkAction:deeplinkURLString andCustomPayload:notificationPayload];
}

@end
