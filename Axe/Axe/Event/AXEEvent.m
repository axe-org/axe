//
//  AXEEvent.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEEvent.h"
#import "AXEEventListener.h"
#import "AXEEventUserInterfaceState+Event.h"
#import "AXELog.h"

NSInteger const AXEEventDefaultPriority = 1;

@interface AXEEvent()

// 串行回调，目前提供两个队列执行.
@property (nonatomic,strong) dispatch_queue_t serialQueueA;
@property (nonatomic,strong) dispatch_queue_t serialQueueB;
@property (nonatomic,assign) BOOL chooseQueueA;
@property (nonatomic,strong) dispatch_semaphore_t queueSemaphore;

@property (nonatomic,strong) dispatch_queue_t concurrentQueue;

@property (nonatomic,strong) NSMutableDictionary<NSString *,AXEEventListenerPriorityQueue *> *listeners;

@end

@implementation AXEEvent



+ (AXEEvent *)sharedInstance {
    static AXEEvent *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AXEEvent alloc] init];
        [instance translateDefaultEvents];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 这里，我们创建了两个序列化的队列，简单地优化一下序列执行，即事件监听会分配到两个队列中，避免一个任务造成的堵塞。
        _serialQueueA = dispatch_queue_create("org.axe.event.serail_queue_a", DISPATCH_QUEUE_SERIAL);
        _serialQueueB = dispatch_queue_create("org.axe.event.serail_queue_b", DISPATCH_QUEUE_SERIAL);
        _chooseQueueA = YES;
        _queueSemaphore = dispatch_semaphore_create(1);
        _concurrentQueue = dispatch_queue_create("org.axe.event.concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
        _listeners = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return self;
}

#pragma mark - register
+ (id<AXEListenerDisposable>)registerListenerForEventName:(NSString *)name
                                                  handler:(AXEEventHandlerBlock)handler {
    return [self registerSyncListenerForEventName:name handler:handler priority:AXEEventDefaultPriority];
}


+ (id<AXEListenerDisposable>)registerSyncListenerForEventName:(NSString *)name
                                                      handler:(AXEEventHandlerBlock)handler
                                                     priority:(NSInteger)priority {
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    
    AXEEventListener *listener = [[AXEEventListener alloc] init];
    listener.eventName = name;
    listener.handler = handler;
    listener.priority = priority;
    listener.asynchronous = NO;
    [[AXEEvent sharedInstance] addListener:listener];
    return listener;
}

+ (id<AXEListenerDisposable>)registerAsyncListenerForEventName:(NSString *)name
                                                       handler:(AXEEventHandlerBlock)handler
                                                      priority:(NSInteger)priority
                                                 inSerialQueue:(BOOL)isSerial {
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    
    AXEEventListener *listener = [[AXEEventListener alloc] init];
    listener.eventName = name;
    listener.handler = handler;
    listener.priority = priority;
    listener.asynchronous = YES;
    listener.serial = isSerial;
    [[AXEEvent sharedInstance] addListener:listener];
    return listener;
}


+ (id<AXEListenerDisposable>)registerSerialListenerForEventName:(NSString *)name
                                                        handler:(AXEEventHandlerBlock)handler
                                                       priority:(NSInteger)priority {
    return [self registerAsyncListenerForEventName:name handler:handler priority:priority inSerialQueue:YES];
}


+ (id<AXEListenerDisposable>)registerConcurrentListenerForEventName:(NSString *)name
                                                            handler:(AXEEventHandlerBlock)handler {
    return [self registerAsyncListenerForEventName:name handler:handler priority:AXEEventDefaultPriority inSerialQueue:NO];
}

+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container {
    return [self registerUIListenerForEventName:name
                                        handler:handler
                                       priority:AXEEventDefaultPriority
                                  inUIContainer:container];
}

+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                                   priority:(NSInteger)priority
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container {
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    NSParameterAssert([container performSelector:@selector(AXEContainerStatus)]);
    
    AXEEventListener *listener = [[AXEEventListener alloc] init];
    listener.eventName = name;
    listener.handler = handler;
    listener.priority = priority;
    listener.asynchronous = YES;
    listener.userInterface = YES;
    listener.containerStatus = container.AXEContainerStatus;
    [[AXEEvent sharedInstance] addListener:listener];
    return listener;
}


