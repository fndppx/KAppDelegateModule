//
//  ZYBMediatorUtils.h
//  ZYBMediator
//
//  Created by binaryc on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MEDIATOR_SECTION_NAME "ZYBMediator"
typedef struct { char *prot_name; char *impl_cls_name; } _ZYBServiceInfo;
#define AUTO_REGISTER_SERVICE(prot, cls)                                                      \
static _ZYBServiceInfo __ZYB##prot __attribute__ ((used, section ("__DATA, ZYBMediator"))) =  \
{                                                                                             \
    (char *)&""#prot"",                                                                               \
    (char *)&""#cls""                                                                                 \
};


@interface ZYBMediatorUtils : NSObject

+ (BOOL)checkObject:(Class)cls implementProtocol:(Protocol *)prot;

@end

NS_ASSUME_NONNULL_END
