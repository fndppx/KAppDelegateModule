//
//  CTMediator+ModuleAActions.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "CTMediator+ModuleAActions.h"
NSString * const kCTMediatorTargetModuleA = @"ModuleA";

NSString * const kCTMediatorActionNativeModuleAViewController = @"nativeModuleAViewController";
@implementation CTMediator (ModuleAActions)
- (UIViewController *)CTMediator_viewControllerForModuleA
{
    UIViewController *viewController = [self performTarget:kCTMediatorTargetModuleA
                                                    action:kCTMediatorActionNativeModuleAViewController
                                                    params:@{@"key":@"value",
                                                             @"imageView":[UIImageView new],
                                                           }
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
