//
//  BModuleService.h
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import <Foundation/Foundation.h>
#import "PMediator.h"
NS_ASSUME_NONNULL_BEGIN

@protocol BModuleService <NSObject>
- (UIViewController*)getBModuleVC;
- (NSInteger)getBModuleGoodsNumber;
@end

NS_ASSUME_NONNULL_END
