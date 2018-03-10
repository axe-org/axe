//
//  AXEEventUserInterfaceState.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEEventUserInterfaceState.h"
#import "AXEEvent.h"
#import "AXEEventUserInterfaceState+Event.h"
#import "AXEDefines.h"

@interface AXEEventUserInterfaceState()
@property (nonatomic,strong) NSMutableDictionary<NSString *,dispatch_block_t> *storedBlocks;
@end

@implementation AXEEventUserInterfaceState

+ (instancetype)state {
    return [[AXEEventUserInterfaceState alloc] init];
}

- (void)containerWillDisappear {
    @synchronized(self) {
        _inFront = NO;
    }
}


- (void)containerWillAppear {
    @synchronized(self) {
        _inFront = YES;
        if (_storedBlocks.count) {
            // 如果当前有存储任务，则执行。
            NSMutableDictionary<NSString *,dispatch_block_t> *storedBlocks = _storedBlocks;
            _storedBlocks = [[NSMutableDictionary alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [storedBlocks enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull eventName, dispatch_block_t  _Nonnull block, BOOL * _Nonnull stop) {
                    AXELogTrace(@"页面回到前台，发送事件 %@",eventName);
                    block();
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
    @synchronized(self) {
        if (!_storedBlocks) {
            _storedBlocks = [[NSMutableDictionary alloc] init];
        }
        [_storedBlocks setObject:[block copy] forKey:name];
    }
}

- (void)cleanStoredEvents {
    @synchronized(self) {
        _storedBlocks = nil;
    }
}

@end
