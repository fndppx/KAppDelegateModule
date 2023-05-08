//
//  BModuleService.h
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import <Foundation/Foundation.h>
#import "BeeHive.h"
NS_ASSUME_NONNULL_BEGIN

@protocol BModuleService <NSObject>
- (UIViewController*)getBModuleVC;
@end

NS_ASSUME_NONNULL_END
