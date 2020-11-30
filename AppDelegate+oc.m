//
//  AppDelegate+oc.m
//  boxin
//
//  Created by guduzhonglao on 10/17/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "AppDelegate+oc.h"



@implementation AppDelegate (oc)

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (@available(iOS 13.0, *)) {
            dispatch_async(dispatch_queue_create("updateDeviceToken", NULL), ^{
                const unsigned *tokenBytes = [deviceToken bytes];
                NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
                NSMutableString *t = [NSMutableString string];
                for (int i=0; i<8; i++) {
                    [t appendFormat:@"%02x", tokenBytes[i]];
                }
                [[NSUserDefaults standardUserDefaults] setObject:t forKey:@"deviceToken"];
                [[EMClient sharedClient]registerForRemoteNotificationsWithDeviceToken:token completion:^(EMError *aError) {
                    
                }];
    //            [[EMClient sharedClient] bindDeviceToken:token];
                
            });
        }else{
            dispatch_async(dispatch_queue_create("updateDeviceToken", NULL), ^{
                NSMutableString *t = [NSMutableString string];
                const unsigned *tokenBytes = [deviceToken bytes];
                               for (int i=0; i<8; i++) {
                                   [t appendFormat:@"%02x", tokenBytes[i]];
                               }
                               [[NSUserDefaults standardUserDefaults] setObject:t forKey:@"deviceToken"];
                [[EMClient sharedClient]bindDeviceToken:deviceToken];
            });
        }
}

@end
