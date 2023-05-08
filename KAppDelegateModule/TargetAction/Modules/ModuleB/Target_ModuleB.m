//
//  Target_ModuleB.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "Target_ModuleB.h"
#import "ModuleBViewController.h"
@implementation Target_ModuleB
- (UIViewController *)Action_nativeModuleBViewController:(NSDictionary *)params
{
    // 因为action是从属于ModuleA的，所以action直接可以使用ModuleA里的所有声明
    ModuleBViewController *viewController = [[ModuleBViewController alloc] init];
    return viewController;
}

@end
