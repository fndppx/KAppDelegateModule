//
//  AppDelegate.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "AppDelegate.h"
#import "KAppDelegateModuleManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[KAppDelegateModuleManager sharedInstance] startupEventsBeforeAgreementOnAppDidFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    [[KAppDelegateModuleManager sharedInstance] startupEventsOnAppWillFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}


@end
