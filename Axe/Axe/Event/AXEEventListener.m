//
//  AXEEventListener.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEEventListener.h"
#import "AXEEventUserInterfaceState+Event.h"

@implementation AXEEventListener

- (void)dispose {
    [_queue delete:self];
    if (_containerState) {
        [_containerState cleanStoredEvents];
    }
}

@end


@interface AXEEventListenerPriorityQueue ()


/**
  使用数组实现队列功能
 */
@property (nonatomic,strong) NSMutableArray<AXEEventListener *> *list;
@end


@implementation AXEEventListenerPriorityQueue

- (instancetype)init {
    if (self = [super init]) {
        _list = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insert:(AXEEventListener *)item {
    @synchronized(_list) {
        NSInteger index = 0;
        for (AXEEventListener *last in _list) {
            if (last.priority < item.priority) {
                break;
            }
            index ++;
        }
        [_list insertObject:item atIndex:index];
    }
}

- (void)delete:(AXEEventListener *)item {
    @synchronized(_list) {
        [_list removeObject:item];
    }
    if (_list.count == 0) {
        [AXEEvent removeListenerForEventName:item.eventName];
    }
}

- (void)enumerateListenersUsingBlock:(void (^)(AXEEventListener *))block {
    NSArray<AXEEventListener *> *list;
    @synchronized(_list) {
        list = [_list copy];
    }
    [list enumerateObjectsUsingBlock:^(AXEEventListener * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

@end
