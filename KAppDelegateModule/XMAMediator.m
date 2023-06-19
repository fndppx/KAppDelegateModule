//
//  XMAMediator.m
//  XMAGroup
//
//  Created by kyan on 2023/6/15.
//

#import "XMAMediator.h"
#import <objc/runtime.h>


@interface XMAMediator ()

@property (nonatomic,strong)NSMutableDictionary *cacheTarget;

@end

@implementation XMAMediator

static XMAMediator *router;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[XMAMediator alloc]init];
    });
    return router;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [super allocWithZone:zone];
    });
    return router;
}

- (id)copyWithZone:(NSZone *)zone
{
    return router;
}

+ (id)openComponentClassMethod:(NSString *)module arguments:(id)arg completion:(void (^)(NSDictionary *callback))complete {
    return [self performComponentClassMethod:module arguments:arg action:XMAMediator_Class_SEL(module, action) completion:complete];
}

- (id)openComponentInstanceMethod:(NSString *)module arguments:(id)arg completion:(void (^)(NSDictionary *))complete {
    return [self performComponentInstanceMethod:module arguments:arg action:XMAMediator_Instance_SEL(module, arg) completion:complete cacheInstanceTarget:YES];
}

+ (id)performComponentClassMethod:(NSString *)name arguments:(id)arg action:(NSString *)classAction completion:(void (^)(NSDictionary *))complete {
    Class targetClass = NSClassFromString(name);
    SEL action = NSSelectorFromString(classAction);
    //check class method
    __autoreleasing id object= nil;
    BOOL respondsToAlias = YES;
    if([targetClass respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        do {
            if ((respondsToAlias = [targetClass respondsToSelector:action])) {
                NSMethodSignature *methodSig = [targetClass methodSignatureForSelector:action];
                if(methodSig == nil) {
                    return nil;
                }
                const char* retType = [methodSig methodReturnType];
                NSAssert((strcmp(retType, @encode(BOOL)) != 0) || (strcmp(retType, @encode(int)) != 0), @"please use number object type");
                if(strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(Class)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    object =  [targetClass performSelector:action withObject:arg];
#pragma clang diagnostic pop
                }else if (strcmp(retType, @encode(void (^)(void))) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    object = [targetClass performSelector:action withObject:arg];
#pragma clang diagnostic pop
                }else if(strcmp(retType, @encode(void)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [targetClass performSelector:action withObject:arg];
#pragma clang diagnostic pop
                }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    object = [targetClass performSelector:action withObject:arg];
#pragma clang diagnostic pop
                }
                break;
            }
        }while (!respondsToAlias && (targetClass = class_getSuperclass(targetClass)));
    }
    if (!respondsToAlias){
#ifdef DEBUG
#if DEBUG
        [object_getClass(name) doesNotRecognizeSelector:action];
#endif
#endif
    }
    if(complete) {
        if(object) {
            complete(@{CompleteResultValueKey:object});
        } else {
            complete(nil);
        }
    }
    return object;
}

- (id)performComponentInstanceMethod:(NSString *)name arguments:(id)arg action:(NSString *)action completion:(void (^)(NSDictionary *))complete cacheInstanceTarget:(BOOL)shouldCached {
    id object = [self performTarget:name action:action params:arg shouldCacheTarget:shouldCached completion:complete];
    return object;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(id)params shouldCacheTarget:(BOOL)shouldCacheTarget completion:(void (^)(NSDictionary *))complete {
    NSObject *target = self.cacheTarget[targetName];
    if(!target) {
        Class targetClass = NSClassFromString(targetName);
        if([actionName hasPrefix:@"init"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if([targetClass instancesRespondToSelector:NSSelectorFromString(actionName)]) {
                target = [[targetClass alloc] performSelector:NSSelectorFromString(actionName) withObject:params];
                if(complete) {
                    if(target) {
                        complete(@{CompleteResultTargetKey:target});
                    } else {
                        complete(@{CompleteErrorKey:[NSString stringWithFormat:@"%@ not found",targetName]});
                    }
                }
                if(target) {
                    if(shouldCacheTarget && ![self.cacheTarget.allKeys containsObject:targetName]) {
                        self.cacheTarget[targetName] = target;
                    }
                }
                return target;
            }
#pragma clang diagnostic pop
        }
        target = [[targetClass alloc] init];
    }
    SEL action = NSSelectorFromString(actionName);
    if (target == nil) {
        if(complete) {
            complete(@{CompleteErrorKey:[NSString stringWithFormat:@"%@ not found",targetName]});
        }
        return nil;
    }
    if(shouldCacheTarget && ![self.cacheTarget.allKeys containsObject:targetName]) {
        self.cacheTarget[targetName] = target;
    }
    id result = [self performOneArgumentByTarget:target selector:action param:params];
    if(complete) {
        if(result) {
            complete(@{CompleteResultTargetKey:target,CompleteResultValueKey:result});
        } else {
            complete(@{CompleteResultTargetKey:target});
        }
    }
    return result;
}


- (id)performComponentMultiArgumentsInstanceMethod:(NSString *)name multiArguments:(NSArray *)arguments action:(SEL)selector completion:(void (^)(NSDictionary *))complete cacheInstanceTarget:(BOOL)shouldCached {
    id object = [self performMultiArgumentsTarget:name action:NSStringFromSelector(selector) params:arguments shouldCacheTarget:shouldCached completion:complete];
    return object;
}

- (id)performMultiArgumentsTarget:(NSString *)targetName action:(NSString *)actionName params:(NSArray *)params shouldCacheTarget:(BOOL)shouldCacheTarget completion:(void (^)(NSDictionary *))complete {
    NSObject *target = self.cacheTarget[targetName];
    if(!target) {
        Class targetClass = NSClassFromString(targetName);
        NSAssert(![actionName hasPrefix:@"init"], @"不支持init方法");
        if([actionName hasPrefix:@"init"]) {
            return nil;
        }
        target = [[targetClass alloc] init];
    }
    SEL action = NSSelectorFromString(actionName);
    if (target == nil) {
        if(complete) {
            complete(@{CompleteErrorKey:[NSString stringWithFormat:@"%@ not found",targetName]});
        }
        return nil;
    }
    if(shouldCacheTarget && ![self.cacheTarget.allKeys containsObject:targetName]) {
        self.cacheTarget[targetName] = target;
    }
    id result = [self performMultiArgumentsByTarget:target selector:action arguments:params];
    if(complete) {
        if(result) {
            complete(@{CompleteResultTargetKey:target,CompleteResultValueKey:result});
        } else {
            complete(@{CompleteResultTargetKey:target});
        }
    }
    return result;
}

- (id)performMultiArgumentsByTarget:(id)target selector:(SEL)actionSel arguments:(NSArray *)params {
    id result = nil;
    if ([target respondsToSelector:actionSel]) {
        result = [self performMultiArgumentsSelector:actionSel withObjects:params target:target];
    } else {
#ifdef DEBUG
#if DEBUG
        [target doesNotRecognizeSelector:actionSel];
#endif
#endif
    }
    return result;
}

- (id)performOneArgumentByTarget:(id)target selector:(SEL)actionSel param:(id)param {
    id result = nil;
    if ([target respondsToSelector:actionSel]) {
        result = [self safePerformAction:actionSel target:target params:param];
    }else {
#ifdef DEBUG
#if DEBUG
        [target doesNotRecognizeSelector:actionSel];
#endif
#endif
    }
    return result;
}

- (id)performInstanceTarget:(id)target arg:(id)arg action:(NSString *)action completion:(void (^)(NSDictionary *))complete {
    if(target) {
        SEL actionSel = NSSelectorFromString(action);
        id result = [self performOneArgumentByTarget:target selector:actionSel param:arg];
        if(complete) {
            if(result) {
                complete(@{CompleteResultTargetKey:target,CompleteResultValueKey:result});
            } else {
                complete(@{CompleteResultTargetKey:target});
            }
        }
        return result;
    } else {
        if(complete) {
            complete(@{CompleteErrorKey:@"target not found"});
        }
    }
    return nil;
}

- (id)performInstanceTarget:(id)target multiArgumets:(NSArray *)arguments action:(SEL)selector completion:(void (^)(NSDictionary *))complete {
    if(target) {
        id result = [self performMultiArgumentsByTarget:target selector:selector arguments:arguments];
        if(complete) {
            if(result) {
                complete(@{CompleteResultTargetKey:target,CompleteResultValueKey:result});
            } else {
                complete(@{CompleteResultTargetKey:target});
            }
        }
        return result;
    } else {
        if(complete) {
            complete(@{CompleteErrorKey:@"target not found"});
        }
    }
    return nil;
}

- (id)objectOfComponent:(NSString *)module {
    if([self.cacheTarget.allKeys containsObject:module]) {
        return [self.cacheTarget objectForKey:module];
    }
    return nil;
}

- (void)component:(id)componentTarget property:(NSString *)propertyName newValue:(id)newValue {
    if(componentTarget) {
        [componentTarget setValue:newValue forKeyPath:propertyName];
    }
}

- (id)propertyValuecomponent:(id)componentTarget property:(NSString *)propertyName {
    if(componentTarget) {
        unsigned int count = 0;
        objc_property_t *propertyList = class_copyPropertyList([componentTarget class], &count);
        for (int i = 0; i<count; i++) {
            objc_property_t t = propertyList[i];
            if([propertyName isEqualToString:[NSString stringWithUTF8String:property_getName(t)]]){
                id property = [componentTarget valueForKeyPath:propertyName];
                return property;
            }
        }
    }
    return nil;
}

- (BOOL)component:(NSString *)componentName canPerformSelector:(SEL)sel {
    Class class = NSClassFromString(componentName);
    return [class instancesRespondToSelector:sel];
}

- (BOOL)component:(NSString *)componentName canPerformAction:(NSString *)action {
    SEL sel = NSSelectorFromString(action);
    Class class = NSClassFromString(componentName);
    return [class instancesRespondToSelector:sel];
}

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName
{
    [self.cacheTarget removeObjectForKey:targetName];
}


#pragma mark - private methods
- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(id)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    NSParameterAssert(methodSig);
    if(methodSig == nil) {
        return nil;
    }
    //const char* retType = [methodSig methodReturnType];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    if(params) {
        if([params isKindOfClass:[NSDictionary class]]) {
            if(dictNonNull((NSDictionary *)params)) {
                [invocation setArgument:&params atIndex:2];
            }
        }else {
            if(params) {
                [invocation setArgument:&params atIndex:2];
            }
        }
    }
    [invocation setSelector:action];
    [invocation setTarget:target];
    [invocation invoke];
    
    return [invocation xma_returnValue];
}

- (id)performMultiArgumentsSelector:(SEL)selector withObjects:(NSArray *)objects target:(NSObject *)target {
    NSAssert([objects isKindOfClass:[NSArray class]] || objects==nil, @"please use array");
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSParameterAssert(signature);
    if (signature == nil) {
        return nil;
        //可以抛出异常也可以不操作。
    }
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    if(objects) {
        NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
        paramsCount = MIN(paramsCount, objects.count);
        for (NSInteger i = 0; i < paramsCount; i++) {
            id object = objects[i];
            if ([object isKindOfClass:[NSNull class]]) continue;
            [invocation setArgument:&object atIndex:i + 2];
        }
    }
    // 调用方法
    [invocation invoke];
    return [invocation xma_returnValue];
}

- (NSMutableDictionary *)cacheTarget {
    if(_cacheTarget == nil) {
        _cacheTarget = [NSMutableDictionary new];
    }
    return _cacheTarget;
}

BOOL dictNonNull(NSDictionary *dict) {
    if(dict && dict.allValues.count>0) {
        return YES;
    }
    return NO;
};

//https://segmentfault.com/a/1190000004141249
+ (id)performClassTarget:(NSString *)targetString selector:(NSString *)selectorString,...{
    Class targetClass = NSClassFromString(targetString);
    SEL selector = NSSelectorFromString(selectorString);
    va_list args;
    va_start(args, selectorString);
    NSInvocation *invocation = [NSInvocation invocationWithTarget:targetClass selector:selector withArgs:args];
    va_end(args);
    if (invocation) {
        [invocation invoke];
        return [invocation xma_returnValue];
    }else{
        return nil;
    }
    
}
- (id)performInstanceTarget:(id)targetObject selector:(NSString *)selectorString,...{
    NSObject *target=nil;
    if ([targetObject isKindOfClass:[NSString class]]) {
        NSAssert(![selectorString isEqualToString:@"init"], @"不支持init方法");
        if([selectorString isEqualToString:@"init"]) {
            return nil;
        }
        Class targetClass = NSClassFromString(targetObject);
        if (targetClass == nil) {
            target = targetObject;
        }else{
            target = [[targetClass alloc] init];
        }
    }else{
        target = targetObject;
    }
    SEL selector = NSSelectorFromString(selectorString);
    va_list args;
    va_start(args, selectorString);
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector withArgs:args];
    va_end(args);
    if (invocation) {
        [invocation invoke];
        return [invocation xma_returnValue];
    }else{
        return nil;
    }
}
@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSInvocation (Aspects)

