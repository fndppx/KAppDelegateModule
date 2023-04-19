//
//  KAppDelegateModuleProtocol.h
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol KAppDelegateModuleProtocol <NSObject>

@optional

/// Step 1 伴随 willFinishLaunchingWithOptions 启动的事件.
/// @note 原则上不应该有该场景，需要使用则明确说明用途
/// @param launchOptions 同application:willFinishLaunchingWithOptions: 参数
- (void)preSetupWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;

/// Step 2 伴随 didFinishLaunchingWithOptions 启动的事件.
/// @note 在用户协议同意之前，方法在主线程同步调用，仅仅初始化配置，因为合规不允许用户同意前做网络或权限的申请
/// @param launchOptions 同application:didFinishLaunchingWithOptions: 参数
- (void)setupWithOptions:(NSDictionary *)launchOptions;

/// Step 3 伴随 didFinishLaunchingWithOptions 启动的事件.
/// @note 在用户协议同意之后 主Window加载之前，方法在主线程同步调用
- (void)syncLoadBeforeUIWithOptions:(NSDictionary *)launchOptions;

/// Step 4 伴随 didFinishLaunchingWithOptions 启动的事件.
/// @note 在用户协议同意之后，方法在主线程同步调用， 子类必须实现
/// @param launchOptions 同application:didFinishLaunchingWithOptions: 参数
- (void)syncLoadAfterUIWithOptions:(NSDictionary *)launchOptions;

/// Step 5 伴随 didFinishLaunchingWithOptions 启动的事件.
/// @note 在用户协议同意之后，方法在异步线程同步调用
/// @param launchOptions 同application:didFinishLaunchingWithOptions: 参数
- (void)asyncLoadAfterUIWithOptions:(NSDictionary *)launchOptions;


@end

NS_ASSUME_NONNULL_END
