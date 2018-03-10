//
//  AXEModuleInitializer.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEEvent.h"

// 模块初始化程序 注册宏。
#define AXEMODULEINITIALIZE_REGISTER()\
+ (void)load{[AXEModuleInitializerManager registerModuleInitializer:[self class]];}

/**
  模块初始化程序
 */
@protocol AXEModuleInitializer<NSObject>
/**
 固定使用这个函数初始化。

 */
- (id)init;
/**
 模块将初始化功能放置在该方法中， 一般通过监听AXEEventModulesBeginInitializing ，来实现异步按序初始化所有模块。
 */
- (void)AEXInitialize;
@end


/**
 * 模块初始化程序。
 *   基于AXEEvent 提供便捷的模块初始化功能.
 *
 *   要使用该功能， 应该在ApplicationDidFinishLaunching时， 调用
 *   [AXEModuleInitializerManager initializeModules];
 *
 *   然后对于一个模块，可以这样编写初始化代码:

    @interface LoginModuleInitializer : NSObject<AXEModuleInitializer>
    @end
    @implementation LoginModuleInitializer
    AXEMODULEINITIALIZE_REGISTER()

    - (void)AEXInitialize {
        [AXEAutoRemoveEvent registerAsyncListenerForEventName:AXEEventModulesBeginInitializing handler:^(NSDictionary *info) {
            NSLog(@"hello world");
        } priority:LoginModulePriority inSerialQueue:YES];
    }
    @end
 *  这样做的好处，就是可以更加有效地管理模块的初始化， 将必要的模块优先初始化，将不必须的模块延后和异步初始化。
 *  同时也没有过度依赖load函数
 */
@interface AXEModuleInitializerManager : NSObject


/**
  初始化所有模块 。
    使用 AXEModuleInitializerManager 管理模块初始化时，将该函数在ApplicationDidFinishLaunching 时执行。
    该函数会发送 AXEEventModulesBeginInitializing 通知，以替代 ApplicationDidFinishLaunching 帮助组件初始化。
 */
+ (void)initializeModules;

/**
  注册 模块初始器。

 @param initializer 模块初始器。 类需要实现 AXEModuleInitializer
 */
+ (void)registerModuleInitializer:(Class)initializer;

@end



/**
  组件初始化开始通知。
 */
extern NSString *const AXEEventModulesBeginInitializing;
