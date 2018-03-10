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
#import "AXEDefines.h"

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
        [instance setupDefaultUIEvent];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
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
    NSParameterAssert([container performSelector:@selector(AXEContainerState)]);
    
    AXEEventListener *listener = [[AXEEventListener alloc] init];
    listener.eventName = name;
    listener.handler = handler;
    listener.priority = priority;
    listener.asynchronous = YES;
    listener.useUIThread = YES;
    listener.containerState = container.AXEContainerState;
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
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    
    [[AXEEvent sharedInstance] dispatchEventName:name userInfo:nil];
}

+ (void)postEventName:(NSString *)name userInfo:(NSDictionary *)userInfo {
    NSParameterAssert([name isKindOfClass:[NSString class]]);
    NSParameterAssert(!userInfo || [userInfo isKindOfClass:[NSDictionary class]]);
    
    [[AXEEvent sharedInstance] dispatchEventName:name userInfo:userInfo];
}

- (void)dispatchEventName:(NSString *)name userInfo:(NSDictionary *)userInfo {
    AXEEventListenerPriorityQueue *listeners = _listeners[name];
    if (listeners) {
        AXELogTrace(@"发送事件 %@ 。" , name);
        NSMutableArray *asyncListeners = [[NSMutableArray alloc] init];
        [listeners enumerateListenersUsingBlock:^(AXEEventListener *listener) {
            if (listener.useUIThread) {
                // 要在主线程中执行。
                if (!listener.containerState) {
                    // 如果state不存在，表示UI被释放，则取消监听.
                    [listener dispose];
                }else {
                    // UI线程事件处理。
                    dispatch_block_t block= ^{
                        listener.handler(userInfo);
                    };
                    if (listener.containerState.inFront) {
                        dispatch_async(dispatch_get_main_queue(), block);
                    }else {
                        [listener.containerState storeEventName:listener.eventName handlerBlock:block];
                    }
                }
            }else if (!listener.asynchronous) {
                // 同步执行。
                listener.handler(userInfo);
            }else {
                // 异步执行。
                if (listener.serial) {
                    // 序列执行先记录一下。
                    [asyncListeners addObject:listeners];
                }else {
                    dispatch_async(_concurrentQueue, ^{
                        listener.handler(userInfo);
                    });
                }
            }
        }];
        if (asyncListeners.count) {
            dispatch_queue_t queue = [self getSerailQueue];
            dispatch_async(queue, ^{
                [asyncListeners enumerateObjectsUsingBlock:^(AXEEventListener *listener, NSUInteger idx, BOOL * _Nonnull stop) {
                    listener.handler(userInfo);
                }];
            });
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
    
    [[NSNotificationCenter defaultCenter] addObserver:[AXEEvent sharedInstance]
                                             selector:@selector(dispatchNotification:)
                                                 name:notificationName
                                               object:nil];
}

- (void)dispatchNotification:(NSNotification *)notification {
    [[AXEEvent sharedInstance] dispatchEventName:notification.name userInfo:notification.userInfo];
}

- (void)setupDefaultUIEvent {
    [AXEEvent translateNotification:UIApplicationDidEnterBackgroundNotification];
    [AXEEvent translateNotification:UIApplicationWillEnterForegroundNotification];
    [AXEEvent translateNotification:UIApplicationDidBecomeActiveNotification];
    [AXEEvent translateNotification:UIApplicationWillResignActiveNotification];
    [AXEEvent translateNotification:UIApplicationWillTerminateNotification];
}
@end



