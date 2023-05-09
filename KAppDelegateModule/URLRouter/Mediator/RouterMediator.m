//
//  RouterMediator.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/9.
//

#import "RouterMediator.h"
#import "MGJRouter.h"
#import "URLModuleBViewController.h"
#import "URLModuleAViewController.h"

@implementation RouterMediator

+ (void)load {

    [MGJRouter registerURLPattern:@"mgj://app/getModuleA" toObjectHandler:^id(NSDictionary *routerParameters) {
        URLModuleAViewController *vc = [[URLModuleAViewController alloc] init];
        return vc;
    }];
    
    [MGJRouter registerURLPattern:@"mgj://app/getModuleB" toObjectHandler:^id(NSDictionary *routerParameters) {
        NSLog(@"url>>>>传递的数据%@",routerParameters);
        URLModuleBViewController *vc = [[URLModuleBViewController alloc] init];
        return vc;
    }];
    
}
@end
