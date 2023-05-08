//
//  BModuleManager.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "BModuleManager.h"
#import "SModuleBViewController.h"
//@BeeHiveService(BModuleService, BModuleManager)
@implementation BModuleManager
+ (void)load {
    [[BeeHive shareInstance]registerService:@protocol(BModuleService) service:BModuleManager.class];
}

- (UIViewController*)getBModuleVC{
    SModuleBViewController *vc = [[SModuleBViewController alloc]init];
    return vc;
}
@end
