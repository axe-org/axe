//
//  AXEAutoRemoveEvent.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEEvent.h"

/**
 AXEEvent 的派生类， 提供了简单的 自动释放的事件监听， 在事件执行一次后，会自动取消监听。
 */
@interface AXEAutoRemoveEvent : AXEEvent


/**
 注册监听 。 默认是注册同步监听。
 如果在一个事件回调中添加对这个事件的监听，显然只能在下次生效。
 @param name 名称
 @param handler 回调
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerListenerForEventName:(NSString *)name
                                                  handler:(AXEEventHandlerBlock)handler;


/**
 注册监听。 监听为同步监听。
 
 @param name 名称
 @param handler 回调
 @param priority 优先级， 高优先级任务优先处理， 同优先级会根据添加顺序决定。
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerSyncListenerForEventName:(NSString *)name
                                                      handler:(AXEEventHandlerBlock)handler
                                                     priority:(NSInteger)priority;



/**
 注册监听。 异步监听
 
 @param name 名称
 @param handler 回调
 @param priority 优先级
 @param isSerial 是否串行 。 串行，则多个监听会依次执行。 为NO表示并行,即创建单独线程执行。
 建议对于 耗时操作，不要使用串行，使用并行以创建单独线程，避免阻塞其他事件监听。
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerAsyncListenerForEventName:(NSString *)name
                                                       handler:(AXEEventHandlerBlock)handler
                                                      priority:(NSInteger)priority
                                                 inSerialQueue:(BOOL)isSerial;


/**
 注册监听。 称之为UI事件监听。 执行在主线程中。
 该监听的特点是， 执行在主线程中。 供那些需要在回调中执行UI操作的任务。
 注意， 对于UI操作，我们约束，如果当前页面不在前台，则不执行，而是保留事件，直到容器回到前台时，才执行事件回调。
 @param name 名称
 @param handler 回调
 @param priority 优先级
 @param container 所在容器 , 通过协议AXEUIContainer来进行约束， 简单实现了对 UIViewController的封装， 也可以自行实现并接入。
 @return 释放器。
 */
+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                                   priority:(NSInteger)priority
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container;

/**
 注册监听，使用默认优先级。
 */
+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container;

@end
