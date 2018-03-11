//
//  AXEEvent.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AXEData.h"
#import "AXEEXTScope.h"

/**
    事件回调block。 参数info 与 NSNotification 所带信息相同。
 */
typedef void(^AXEEventHandlerBlock)(AXEData *payload);

// 默认事件优先级 ,为1 。 事件支持优先级， 越高就能越快处理。
extern NSInteger const AXEEventDefaultPriority;



/**
  负责监听的释放。
 */
@protocol AXEListenerDisposable <NSObject>


/**
 释放监听。
 */
- (void)dispose;

@end


@protocol AXEEventUserInterfaceContainer;
/**
 * 事件管理， 简化通知机制，支持block ，同时提供同步、异步、以及优先级控制等。
 *   使用block的监听，最重要的是要注意 对象的持有问题。 对于持久监听，建议使用 @weakify 和 @strongify宏。
 *  @code
 
     id foo = [[NSObject alloc] init];
     id bar = [[NSObject alloc] init];
 
     @weakify(foo, bar);
     [AXEEvent registerListenerForEventName: @"foobar" handler:^(){
        @strongify(foo, bar);
 
     }];
 */
@interface AXEEvent : NSObject


/**
  发送事件通知

 @param name 名称
 */
+ (void)postEventName:(NSString *)name;


/**
  发送事件通知

 @param name 名称
 @param payload 附带的信息。
 */
+ (void)postEventName:(NSString *)name withPayload:(AXEData *)payload;



/**
  将 NSNotification的通知转换为 AXEEvent通知。
  需要注意的是， 这里附带的用户信息， 在 NSNotification中发送的是 NSDictionary
  转换成 AXEData , 然后存在 @"userInfo"中。
 
 @param notificationName 原通知名称。
 */
+ (void)translateNotification:(NSString *)notificationName;


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



// 以下这些通知，在初始化时，被自动接入到 AXEEvent事件通知系统中。
UIKIT_EXTERN NSNotificationName const UIApplicationDidEnterBackgroundNotification;
UIKIT_EXTERN NSNotificationName const UIApplicationWillEnterForegroundNotification;
UIKIT_EXTERN NSNotificationName const UIApplicationDidBecomeActiveNotification;
UIKIT_EXTERN NSNotificationName const UIApplicationWillResignActiveNotification;
UIKIT_EXTERN NSNotificationName const UIApplicationWillTerminateNotification;

extern NSString *const AXEEventNotificationUserInfoKey;
