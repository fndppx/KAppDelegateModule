//
//  ModuleVCInit.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ModuleVCInit.h"

@implementation ModuleVCInit
- (void)setupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
}
@end
