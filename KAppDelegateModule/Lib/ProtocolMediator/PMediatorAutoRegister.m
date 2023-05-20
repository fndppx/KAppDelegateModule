//
//  ZYBMediatorAutoRegister.m
//  ZYBMediator
//
//  Created by binaryc on 2021/8/27.
//

#import "PMediatorAutoRegister.h"
#import "PMediator.h"
#import "ZYBMediatorUtils.h"
#include <mach-o/getsect.h>
#include <mach-o/dyld.h>

NSArray<NSArray *>* __ReadMediatorRegedit(char *sectionName,const struct mach_header *mhp);
static void __dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    NSArray *serviceRegedit = __ReadMediatorRegedit(MEDIATOR_SECTION_NAME,mhp);
     for (NSArray *info in serviceRegedit) {
         Protocol *service = NSProtocolFromString(info[0]);
         Class serviceCls = NSClassFromString(info[1]);
         [[PMediator sharedInstance] registerService:service implementClass:serviceCls];
     }
}
__attribute__((constructor))
void __initMediatorProphet(void) {
    _dyld_register_func_for_add_image(__dyld_callback);
}

NSArray<NSArray *>* __ReadMediatorRegedit(char *sectionName,const struct mach_header *mhp)
{
    NSMutableArray *regedit = [NSMutableArray arrayWithCapacity:8];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long counter = size/sizeof(_ZYBServiceInfo);
    _ZYBServiceInfo *infos = (_ZYBServiceInfo *)memory;
    for(int idx = 0; idx < counter; ++idx){
        NSString *prot = [NSString stringWithUTF8String:infos[idx].prot_name];
        NSString *cls = [NSString stringWithUTF8String:infos[idx].impl_cls_name];
        if (prot&&cls) {
            [regedit addObject:@[prot, cls]];
        }
    }
    
    return regedit;
}

@implementation ZYBMediatorAutoRegister

@end
