//
//  ConcurrentMutableDictionary.m
//  Pods
//
//  Created by zyb on 2021/8/2.
//

#import "ConcurrentMutableDictionary.h"
#import <pthread/pthread.h>
#import <os/lock.h>
#import <libkern/OSAtomic.h>

#pragma mark - Semaphore

@interface ConcurrentSemaphoreDictionary (){
    NSMutableDictionary* _dict;
    dispatch_semaphore_t _signal;
    dispatch_time_t _overTime;
}
@end

@implementation ConcurrentSemaphoreDictionary

- (instancetype)initCommon{
    self = [super init];
    if (self) {
        _signal = dispatch_semaphore_create(1);
        _overTime = DISPATCH_TIME_FOREVER;
    }
    return self;
}
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
    }
    return self;
}
- (NSUInteger)count
{
    dispatch_semaphore_wait(_signal, _overTime);
    NSUInteger count = [_dict count];
    dispatch_semaphore_signal(_signal);
    return count;
}

- (id)objectForKey:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    dispatch_semaphore_wait(_signal, _overTime);
    id result = [_dict objectForKey:key];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (id)objectForKeyedSubscript:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    dispatch_semaphore_wait(_signal, _overTime);
    id result =  [_dict objectForKeyedSubscript:key];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    dispatch_semaphore_wait(_signal, _overTime);
    NSEnumerator *result = [_dict keyEnumerator];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    dispatch_semaphore_wait(_signal, _overTime);
    [_dict setObject:anObject forKey:aKey];
    dispatch_semaphore_signal(_signal);
}

- (void)setObject:(id)anObject forKeyedSubscript:(id <NSCopying>)key
{
    dispatch_semaphore_wait(_signal, _overTime);
    [_dict setObject:anObject forKeyedSubscript:key];
    dispatch_semaphore_signal(_signal);
}

- (NSArray *)allKeys
{
    dispatch_semaphore_wait(_signal, _overTime);
    NSArray *result = [_dict allKeys];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (NSArray *)allValues
{
    dispatch_semaphore_wait(_signal, _overTime);
    NSArray *result = [_dict allValues];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (void)removeObjectForKey:(id)aKey
{
    dispatch_semaphore_wait(_signal, _overTime);
    [_dict removeObjectForKey:aKey];
    dispatch_semaphore_signal(_signal);
}

- (void)removeAllObjects
{
    dispatch_semaphore_wait(_signal, _overTime);
    [_dict removeAllObjects];
    dispatch_semaphore_signal(_signal);
}

- (id)copy
{
    dispatch_semaphore_wait(_signal, _overTime);
    id result = [_dict copy];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (id)mutableCopy{
    dispatch_semaphore_wait(_signal, _overTime);
    id result = [_dict mutableCopy];
    dispatch_semaphore_signal(_signal);
    return result;
}

- (void)dealloc
{
}

@end

#pragma mark - GCD barriar
@interface ConcurrentBarriarDictionary : NSMutableDictionary{
    NSMutableDictionary* _dict;
    dispatch_queue_t _rwQueue;
}
@end

@implementation ConcurrentBarriarDictionary

- (instancetype)initCommon{
    self = [super init];
    if (self) {
        _rwQueue = dispatch_queue_create("com.zyb.barriarDicQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
    }
    return self;
}
- (NSUInteger)count
{
    __block NSUInteger count;
    dispatch_sync(_rwQueue, ^{
        count = [_dict count];
    });
    return count;
}

- (id)objectForKey:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict objectForKey:key];
    });
    return result;
}

- (id)objectForKeyedSubscript:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict objectForKeyedSubscript:key];
    });
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict keyEnumerator];
    });
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (nil == aKey || nil == anObject) {
        return;
    }
    
    dispatch_barrier_async(_rwQueue, ^{
        [self->_dict setObject:anObject forKey:aKey];
    });
}

- (void)setObject:(id)anObject forKeyedSubscript:(id <NSCopying>)key
{
    if (nil == key || nil == anObject) {
        return;
    }
    
    dispatch_barrier_async(_rwQueue, ^{
        [self->_dict setObject:anObject forKeyedSubscript:key];
    });
}