@implementation NSInvocation (Aspects)

// Thanks to the ReactiveCocoa team for providing a generic solution for this.
- (id)aspect_argumentAtIndex:(NSUInteger)index {
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;
    
#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getArgument:&theClass atIndex:(NSInteger)index];
        return theClass;
        // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(bool)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    return nil;
#undef WRAP_AND_RETURN
}

- (NSArray *)aspects_arguments {
    NSMutableArray *argumentsArray = [NSMutableArray array];
    for (NSUInteger idx = 2; idx < self.methodSignature.numberOfArguments; idx++) {
        [argumentsArray addObject:[self aspect_argumentAtIndex:idx] ?: NSNull.null];
    }
    return [argumentsArray copy];
}

- (void)setArguments:(NSArray *)argumentsArray {
    NSInteger paramsCount = self.methodSignature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, argumentsArray.count);
    for (NSInteger i = 0; i < paramsCount; i++) {
        id object = argumentsArray[i];
        if ([object isKindOfClass:[NSNull class]]) continue;
        [self setArgument:&object atIndex:i + 2];
    }
}
//RAC
- (id)xma_returnValue {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[self getReturnValue:&val]; \
return @(val); \
} while (0)
    
    const char *returnType = self.methodSignature.methodReturnType;
    // Skip const type qualifier.
    if (returnType[0] == 'r') {
        returnType++;
    }
    
    if (strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0 || strcmp(returnType, @encode(void (^)(void))) == 0) {
        __autoreleasing id returnObj;
        [self getReturnValue:&returnObj];
        return returnObj;
    } else if (strcmp(returnType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(returnType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(returnType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(returnType, @encode(void)) == 0) {
        return nil;
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(returnType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getReturnValue:valueBytes];
        
        return [NSValue valueWithBytes:valueBytes objCType:returnType];
    }
    return nil;
    
#undef WRAP_AND_RETURN
}

+ (instancetype)invocationWithTarget:(id)target selector:(SEL)selector withArgs:(va_list)args{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (!signature) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    
#define ARG_GET_SET(type) do { type val = 0; val = va_arg(args,type); [invocation setArgument:&val atIndex:i+2];} while (0)
    NSInteger argsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    for(NSUInteger i = 0; i < argsCount ; ++i){
        const char* argType = [invocation.methodSignature getArgumentTypeAtIndex:i + 2];
        if (argType[0] == _C_CONST) argType++;
        
        if (argType[0] == '@') {                                //id and block
            ARG_GET_SET(id);
        }else if (strcmp(argType, @encode(Class)) == 0 ){       //Class
            ARG_GET_SET(Class);
        }else if (strcmp(argType, @encode(IMP)) == 0 ){         //IMP
            ARG_GET_SET(IMP);
        }else if (strcmp(argType, @encode(SEL)) == 0) {         //SEL
            ARG_GET_SET(SEL);
        }else if (strcmp(argType, @encode(double)) == 0){       //
            ARG_GET_SET(double);
        }else if (strcmp(argType, @encode(float)) == 0){
            float val = 0;
            val = (float)va_arg(args,double);
            [invocation setArgument:&val atIndex:1 + i];
        }else if (argType[0] == '^'){                           //pointer ( andconst pointer)
            ARG_GET_SET(void*);
        }else if (strcmp(argType, @encode(char *)) == 0) {      //char* (and const char*)
            ARG_GET_SET(char *);
        }else if (strcmp(argType, @encode(unsigned long)) == 0) {
            ARG_GET_SET(unsigned long);
        }else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            ARG_GET_SET(unsigned long long);
        }else if (strcmp(argType, @encode(long)) == 0) {
            ARG_GET_SET(long);
        }else if (strcmp(argType, @encode(long long)) == 0) {
            ARG_GET_SET(long long);
        }else if (strcmp(argType, @encode(int)) == 0) {
            ARG_GET_SET(int);
        }else if (strcmp(argType, @encode(unsigned int)) == 0) {
            ARG_GET_SET(unsigned int);
        }else if (strcmp(argType, @encode(BOOL)) == 0 || strcmp(argType, @encode(bool)) == 0
                  || strcmp(argType, @encode(char)) == 0 || strcmp(argType, @encode(unsigned char)) == 0
                  || strcmp(argType, @encode(short)) == 0 || strcmp(argType, @encode(unsigned short)) == 0) {
            ARG_GET_SET(int);
        }else{                  //struct union and array
            //            assert(false && "struct union array unsupported!");
        }
    }
    return invocation;
#undef ARG_GET_SET
}
@end