- (void)addListener:(AXEEventListener *)listener {
    @synchronized(self) {
        AXEEventListenerPriorityQueue *queue;
        queue = _listeners[listener.eventName];
        if (!queue) {
            queue = [[AXEEventListenerPriorityQueue alloc] init];
            _listeners[listener.eventName] = queue;
        }
        [queue insert:listener];
        listener.queue = queue;
    }
}

+ (void)removeListenerForEventName:(NSString *)name {
    AXEEvent *event = [AXEEvent sharedInstance];
    @synchronized(event) {
        [event.listeners removeObjectForKey:name];
    }
}

#pragma mark - post

+ (void)postEventName:(NSString *)name {
    return [AXEEvent postEventName:name withPayload:nil];
}

+ (void)postEventName:(NSString *)name withPayload:(AXEData *)payload {
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    NSParameterAssert(!payload || [payload isKindOfClass:[AXEData class]]);
    
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(eventWillPost:withPayload:)]) {
        [tracker eventWillPost:name withPayload:payload];
    }
    
    [[AXEEvent sharedInstance] dispatchEventName:name withPayload:payload];
}

- (void)dispatchEventName:(NSString *)name withPayload:(AXEData *)payload {
    AXEEventListenerPriorityQueue *listeners = _listeners[name];
    AXELogTrace(@"发送事件 %@ 。" , name);
    if (listeners) {
        NSMutableArray *asyncListeners = [[NSMutableArray alloc] init];
        NSMutableArray *syncListeners = [[NSMutableArray alloc] init];
        [listeners enumerateListenersUsingBlock:^(AXEEventListener *listener) {
            if (listener.userInterface) {
                // 要在主线程中执行。
                if (!listener.containerStatus) {
                    // 如果state不存在，表示UI被释放，则取消监听.
                    [listener dispose];
                }else {
                    // UI线程事件处理。
                    dispatch_block_t block= ^{
                        listener.handler(payload);
                    };
                    if (listener.containerStatus.inFront) {
                        dispatch_async(dispatch_get_main_queue(), block);
                    }else {
                        [listener.containerStatus storeEventName:listener.eventName handlerBlock:block];
                    }
                }
            }else if (!listener.asynchronous) {
                [syncListeners addObject:listener];
            }else {
                // 异步执行。
                if (listener.serial) {
                    // 序列执行先记录一下。
                    [asyncListeners addObject:listener];
                }else {
                    // 并发执行
                    dispatch_async(self->_concurrentQueue, ^{
                        listener.handler(payload);
                    });
                }
            }
        }];
        // 先调用好异步任务
        if (asyncListeners.count) {
            dispatch_queue_t queue = [self getSerailQueue];
            dispatch_async(queue, ^{
                [asyncListeners enumerateObjectsUsingBlock:^(AXEEventListener *listener, NSUInteger idx, BOOL * _Nonnull stop) {
                    listener.handler(payload);
                }];
            });
        }
        //然后才执行同步任务
        if (syncListeners.count) {
            [syncListeners enumerateObjectsUsingBlock:^(AXEEventListener *listener, NSUInteger idx, BOOL * _Nonnull stop) {
                listener.handler(payload);
            }];
        }
    }
}



- (dispatch_queue_t)getSerailQueue {
    dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_queue_t queue = _chooseQueueA ? _serialQueueA : _serialQueueB;
    _chooseQueueA = !_chooseQueueA;
    dispatch_semaphore_signal(_queueSemaphore);
    return queue;
}

#pragma mark - Notification Translate

+ (void)translateNotification:(NSString *)notificationName {
    NSParameterAssert([notificationName isKindOfClass:[NSString class]]);
    
    [[AXEEvent sharedInstance] translateNotification:notificationName];
}

- (void)translateNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dispatchNotification:)
                                                 name:notificationName
                                               object:nil];
}


- (void)dispatchNotification:(NSNotification *)notification {
    AXEData *data;
    if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        data = [AXEData dataForTransmission];
        [data setData:notification.userInfo forKey:AXEEventNotificationUserInfoKey];
    }
    [[AXEEvent sharedInstance] dispatchEventName:notification.name withPayload:data];
}

- (void)translateDefaultEvents {
    [self translateNotification:UIApplicationDidEnterBackgroundNotification];
    [self translateNotification:UIApplicationWillEnterForegroundNotification];
    [self translateNotification:UIApplicationDidBecomeActiveNotification];
    [self translateNotification:UIApplicationWillResignActiveNotification];
    [self translateNotification:UIApplicationWillTerminateNotification];
}
@end

NSString *const AXEEventNotificationUserInfoKey = @"userInfo";

