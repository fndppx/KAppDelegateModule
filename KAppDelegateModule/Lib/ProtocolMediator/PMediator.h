//
//  PMediator.h
//  Pods-PMediator_Example
//
//  Created by kyan on 2023/05/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define ModuleDefaultPriority 100

@interface PMediator : NSObject

+ (instancetype)sharedInstance;

- (void)registerService:(Protocol *)service implementClass:(Class)serviceClass;
- (void)unregisterService:(Protocol *)service;

- (id)createService:(Protocol *)proto;

- (id)getServiceInstance:(Protocol *)service;

+ (void)setupAllModules;
+ (BOOL)checkAllModulesWithSelector:(nonnull SEL)selector
                          arguments:(nullable NSArray*)arguments;

@end

NS_ASSUME_NONNULL_END
