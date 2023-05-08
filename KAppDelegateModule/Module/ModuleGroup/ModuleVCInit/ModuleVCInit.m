//
//  ModuleVCInit.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ModuleVCInit.h"
#import "ViewController.h"
#import "SModuleAViewController.h"
@implementation ModuleVCInit
- (void)setupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.rootViewController = [[ViewController alloc]init];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[SModuleAViewController alloc]init]];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}
@end
