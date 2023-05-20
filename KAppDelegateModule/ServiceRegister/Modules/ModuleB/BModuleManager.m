//
//  BModuleManager.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "BModuleManager.h"
#import "SModuleBViewController.h"
@implementation BModuleManager
+ (void)load {
    [[PMediator sharedInstance]registerService:@protocol(BModuleService) implementClass:BModuleManager.class];
}

- (UIViewController*)getBModuleVC{
    SModuleBViewController *vc = [[SModuleBViewController alloc]init];
    return vc;
}

- (NSInteger)getBModuleGoodsNumber {
    return 10;
}

- (void)setup {
    
}

+ (NSUInteger)priority {
    return ModuleDefaultPriority+100; //higher priority than other modules
}

+ (BOOL)setupModuleSynchronously {
    return YES;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = application.delegate.window;
    UIViewController *homeVC = [self getBModuleVC];
    UINavigationController *rootNavContoller = [[UINavigationController alloc] initWithRootViewController:homeVC];
    rootNavContoller.navigationItem.backBarButtonItem.title = @"";
    window.rootViewController = rootNavContoller;
    [window makeKeyAndVisible];
    return YES;
}


@end
