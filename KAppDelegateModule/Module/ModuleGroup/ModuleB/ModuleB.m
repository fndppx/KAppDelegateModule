//
//  ModuleB.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ModuleB.h"
#import "GuidanceManger.h"
#import "KAppDelegateModuleManager.h"
#import "ModuleVCInit.h"
@implementation ModuleB
- (void)preSetupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
}

- (void)setupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
    // 让模块分发类传递生命周期方法
    [[KAppDelegateModuleManager sharedInstance]startupEventsBeforeAgreementOnAppDidFinishLaunchingWithOptions:launchOptions];
    
    __block UIWindow *window;
    [[KAppDelegateModuleManager sharedInstance].startupModuleList enumerateObjectsUsingBlock:^(id<KAppDelegateModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ModuleVCInit class]]){
            window = [(ModuleVCInit*)obj window];
            *stop = YES;
        }
    }];
    
    [GuidanceManger showGuidanceOnSuperView:window completion:^{
        
        // 让模块分发类传递生命周期方法
        [[KAppDelegateModuleManager sharedInstance]startupEventsAfterAgreementAndBeforeUIOnAppDidFinishLaunchingWithOptions:launchOptions];
    }];
}

@end
