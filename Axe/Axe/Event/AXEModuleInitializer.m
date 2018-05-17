//
//  AXEModuleInitializer.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEModuleInitializer.h"

NSString *const AXEEventModulesBeginInitializing = @"AXEEventModulesBeginInitializing";

static NSMutableArray *registeredModules;

@implementation AXEModuleInitializerManager


+ (void)registerModuleInitializer:(Class)initializer {
    NSParameterAssert(initializer);
    if ([initializer conformsToProtocol:@protocol(AXEModuleInitializer)]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            registeredModules = [[NSMutableArray alloc] init];
        });
        [registeredModules addObject:initializer];
    }else {
        NSLog(@"模块初始程序 必须实现协议 AXEModuleInitializer , 当前类%@不支持",NSStringFromClass(initializer));
    }
}


+ (void)initializeModules {
    if (registeredModules) {
        for (Class cls in registeredModules) {
            id<AXEModuleInitializer> initializer = [[cls alloc] init];
            [initializer AEXInitialize];
        }
    }
    [AXEEvent postEventName:AXEEventModulesBeginInitializing];
}

@end



