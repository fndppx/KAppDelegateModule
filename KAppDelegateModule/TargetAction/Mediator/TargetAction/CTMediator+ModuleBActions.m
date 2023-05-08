//
//  CTMediator+ModuleBActions.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "CTMediator+ModuleBActions.h"
NSString * const kCTMediatorTargetModuleB = @"ModuleB";
NSString * const kCTMediatorActionNativeModuleBViewController = @"nativeModuleBViewController";

@implementation CTMediator (ModuleBActions)
- (UIViewController *)CTMediator_viewControllerForModuleB
{
    UIViewController *viewController = [self performTarget:kCTMediatorTargetModuleB
                                                    action:kCTMediatorActionNativeModuleBViewController
                                                    params:@{@"key":@"value"}
                                         shouldCacheTarget:NO
                                        ];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[UIViewController alloc] init];
    }
}
@end
