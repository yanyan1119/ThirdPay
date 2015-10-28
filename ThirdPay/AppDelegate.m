//
//  AppDelegate.m
//  ThirdPay
//
//  Created by hky on 15/10/28.
//  Copyright © 2015年 hky. All rights reserved.
//

#import "WeChatSDK_1.5/WXApi.h"
#import "AppDelegate.h"
#import "AlixPayResult.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.host isEqualToString:@"pay"]) {
        //微信支付支付成功
        [[NSNotificationCenter defaultCenter] postNotificationName:WechatpaySuccessNotifycation object:url];
    }
    else
    {
        //支付宝支付成功
        AlixPayResult *result = [[AlixPayResult alloc] initWithResultString:[[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[NSNotificationCenter defaultCenter] postNotificationName:AlixpaySuccessNotifycation object:result];
    }
    return YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WXApi registerApp:@"wxc4e9f91ab32ad957"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
