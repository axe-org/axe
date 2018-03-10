//
//  AXEEventListener.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEEvent.h"
#import "AXEEventUserInterfaceState.h"

@interface AXEEvent (ListenerRemoval)


/**
  当 事件没有监听时， 进行删除。
 */
+ (void)removeListenerForEventName:(NSString *)name;
@end


@class AXEEventListenerPriorityQueue;

/**
  事件监听器。
 */
@interface AXEEventListener : NSObject <AXEListenerDisposable>


/**
  回调block
 */
@property (nonatomic,copy) void (^handler)(NSDictionary *);


/**
  监听的事件名称
 */
@property (nonatomic,copy) NSString *eventName;


/**
  同步异步
 */
@property (nonatomic,assign) BOOL asynchronous;


/**
  异步的情况下， 决定是串行还是并行。
 */
@property (nonatomic,assign) BOOL serial;

/**
  优先级
 */
@property (nonatomic,assign) NSInteger priority;



/**
  使用 主线程， UI监听。
 */
@property (nonatomic,assign) BOOL useUIThread;

/**
   用于判断UI状态。 设置为 weak ， 当界面消失时， 会自动释放监听。
 */
@property (nonatomic,weak) AXEEventUserInterfaceState *containerState;

/**
  当前监听所在的队列，用于 dispose
 */
@property (nonatomic,strong) AXEEventListenerPriorityQueue *queue;

@end


/**
  优先级队列，先入先出 ， 同时使用优先级控制。
 */
@interface AXEEventListenerPriorityQueue : NSObject


- (void)insert:(AXEEventListener *)item;

- (void)delete:(AXEEventListener *)item;

/**
  根据优先级便利。

 @param block 外部设定便利任务， 这里将handler的执行，放在 AXEEvent中。
 */
- (void)enumerateListenersUsingBlock:(void (^)(AXEEventListener *obj))block;

@end

