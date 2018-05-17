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
    事件回调block。
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
 *  使用block的监听，最重要的是要注意 对象的持有问题。 对于持久监听，建议使用 @weakify 和 @strongify宏。
 *  @code
 
     id foo = [[NSObject alloc] init];
     id bar = [[NSObject alloc] init];
 
     @weakify(foo, bar);
     [AXEEvent registerListenerForEventName: @"foobar" handler:^(){
        @strongify(foo, bar);
 
     }];
 
  * 
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
  转换存储在 AXEData中， key为 "userInfo"
 
 @param notificationName 原通知名称。
 */
+ (void)translateNotification:(NSString *)notificationName;


/**
 注册同步监听， 使用默认优先级。
 同步监听会在当前发送通知的线程执行。
 如果在一个事件回调中添加对这个事件的监听，显然只能在下次生效。
 @param name 名称
 @param handler 回调
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerListenerForEventName:(NSString *)name
                                                  handler:(AXEEventHandlerBlock)handler;


/**
 注册同步监听。
 
 @param name 名称
 @param handler 回调
 @param priority 优先级， 高优先级任务优先处理， 同优先级会根据添加顺序决定。
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerSyncListenerForEventName:(NSString *)name
                                                      handler:(AXEEventHandlerBlock)handler
                                                     priority:(NSInteger)priority;



/**
 注册 异步序列监听。 异步监听分两种 序列与并发， 序列监听回调会在一个异步gcd的queue中按照优先级依次执行。
 不推荐做耗时的操作，会阻塞其他事件的处理。
 @param name 名称
 @param handler 回调
 @param priority 优先级
 @return 释放器。
 */
+ (id<AXEListenerDisposable>)registerSerialListenerForEventName:(NSString *)name
                                                        handler:(AXEEventHandlerBlock)handler
                                                       priority:(NSInteger)priority;


/**
 注册异步并发监听， 会新建一个 default优先级的gcd来执行回调。
 异步并发的监听，可以做一些比较耗时的操作，毕竟是单独的queue.
 @param name 名称
 @param handler 回调
 @return 释放器
 */
+ (id<AXEListenerDisposable>)registerConcurrentListenerForEventName:(NSString *)name
                                                            handler:(AXEEventHandlerBlock)handler;

/**
 UI事件监听。（纠结命名）
 该监听的特点是:
 1. 执行在主线程中。 供那些需要在回调中执行UI操作的任务。
 2. 与界面绑定 。UI监听会监控当前界面的状态， 如果界面不在前台，则推迟回调的执行， 直到界面重新回到前台。
 3. 当界面在后台时，对于同名的事件，只会记录和响应最后一次的数据。 保证通知内容保存最新 !!!
 @param name 名称
 @param handler 回调
 @param priority 优先级
 @param container 所在容器 , 通过协议AXEUIContainer来进行 界面切后台切换的监控。 可以直接使用util中的 AXEViewController
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
// NSNotification附带的userInfo ,以该检测转存到 AXEData中。
extern NSString *const AXEEventNotificationUserInfoKey;