- (NSArray *)allKeys
{
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict allKeys];
    });
    return result;
}

- (NSArray *)allValues
{
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict allValues];
    });
    return result;
}

- (void)removeObjectForKey:(id)aKey
{
    if (nil == aKey) {
        return;
    }
    
    dispatch_barrier_async(_rwQueue, ^{
        [self->_dict removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects
{
    dispatch_barrier_async(_rwQueue, ^{
        [self->_dict removeAllObjects];
    });
}

- (id)copy
{
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict copy];
    });
    return result;
}

- (id)mutableCopy{
    __block id result;
    dispatch_sync(_rwQueue, ^{
        result = [_dict mutableCopy];
    });
    return result;
}

- (void)dealloc {}

@end

#pragma mark - spin lock
@interface ConcurrentSpinlockDictionary (){
    NSMutableDictionary* _dict;
    OSSpinLock _spinlock;
}
@end

@implementation ConcurrentSpinlockDictionary

- (instancetype)initCommon{
    self = [super init];
    if (self) {
        _spinlock = OS_SPINLOCK_INIT;
    }
    return self;
}
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
    }
    return self;
}
- (NSUInteger)count
{
    OSSpinLockLock(&_spinlock);
    NSUInteger count = [_dict count];
    OSSpinLockUnlock(&_spinlock);
    return count;
}

- (id)objectForKey:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    OSSpinLockLock(&_spinlock);
    id result = [_dict objectForKey:key];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (id)objectForKeyedSubscript:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    OSSpinLockLock(&_spinlock);
    id result =  [_dict objectForKeyedSubscript:key];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    OSSpinLockLock(&_spinlock);
    NSEnumerator *result = [_dict keyEnumerator];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    OSSpinLockLock(&_spinlock);
    [_dict setObject:anObject forKey:aKey];
    OSSpinLockUnlock(&_spinlock);
}

- (void)setObject:(id)anObject forKeyedSubscript:(id <NSCopying>)key
{
    OSSpinLockLock(&_spinlock);
    [_dict setObject:anObject forKeyedSubscript:key];
    OSSpinLockUnlock(&_spinlock);
}

- (NSArray *)allKeys
{
    OSSpinLockLock(&_spinlock);
    NSArray *result = [_dict allKeys];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (NSArray *)allValues
{
    OSSpinLockLock(&_spinlock);
    NSArray *result = [_dict allValues];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (void)removeObjectForKey:(id)aKey
{
    OSSpinLockLock(&_spinlock);
    [_dict removeObjectForKey:aKey];
    OSSpinLockUnlock(&_spinlock);
}

- (void)removeAllObjects
{
    OSSpinLockLock(&_spinlock);
    [_dict removeAllObjects];
    OSSpinLockUnlock(&_spinlock);
}

- (id)copy
{
    OSSpinLockLock(&_spinlock);
    id result = [_dict copy];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (id)mutableCopy{
    OSSpinLockLock(&_spinlock);
    id result = [_dict mutableCopy];
    OSSpinLockUnlock(&_spinlock);
    return result;
}

- (void)dealloc
{
}

@end

#pragma mark - rwlock
@interface ConcurrentRwlockDictionary (){
    NSMutableDictionary* _dict;
    pthread_rwlock_t _rwlock;
}
@end

@implementation ConcurrentRwlockDictionary

- (instancetype)initCommon{
    self = [super init];
    if (self) {
        pthread_rwlock_init(&_rwlock, NULL);
    }
    return self;
}
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
    }
    return self;
}
- (NSUInteger)count
{
    pthread_rwlock_rdlock(&_rwlock);
    NSUInteger count = [_dict count];
    pthread_rwlock_unlock(&_rwlock);
    return count;
}

- (id)objectForKey:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    pthread_rwlock_rdlock(&_rwlock);
    id result = [_dict objectForKey:key];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (id)objectForKeyedSubscript:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    pthread_rwlock_rdlock(&_rwlock);
    id result =  [_dict objectForKeyedSubscript:key];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    pthread_rwlock_rdlock(&_rwlock);
    NSEnumerator *result = [_dict keyEnumerator];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    pthread_rwlock_wrlock(&_rwlock);
    [_dict setObject:anObject forKey:aKey];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)setObject:(id)anObject forKeyedSubscript:(id <NSCopying>)key
{
    pthread_rwlock_wrlock(&_rwlock);
    [_dict setObject:anObject forKeyedSubscript:key];
    pthread_rwlock_unlock(&_rwlock);
}

