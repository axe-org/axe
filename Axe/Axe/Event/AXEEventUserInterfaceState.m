//
//  AXEEventUserInterfaceStatus.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEEventUserInterfaceState.h"
#import "AXEEvent.h"
#import "AXEEventUserInterfaceState+Event.h"
#import "AXELog.h"


/**
  本地存储的事件回调。
 */
@interface AXEEventStoredEventHandler : NSObject

@property (nonatomic,copy) NSString *eventName;
@property (nonatomic,copy) dispatch_block_t handler;
@end
@implementation AXEEventStoredEventHandler
@end

@interface AXEEventUserInterfaceStatus()
@property (nonatomic,strong) NSMutableArray<AXEEventStoredEventHandler *> *storedBlocks;
@end

@implementation AXEEventUserInterfaceStatus

+ (instancetype)status {
    return [[AXEEventUserInterfaceStatus alloc] init];
}

- (void)containerWillDisappear {
    @synchronized(self) {
        _inFront = NO;
    }
}


- (void)containerDidAppear {
    @synchronized(self) {
        _inFront = YES;
        if (_storedBlocks.count) {
            // 如果当前有存储任务，则执行。
            NSArray<AXEEventStoredEventHandler *> *storedBlocks = _storedBlocks;
            _storedBlocks = [[NSMutableArray alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [storedBlocks enumerateObjectsUsingBlock:^(AXEEventStoredEventHandler * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    AXELogTrace(@"页面回到前台，发送事件 %@",obj.eventName);
                    obj.handler();
                }];
            });
        }
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _inFront = YES;
    }
    return self;
}

- (void)storeEventName:(NSString *)name handlerBlock:(dispatch_block_t)block {
    // 既要保持事件发送顺序，又要覆盖同名事件。
    @synchronized(self) {
        if (!_storedBlocks) {
            _storedBlocks = [[NSMutableArray alloc] init];
        }
        for (AXEEventStoredEventHandler *item in _storedBlocks) {
            if ([item.eventName isEqualToString:name]) {
                [_storedBlocks removeObject:item];
                break;
            }
        }
        AXEEventStoredEventHandler *stored = [[AXEEventStoredEventHandler alloc] init];
        stored.eventName = name;
        stored.handler = block;
        [_storedBlocks addObject:stored];
    }
}

- (void)cleanStoredEvents {
    @synchronized(self) {
        _storedBlocks = nil;
    }
}

@end
