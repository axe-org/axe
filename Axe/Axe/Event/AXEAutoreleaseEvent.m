//
//  AXEAutoreleaseEvent.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEAutoreleaseEvent.h"

@implementation AXEAutoreleaseEvent

+ (id<AXEListenerDisposable>)registerListenerForEventName:(NSString *)name
                                                  handler:(AXEEventHandlerBlock)handler {
    return [self registerSyncListenerForEventName:name
                                          handler:handler
                                         priority:AXEEventDefaultPriority];
}


+ (id<AXEListenerDisposable>)registerSyncListenerForEventName:(NSString *)name
                                                      handler:(AXEEventHandlerBlock)handler
                                                     priority:(NSInteger)priority {
    id<AXEListenerDisposable> disposable;
    AXEEventHandlerBlock internalHandler = [handler copy];
    disposable = [AXEEvent registerSyncListenerForEventName:name handler:^(AXEData *info) {
        internalHandler(info);
        [disposable dispose];
    } priority:priority];
    return disposable;
}



+ (id<AXEListenerDisposable>)registerAsyncListenerForEventName:(NSString *)name
                                                       handler:(AXEEventHandlerBlock)handler
                                                      priority:(NSInteger)priority
                                                 inSerialQueue:(BOOL)isSerial {
    id<AXEListenerDisposable> disposable;
    AXEEventHandlerBlock internalHandler = [handler copy];
    disposable = [AXEEvent registerAsyncListenerForEventName:name handler:^(AXEData *info) {
        internalHandler(info);
        [disposable dispose];
    } priority:priority inSerialQueue:isSerial];
    return disposable;
}


+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                                   priority:(NSInteger)priority
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container {
    id<AXEListenerDisposable> disposable;
    AXEEventHandlerBlock internalHandler = [handler copy];
    disposable = [AXEEvent registerUIListenerForEventName:name handler:^(AXEData *info) {
        internalHandler(info);
        [disposable dispose];
    } priority:priority inUIContainer:container];
    return disposable;
}

/**
 注册监听，使用默认优先级。
 */
+ (id<AXEListenerDisposable>)registerUIListenerForEventName:(NSString *)name
                                                    handler:(AXEEventHandlerBlock)handler
                                              inUIContainer:(id<AXEEventUserInterfaceContainer>)container {
    return [self registerUIListenerForEventName:name
                                        handler:handler
                                       priority:AXEEventDefaultPriority
                                  inUIContainer:container];
}

@end
