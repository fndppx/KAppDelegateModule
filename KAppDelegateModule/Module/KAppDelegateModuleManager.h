//
//  KAppDelegateModuleManager.h
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import "KAppDelegateModuleProtocol.h"

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface KAppDelegateModuleManager : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, copy, readonly) NSArray <id<KAppDelegateModuleProtocol>> *startupModuleList;

/// Step 1 伴随 willFinishLaunchingWithOptions 启动的事件.
- (void)startupEventsOnAppWillFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;

/// Step 2 伴随 didFinishLaunchingWithOptions 启动的事件. 在用户同意隐私协议之前执行的操作
- (void)startupEventsBeforeAgreementOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/// Step 3 伴随 didFinishLaunchingWithOptions 启动的事件. 在用户同意隐私协议后主Window初始化之前执行的操作
- (void)startupEventsAfterAgreementAndBeforeUIOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/// Step 4 伴随 didFinishLaunchingWithOptions 启动的事件. 在用户同意隐私协议和主Window初始化之后执行的操作
- (void)startupEventsAfterAgreementAndUIOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/// 如果不满足需求可以自定义追加
@end

NS_ASSUME_NONNULL_END
