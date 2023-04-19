//
//  KAppDelegateModuleManager.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "KAppDelegateModuleManager.h"
#import <UIKit/UIKit.h>

#import "ModuleVCInit.h"
#import "ModuleA.h"
#import "ModuleB.h"
typedef NS_ENUM(int, ModuleStartupStepType) {
    ModuleStartupStepTypeInit,
    ModuleStartupStepTypeAppWillFinish,
    ModuleStartupStepTypeAppDidFinishBeforeAgreement,
    ModuleStartupStepTypeAppDidFinishAfterAgreementBeforeUI,
    ModuleStartupStepTypeAppDidFinishAfterAgreementAndUI,
};

@interface KAppDelegateModuleManager ()

@property (nonatomic, assign) ModuleStartupStepType stepType;

@property (nonatomic, copy) NSArray <id<KAppDelegateModuleProtocol>> *startupModuleList;

@property (nonatomic, strong) dispatch_queue_t startupQueue;

@end

@implementation KAppDelegateModuleManager

+ (instancetype)sharedInstance {
    static KAppDelegateModuleManager *_startupInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _startupInstance = [[KAppDelegateModuleManager alloc] init];
    });
    return _startupInstance;
}


- (instancetype)init {
    self= [super init];
    if (self) {
        self.stepType = ModuleStartupStepTypeInit;
        self.startupQueue = dispatch_queue_create("com.module.startup.queue", DISPATCH_QUEUE_CONCURRENT);
        [self p_registerStartupModule];
    }
    return self;
}

#pragma mark -- Public Methods

- (void)startupEventsOnAppWillFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    ModuleStartupStepType stepType = ModuleStartupStepTypeAppWillFinish;
    if (![self p_checkValidStep:stepType]) {
        return;
    }
    self.stepType = stepType;
    
    if ([self.startupModuleList count] == 0) {
        return;
    }
    for (id<KAppDelegateModuleProtocol> module in self.startupModuleList) {
        if ([self p_checkModule:module respondsSelector:@selector(preSetupWithOptions:)]) {
            [module preSetupWithOptions:launchOptions];
            NSLog(@"[StartUp] [%@] will launch **preSetup**",NSStringFromClass([module class]));
        }
    }
}

- (void)startupEventsBeforeAgreementOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ModuleStartupStepType stepType = ModuleStartupStepTypeAppDidFinishBeforeAgreement;
    if (![self p_checkValidStep:stepType]) {
        return;
    }
    self.stepType = stepType;

    if ([self.startupModuleList count] == 0) {
        return;
    }
    for (id<KAppDelegateModuleProtocol> module in self.startupModuleList) {
        if ([self p_checkModule:module respondsSelector:@selector(setupWithOptions:)]) {
            [module setupWithOptions:launchOptions];
            NSLog(@"[StartUp] [%@] did launch **setup**",NSStringFromClass([module class]));
        }
    }
}

- (void)startupEventsAfterAgreementAndBeforeUIOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ModuleStartupStepType stepType = ModuleStartupStepTypeAppDidFinishAfterAgreementBeforeUI;
    if (![self p_checkValidStep:stepType]) {
        return;
    }
    self.stepType = stepType;

    if ([self.startupModuleList count] == 0) {
        return;
    }
    for (id<KAppDelegateModuleProtocol> module in self.startupModuleList) {
        if ([self p_checkModule:module respondsSelector:@selector(syncLoadBeforeUIWithOptions:)]) {
            [module syncLoadBeforeUIWithOptions:launchOptions];
            NSLog(@"[StartUp] [%@] did launch sync load before UI",NSStringFromClass([module class]));
        }
    }
}

- (void)startupEventsAfterAgreementAndUIOnAppDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ModuleStartupStepType stepType = ModuleStartupStepTypeAppDidFinishAfterAgreementAndUI;
    if (![  self p_checkValidStep:stepType]) {
        return;
    }
    self.stepType = stepType;

    if ([self.startupModuleList count] == 0) {
        return;
    }
    for (id<KAppDelegateModuleProtocol> module in self.startupModuleList) {
        if ([self p_checkModule:module respondsSelector:@selector(syncLoadAfterUIWithOptions:)]) {
            [module syncLoadAfterUIWithOptions:launchOptions];
            NSLog(@"[StartUp] [%@] did launch sync load after UI",NSStringFromClass([module class]));
        }
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.startupQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (id<KAppDelegateModuleProtocol> module in strongSelf.startupModuleList) {
            if ([strongSelf p_checkModule:module respondsSelector:@selector(asyncLoadAfterUIWithOptions:)]) {
                [module asyncLoadAfterUIWithOptions:launchOptions];
                NSLog(@"[StartUp] [%@] did launch async load after UI",NSStringFromClass([module class]));
            }
        }
    });
}


#pragma mark -- Private Methods

- (BOOL)p_checkValidStep:(ModuleStartupStepType)stepType {
    if (self.stepType == stepType) {
        NSLog(@"startup repeat call step type:%d last:%d ",stepType,self.stepType);
        return NO;
    }
    if (self.stepType > stepType) {
        NSString *formatStr = [NSString stringWithFormat:@"startup step invalid type:%d last:%d ",stepType,self.stepType];
        NSAssert(NO, formatStr);
        return NO;
    }
    return YES;
}

- (void)p_registerStartupModule {
    NSMutableArray <id<KAppDelegateModuleProtocol>> *moduleList = [[NSMutableArray alloc] init];
    [moduleList addObject:[ModuleA new]];
    [moduleList addObject:[ModuleVCInit new]];
    [moduleList addObject:[ModuleB new]];
    
    // 有新的需求模块后续追加
    self.startupModuleList = [moduleList copy];
}

- (BOOL)p_checkModule:(id<KAppDelegateModuleProtocol>)module respondsSelector:(SEL)selector {
    if (!module || ![module conformsToProtocol:@protocol(KAppDelegateModuleProtocol)]) {
        return NO;
    }
    return [module respondsToSelector:selector];
}

@end
