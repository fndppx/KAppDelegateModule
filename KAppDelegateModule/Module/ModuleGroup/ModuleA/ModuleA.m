//
//  ModuleA.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ModuleA.h"
#import "ModuleA+A.h"
#import "ModuleA+B.h"
@implementation ModuleA
- (void)setupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
    [self aModuleInit];
    [self bModuleInit];
}

- (void)preSetupWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    
}

@end
