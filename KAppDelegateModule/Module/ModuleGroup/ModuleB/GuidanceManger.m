//
//  GuidanceManger.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "GuidanceManger.h"
@implementation GuidanceManger
+ (void)showGuidanceOnSuperView:(UIView *)superView completion:(void(^)(void))completion {
    
    UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [superView addSubview:v];
    v.backgroundColor = [UIColor clearColor];
    !completion?:completion();
}
@end
