//
//  ZYBMediatorUtils.m
//  ZYBMediator
//
//  Created by binaryc on 2021/8/24.
//

#import "ZYBMediatorUtils.h"
#import <objc/runtime.h>

@implementation ZYBMediatorUtils

+ (BOOL)checkObject:(Class)cls implementProtocol:(Protocol *)prot {
    if (cls == nil || prot == nil) {
        return NO;
    }
    
    id instance = [[cls alloc] init];
    if (![self __checkObject:instance implementProtocol:prot isRequiredMethod:YES isInstanceMethod:YES recursive:YES skipNSObjectProtocol:YES]) {
        return NO;
    }
    if (![self __checkObject:cls implementProtocol:prot isRequiredMethod:YES isInstanceMethod:NO recursive:YES skipNSObjectProtocol:YES]) {
        return NO;
    }
   
    return YES;
}

+ (BOOL)__checkObject:(id)object implementProtocol:(Protocol *)prot isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod recursive:(BOOL)recursive skipNSObjectProtocol:(BOOL)skipNSObjectProtocol {
    if (skipNSObjectProtocol && protocol_isEqual(prot, @protocol(NSObject)) ) {
        return YES;
    }
    
    if (recursive) {
        unsigned int protocolCount = 0;
        __unsafe_unretained Protocol **protocolList = protocol_copyProtocolList(prot, &protocolCount);
        for (int i = 0; i < protocolCount; i++) {
            if (![self __checkObject:object implementProtocol:protocolList[i] isRequiredMethod:isRequiredMethod isInstanceMethod:isInstanceMethod recursive:recursive skipNSObjectProtocol:skipNSObjectProtocol]) {
                return NO;
            }
        }
    }
    
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(prot, isRequiredMethod, isInstanceMethod, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        if (![object respondsToSelector:methods[i].name]) {
            return NO;
        }
    }
    
    free(methods);
    return YES;
}

@end


