//
//  ZYBMediatorProtocol.h
//  Pods-ZYBMediator_Example
//
//  Created by binaryc on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZYBMediatorProtocol <NSObject>

@optional

// 是否为单实例
+ (BOOL)singleton;

// 单实例实现接口
+ (id)sharedInstance;

- (void)setup;
/**
 The priority of the module to be setup. 0 is the lowest priority;
 If not provided, the default priority is BifrostModuleDefaultPriority;

 @return the priority
 */
+ (NSUInteger)priority;


/**
 Whether to setup the module synchronously in main thread.
 If it's not implemeted, default value is NO, module will be sutup asyhchronously in backgorud thread.

 @return whether synchronously
 */
+ (BOOL)setupModuleSynchronously;


@end


NS_ASSUME_NONNULL_END
