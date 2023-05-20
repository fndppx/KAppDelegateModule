//
//  PMediator.m
//  Pods-PMediator_Example
//
//  Created by kyan on 2023/05/18.
//

#import "PMediator.h"
#import "ZYBMediatorProtocol.h"
#import "ZYBMediatorUtils.h"

#import "ConcurrentMutableDictionary.h"
#define BFLog(msg) NSLog(@"[Bifrost] %@", (msg))
#define BFInstance [PMediator sharedInstance]
NSExceptionName BifrostExceptionName = @"BifrostExceptionName";
NSString * const kBifrostExceptionCode = @"BifrostExceptionCode";
NSString * const kBifrostExceptionURLStr = @"kBifrostExceptionURLStr";
NSString * const kBifrostExceptionURLParams = @"kBifrostExceptionURLParams";
NSString * const kBifrostExceptionServiceProtocolStr = @"kBifrostExceptionServiceProtocolStr";
NSString * const kBifrostExceptionModuleClassStr = @"kBifrostExceptionModuleClassStr";
NSString * const kBifrostExceptionAPIStr = @"kBifrostExceptionAPIStr";
NSString * const kBifrostExceptionAPIArguments = @"kBifrostExceptionAPIArguments";
@interface PMediator ()<ZYBMediatorProtocol>

@property (nonatomic, strong) ConcurrentMutexDictionary *serviceClasses;
@property (nonatomic, strong) NSMutableDictionary *moduleInvokeDict;

@property (nonatomic, strong) NSMutableDictionary *serviceSingleInstances;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation PMediator

+ (instancetype)sharedInstance {
    static PMediator *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PMediator alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _serviceClasses = [ConcurrentMutexDictionary dictionaryWithCapacity:8];
        _serviceSingleInstances = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    return self;
}

- (void)registerService:(Protocol *)service implementClass:(Class)serviceClass {
    NSAssert(service!=nil, @"registerService:implementClass:参数service不能为空");
    NSAssert(serviceClass!=nil, @"registerService:implementClass:参数serviceClass不能为空");
    NSAssert([serviceClass conformsToProtocol:service], @"registerService:implementClass:参数serviceClass没有遵循协议service");
    NSAssert([ZYBMediatorUtils checkObject:serviceClass implementProtocol:service], @"registerService:implementClass:参数serviceClass未实现协议service方法");
    NSString *key = NSStringFromProtocol(service);
    NSAssert((![_serviceClasses objectForKey:key]) || ([_serviceClasses objectForKey:key] == serviceClass), @"协议service不能重复注册");
    [_serviceClasses setObject:serviceClass forKey:key];
}

- (void)unregisterService:(Protocol *)service {
    NSAssert(service!=nil, @"registerService:implementClass:参数service不能为空");
    NSString *key = NSStringFromProtocol(service);
    [_serviceClasses removeObjectForKey:key];
    
    [_lock lock];
    @try {
        [_serviceSingleInstances removeObjectForKey:key];
    } @finally {
        [_lock unlock];
    }
}

- (id)getServiceInstance:(Protocol *)service {
    NSAssert(service!=nil, @"getServiceInstance:参数service不能为空");
    NSString *protName = NSStringFromProtocol(service);
    Class cls = [_serviceClasses objectForKey:protName];
    
    if (!cls) {
        return nil;
    }
    
    if (![cls respondsToSelector:@selector(singleton)]) {
        return [[cls alloc] init];
    }
    
    if (![cls singleton]) {
        return [[cls alloc] init];
    }
    
    if ([cls respondsToSelector:@selector(sharedInstance)]) {
        return [cls sharedInstance];
    }
    
    id instance;
    [_lock lock];
    @try {
        instance = [_serviceSingleInstances objectForKey:protName];
        if (!instance) {
            instance = [[cls alloc] init];
            [_serviceSingleInstances setObject:instance forKey:protName];
        }
    } @finally {
        [_lock unlock];
    }
    return instance;
}


- (id)createService:(Protocol *)proto {
    return [self createService:proto withServiceName:nil];
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName {
    return [self createService:service withServiceName:serviceName shouldCache:YES];
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache {
    if (!serviceName.length) {
        serviceName = NSStringFromProtocol(service);
    }
    id implInstance = nil;
    
    if (![self checkValidService:service]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
        
    }
    
    NSString *serviceStr = serviceName;
    if (shouldCache) {
        id protocolImpl = [_serviceSingleInstances objectForKey:serviceStr];
        if (protocolImpl) {
            return protocolImpl;
        }
    }
    
    Class implClass = [self serviceImplClass:service];
    if ([[implClass class] respondsToSelector:@selector(singleton)]) {
        if ([[implClass class] singleton]) {
            if ([[implClass class] respondsToSelector:@selector(sharedInstance)])
                implInstance = [[implClass class] sharedInstance];
            else
                implInstance = [[implClass alloc] init];
            if (shouldCache) {
                Protocol *key = NSProtocolFromString(serviceStr);
                [self registerService:key implementClass:implInstance];
                return implInstance;
            } else {
                return implInstance;
            }
        }
    }
    return [[implClass alloc] init];
}

- (Class)serviceImplClass:(Protocol *)service
{
    NSString *serviceImpl = [_serviceClasses objectForKey:NSStringFromProtocol(service)];
    if (serviceImpl.length > 0) {
        return NSClassFromString(serviceImpl);
    }
    return nil;
}


- (BOOL)checkValidService:(Protocol *)service
{
    NSString *serviceImpl = [_serviceClasses objectForKey:NSStringFromProtocol(service)];
    if (serviceImpl.length > 0) {
        return YES;
    }
    return NO;
}

+ (void)setupAllModules {
    NSArray *modules = [self allRegisteredModules];
    for (Class<ZYBMediatorProtocol> moduleClass in modules) {
        @try {
            BOOL setupSync = NO;
            if ([moduleClass respondsToSelector:@selector(setupModuleSynchronously)]) {
                setupSync = [moduleClass setupModuleSynchronously];
            }
            if (setupSync) {
                [[moduleClass sharedInstance] setup];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[moduleClass sharedInstance] setup];
                });
            }
        } @catch (NSException *exception) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
//            [userInfo setValue:@(BFExceptionFailedToSetupModule) forKey:kBifrostExceptionCode];
            [userInfo setValue:NSStringFromClass(moduleClass) forKey:kBifrostExceptionModuleClassStr];
//            NSException *ex = [[NSException alloc] initWithName:exception.name
//                                                         reason:exception.reason
//                                                       userInfo:userInfo];
//            BifrostExceptionHandler handler = [self getExceptionHandler];
//            if (handler) {
//                 handler(ex);
//            }
//            BFLog(exception.reason);
        }
    }
}

