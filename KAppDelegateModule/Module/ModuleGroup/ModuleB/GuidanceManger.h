//
//  GuidanceManger.h
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
// 模拟引导页
@interface GuidanceManger : NSObject
+ (void)showGuidanceOnSuperView:(UIView *)superView completion:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
