//
//  XMAMediator.h
//  XMAGroup
//
//  Created by kyan on 2023/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define XMAMediator_Class_SEL(class,action) @"routerHandleClass_##class##_##action##_arg:callback:"
#define XMAMediator_Class_METHOD(class,action) + (id)routerHandleClass_##class##_##action##_arg:(NSDictionary*)arg callback:(void (^)(NSDictionary *callback))callback

#define XMAMediator_Instance_SEL(class,action) @"routerHandleInstance_##class##_##action##_arg:callback:"
#define XMAMediator_Instance_METHOD(class,action) - (id)routerHandleInstance_##class##_##action##_arg:(NSDictionary*)arg callback:(void (^)(NSDictionary *callback))callback

static NSString *const CompleteResultTargetKey = @"object";
static NSString *const CompleteResultValueKey = @"result";
static NSString *const CompleteErrorKey = @"error";

@interface XMAMediator : NSObject

//----------------------The tutorial------------
/*1.实例方法：first 确认你的业务对象生命周期，由谁维护
 ex: a. router 维护对象生命周期 ，类classA，cacheInstanceTarget：为YES
 1.id value = [[XMAMediator shareInstance] performComponentInstanceMethod:classA.name arguments:参数 action:action(方法名) completion:complete(回调，可选) cacheInstanceTarget:YES];
 //value 为方法返回值
 2.classA *A = [[XMAMediator shareInstance] objectOfComponent:classA.name];//取出实例对象
 A 为router维护的类classA的一个实例对象，同一时刻只有一个实例对象
 有了对象实例，可以通过router下面👇方法调用对象的其他方法，操作属性等，看具体注释
 
 b. 外部自行维护生命周期，类classA，cacheInstanceTarget：为NO
 1.classA *A = [[XMAMediator shareInstance] performComponentInstanceMethod:classA.name arguments:参数 action:action(方法名) completion:complete(回调，可选) cacheInstanceTarget:NO];
 //A 确保你的第一个使用方法 返回值为实例对象,自己持有A，这样后续操作 使用实例A 继续调用
 2.或者直接init方法classA *A = [[XMAMediator shareInstance] performComponentInstanceMethod:classA.name arguments:参数 action:@"init" completion:complete(回调，可选) cacheInstanceTarget:NO];
 有了对象实例，可以通过router下面👇方法调用对象的其他方法，操作属性等，看具体注释
 
 !!! 使用完毕 适当时机 一定调用relase来释放实例内存
 [XMAMediator shareInstance] releaseCachedTargetWithTargetName:classA.name];
 
 2.类方法：
 ex: classA
 a.
 [XMAMediator performComponentClassMethod:classA.name arguments:(arg(类方法参数) action:classAction(类方法) completion:(void (^)(NSDictionary *))complete];
 
 3.支持方法，传递多个参数，具体看各个注释
 4.！！返回值一定确保是以下类型，不支持个别C型，dispatch_queue_t等不常用返回值
 id,class,sel,char,int short long double,bool void(^)()等
 */

//功能组件，UI组件
//UI组件功能跳转
//后面提供多个参数的调用，SEL有多个argument,参考Aspects、RAC
+ (instancetype)shareInstance;

//module must follow macro above
//适用通过module名调用类、实例方法
+ (id)openComponentClassMethod:(NSString *)module arguments:(id)arg completion:(void (^)(NSDictionary *callback))complete;
- (id)openComponentInstanceMethod:(NSString *)module arguments:(id)arg completion:(void (^)(NSDictionary *callback))complete;

//直接调用
+ (id)performComponentClassMethod:(NSString *)name arguments:(id)arg action:(NSString *)classAction completion:(void (^)(NSDictionary *))complete;
//shouldCached:是否持有实例，继续调用该module时 决定是否alloc新实例
- (id)performComponentInstanceMethod:(NSString *)name arguments:(id)arg action:(NSString *)action completion:(void (^)(NSDictionary *))complete cacheInstanceTarget:(BOOL)shouldCached;
//适用selector有多个参数时
- (id)performComponentMultiArgumentsInstanceMethod:(NSString *)name multiArguments:(NSArray *)arguments action:(SEL)selector completion:(void (^)(NSDictionary *))complete cacheInstanceTarget:(BOOL)shouldCached;

//------------------------------
//适用已持有实例target 调用target服务的场景
- (id)performInstanceTarget:(id)target arg:(id)arg action:(NSString *)action completion:(void (^)(NSDictionary *))complete;
- (id)performInstanceTarget:(id)target multiArgumets:(NSArray *)arguments action:(SEL)selector completion:(void (^)(NSDictionary *))complete;

//当前component对应的实例,shouldCached为YES才会有
- (id)objectOfComponent:(NSString *)module;

//组件属性的read write 操作
- (void)component:(id)componentTarget property:(NSString *)propertyName newValue:(id)newValue;
- (id)propertyValuecomponent:(id)componentTarget property:(NSString *)propertyName;

- (BOOL)component:(NSString *)componentName canPerformSelector:(SEL)sel;
- (BOOL)component:(NSString *)componentName canPerformAction:(NSString *)action;

//需要router持有对象实例的时候，需要释放对象的时候  一定要手动调用
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

//https://segmentfault.com/a/1190000004141249
+ (id)performClassTarget:(NSString *)targetString selector:(NSString *)selectorString,...;
- (id)performInstanceTarget:(id)targetObject selector:(NSString *)selectorString,...;
@end

@interface NSInvocation (Aspects)
- (id)aspect_argumentAtIndex:(NSUInteger)index;
- (NSArray *)aspects_arguments;
- (id)xma_returnValue;
+ (instancetype)invocationWithTarget:(id)target selector:(SEL)selector  withArgs:(va_list)args;
@end


NS_ASSUME_NONNULL_END
