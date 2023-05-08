//
//  Target_ModuleA.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "Target_ModuleA.h"
#import "ModuleAViewController.h"
@implementation Target_ModuleA
- (UIViewController *)Action_nativeModuleAViewController:(NSDictionary *)params
{
    // 因为action是从属于ModuleA的，所以action直接可以使用ModuleA里的所有声明
    ModuleAViewController *viewController = [[ModuleAViewController alloc] init];
    viewController.data = params[@"key"];
    viewController.imageView = params[@"imageView"];
    return viewController;
}

@end
