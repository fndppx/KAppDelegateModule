//
//  ModuleVCInit.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ModuleVCInit.h"
#import "ViewController.h"
//测试
#import "SModuleAViewController.h"
#import "URLModuleAViewController.h"
@implementation ModuleVCInit
- (void)setupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    // target-action
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    
    // 服务注册
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[SModuleAViewController alloc]init]];

    // url
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[URLModuleAViewController alloc]init]];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}
@end
