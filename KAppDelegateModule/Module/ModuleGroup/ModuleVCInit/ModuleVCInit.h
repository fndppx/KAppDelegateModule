//
//  ModuleVCInit.h
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KAppDelegateModuleProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface ModuleVCInit : NSObject<KAppDelegateModuleProtocol>
@property (nonatomic, strong) UIWindow *window;
@end

NS_ASSUME_NONNULL_END
