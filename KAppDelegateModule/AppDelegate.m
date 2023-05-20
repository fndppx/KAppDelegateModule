//
//  AppDelegate.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "AppDelegate.h"
#import "KAppDelegateModuleManager.h"
#import "PMediator.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   [PMediator setupAllModules];
    [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application), (launchOptions)]];
    return YES;
}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application), (launchOptions)]];
    return YES;
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application)]];
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application{
    [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application)]];
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application)]];
}
    
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [PMediator checkAllModulesWithSelector:_cmd arguments:@[(application),(url),(options)]];
}
    

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
//
//    [PMediator setupAllModules];
////    [[KAppDelegateModuleManager sharedInstance] startupEventsBeforeAgreementOnAppDidFinishLaunchingWithOptions:launchOptions];
//
//    return YES;
//}
//
//- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
////    [[KAppDelegateModuleManager sharedInstance] startupEventsOnAppWillFinishLaunchingWithOptions:launchOptions];
//
//    return YES;
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//
//}
//
//- (void)applicationWillResignActive:(UIApplication *)application {
//
//}


@end