- (NSArray *)allKeys
{
    pthread_rwlock_rdlock(&_rwlock);
    NSArray *result = [_dict allKeys];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (NSArray *)allValues
{
    pthread_rwlock_rdlock(&_rwlock);
    NSArray *result = [_dict allValues];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (void)removeObjectForKey:(id)aKey
{
    pthread_rwlock_wrlock(&_rwlock);
    [_dict removeObjectForKey:aKey];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)removeAllObjects
{
    pthread_rwlock_wrlock(&_rwlock);
    [_dict removeAllObjects];
    pthread_rwlock_unlock(&_rwlock);
}

- (id)copy
{
    pthread_rwlock_rdlock(&_rwlock);
    id result = [_dict copy];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (id)mutableCopy{
    pthread_rwlock_rdlock(&_rwlock);
    id result = [_dict mutableCopy];
    pthread_rwlock_unlock(&_rwlock);
    return result;
}

- (void)dealloc
{
    pthread_rwlock_destroy(&_rwlock);
}

@end

#pragma mark - pthread mutex
@interface ConcurrentMutexDictionary (){
    NSMutableDictionary* _dict;
    pthread_mutex_t _mutex;
    pthread_mutexattr_t _mutexAttr;
}
@end

@implementation ConcurrentMutexDictionary

- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        pthread_mutexattr_init(&(_mutexAttr));
        pthread_mutexattr_settype(&(_mutexAttr), PTHREAD_MUTEX_RECURSIVE); // must use recursive lock
        pthread_mutex_init(&(_mutex), &(_mutexAttr));
    }
    return self;
}
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
    }
    return self;
}
- (NSUInteger)count
{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict count];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id)objectForKey:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict objectForKey:key];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id)objectForKeyedSubscript:(id)key
{
    if (nil == key) {
        return nil;
    }
    
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict objectForKeyedSubscript:key];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (NSEnumerator *)keyEnumerator
{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict keyEnumerator];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    id originalObject = nil; // make sure that object is not released in lock
    @try {
        pthread_mutex_lock(&_mutex);
        originalObject = [_dict objectForKey:aKey];
        [_dict setObject:anObject forKey:aKey];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
    originalObject = nil;
}

- (void)setObject:(id)anObject forKeyedSubscript:(id <NSCopying>)key
{
    id originalObject = nil; // make sure that object is not released in lock
    @try {
        pthread_mutex_lock(&_mutex);
        originalObject = [_dict objectForKey:key];
        [_dict setObject:anObject forKeyedSubscript:key];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
    originalObject = nil;
}

- (NSArray *)allKeys
{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict allKeys];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (NSArray *)allValues
{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict allValues];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (void)removeObjectForKey:(id)aKey
{
    id originalObject = nil; // make sure that object is not released in lock
    @try {
        pthread_mutex_lock(&_mutex);
        originalObject = [_dict objectForKey:aKey];
        if (originalObject) {
            [_dict removeObjectForKey:aKey];
        }
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
    originalObject = nil;
}

- (void)removeAllObjects
{
    NSArray* allValues = nil; // make sure that objects are not released in lock
    @try {
        pthread_mutex_lock(&_mutex);
        allValues = [_dict allValues];
        [_dict removeAllObjects];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
    allValues = nil;
}

- (id)copy
{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict copy];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id)mutableCopy{
    @try {
        pthread_mutex_lock(&_mutex);
        return [_dict mutableCopy];
    }
    @finally {
        pthread_mutex_unlock(&_mutex);
    }
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
    pthread_mutexattr_destroy(&_mutexAttr);
}

@end