+ (NSArray<Class<ZYBMediatorProtocol>>*_Nonnull)allRegisteredModules {
    NSArray *modules = BFInstance.serviceClasses.allValues;
    NSArray *sortedModules = [modules sortedArrayUsingComparator:^NSComparisonResult(Class class1, Class class2) {
        NSUInteger priority1 = ModuleDefaultPriority;
        NSUInteger priority2 = ModuleDefaultPriority;
        if ([class1 respondsToSelector:@selector(priority)]) {
            priority1 = [class1 priority];
        }
        if ([class2 respondsToSelector:@selector(priority)]) {
            priority2 = [class2 priority];
        }
        if(priority1 == priority2) {
            return NSOrderedSame;
        } else if(priority1 < priority2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    return sortedModules;
}


+ (BOOL)checkAllModulesWithSelector:(SEL)selector arguments:(NSArray*)arguments {
    BOOL result = NO;
    NSArray *modules = [self allRegisteredModules];
    for (Class<ZYBMediatorProtocol> class in modules) {
        id<ZYBMediatorProtocol> moduleItem = [class sharedInstance];
        if ([moduleItem respondsToSelector:selector]) {
            
            __block BOOL shouldInvoke = YES;
            if (![BFInstance.moduleInvokeDict objectForKey:NSStringFromClass([moduleItem class])]) {
                // 如果 modules 里面有 moduleItem 的子类，不 invoke target
                [modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([NSStringFromClass([obj superclass]) isEqualToString:NSStringFromClass([moduleItem class])]) {
                        shouldInvoke = NO;
                        *stop = YES;
                    }
                }];
            }
            
            if (shouldInvoke) {
                if (![BFInstance.moduleInvokeDict objectForKey:NSStringFromClass([moduleItem class])]) { //cache it
                    [BFInstance.moduleInvokeDict setObject:moduleItem forKey:NSStringFromClass([moduleItem class])];
                }
                
                BOOL ret = NO;
                [self invokeTarget:moduleItem action:selector arguments:arguments returnValue:&ret];
                if (!result) {
                    result = ret;
                }
            }
        }
    }
    return result;
}

+ (BOOL)invokeTarget:(id)target
              action:(_Nonnull SEL)selector
           arguments:(NSArray* _Nullable )arguments
         returnValue:(void* _Nullable)result; {
    if (target && [target respondsToSelector:selector]) {
        NSMethodSignature *sig = [target methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:target];
        [invocation setSelector:selector];
        for (NSUInteger i = 0; i<[arguments count]; i++) {
            NSUInteger argIndex = i+2;
            id argument = arguments[i];
            if ([argument isKindOfClass:NSNumber.class]) {
                //convert number object to basic num type if needs
                BOOL shouldContinue = NO;
                NSNumber *num = (NSNumber*)argument;
                const char *type = [sig getArgumentTypeAtIndex:argIndex];
                if (strcmp(type, @encode(BOOL)) == 0) {
                    BOOL rawNum = [num boolValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(int)) == 0
                           || strcmp(type, @encode(short)) == 0
                           || strcmp(type, @encode(long)) == 0) {
                    NSInteger rawNum = [num integerValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if(strcmp(type, @encode(long long)) == 0) {
                    long long rawNum = [num longLongValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(unsigned int)) == 0
                           || strcmp(type, @encode(unsigned short)) == 0
                           || strcmp(type, @encode(unsigned long)) == 0) {
                    NSUInteger rawNum = [num unsignedIntegerValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if(strcmp(type, @encode(unsigned long long)) == 0) {
                    unsigned long long rawNum = [num unsignedLongLongValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(float)) == 0) {
                    float rawNum = [num floatValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(double)) == 0) { // double
                    double rawNum = [num doubleValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                }
                if (shouldContinue) {
                    continue;
                }
            }
            if ([argument isKindOfClass:[NSNull class]]) {
                argument = nil;
            }
            [invocation setArgument:&argument atIndex:argIndex];
        }
        [invocation invoke];
        NSString *methodReturnType = [NSString stringWithUTF8String:sig.methodReturnType];
        if (result && ![methodReturnType isEqualToString:@"v"]) { //if return type is not void
            if([methodReturnType isEqualToString:@"@"]) { //if it's kind of NSObject
                CFTypeRef cfResult = nil;
                [invocation getReturnValue:&cfResult]; //this operation won't retain the result
                if (cfResult) {
                    CFRetain(cfResult); //we need to retain it manually
                    *(void**)result = (__bridge_retained void *)((__bridge_transfer id)cfResult);
                }
            } else {
                [invocation getReturnValue:result];
            }
        }
        return YES;
    }
    return NO;
}

@end
