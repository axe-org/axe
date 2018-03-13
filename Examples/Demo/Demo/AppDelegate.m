//
//  AppDelegate.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AppDelegate.h"
#import "AXETabBarController.h"

#import "ViewController.h"

#import "Axe.h"

#import "AXEWebViewController.h"
#import "AXEWKWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AXERouter sharedRouter] registerPagePath:@"a" withRouterForVCBlock:^UIViewController *(AXEData *params,AXERouterCallbackBlock callback) {
        ViewController *vc = [[ViewController alloc] init];
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
        return nv;
    }];
    
    [[AXERouter sharedRouter] registerPagePath:@"b" withRouterForVCBlock:^UIViewController *(AXEData *params,AXERouterCallbackBlock callback) {
        ViewController *vc = [[ViewController alloc] init];
        return vc;
    }];
//    [AXEWebViewController registerUIWebViewForHTTP];
    [AXEWKWebViewController registerWKWebViewForHTTP];
    [AXEWKWebViewController registerWKWebViewForHTTPS];
    
    AXETabBarItem *itema = [AXETabBarItem itemWithPagePath:@"A" routURL:@"axe://a"];
    itema.title = @"A";
    [AXETabBarController registerTabBarItem:itema];
    
    AXETabBarItem *itemb = [AXETabBarItem itemWithPagePath:@"B" routURL:@"https://www.baidu.com"];
    itemb.title = @"B";
    [AXETabBarController registerTabBarItem:itemb];
    
    AXETabBarItem *itemc = [AXETabBarItem itemWithPagePath:@"C" routURL:@"http://localhost/echo.html"];
    itemc.title = @"echo";
    [AXETabBarController registerTabBarItem:itemc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    AXETabBarController *rootViewController = [AXETabBarController TabBarController];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    
    [AXEEvent registerListenerForEventName:@"event_test" handler:^(AXEData *payload) {
        NSLog(@"payload 里面带有时间 为 %@",[payload dateForKey:@"now_date"]);
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
