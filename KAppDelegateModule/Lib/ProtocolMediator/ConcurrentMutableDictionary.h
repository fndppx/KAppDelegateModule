//
//  ConcurrentMutableDictionary.h
//  Pods
//
//  Created by zyb on 2021/8/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConcurrentMutexDictionary : NSMutableDictionary
@end

@interface ConcurrentSpinlockDictionary : NSMutableDictionary
@end

@interface ConcurrentRwlockDictionary : NSMutableDictionary
@end

@interface ConcurrentSemaphoreDictionary : NSMutableDictionary
@end

NS_ASSUME_NONNULL_END
