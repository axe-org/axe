//
//  AXEViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/21.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEViewController.h"

@implementation AXEViewController

- (instancetype)init {
    if (self = [super init]) {
        _AXEContainerStatus = [AXEEventUserInterfaceStatus status];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_didAppearBlock) {
        _didAppearBlock();
        _didAppearBlock = nil;
    }
    [_AXEContainerStatus containerDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_AXEContainerStatus containerWillDisappear];
}

- (id<AXEListenerDisposable>)registerUIEvent:(NSString *)event withHandler:(AXEEventHandlerBlock)block {
    return [AXEEvent registerUIListenerForEventName:event handler:block inUIContainer:self];
}

- (void)jumpTo:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block {
    return [[AXERouter sharedRouter] jumpTo:url fromViewController:self withParams:params finishBlock:block];
}

- (void)jumpTo:(NSString *)url {
    return [[AXERouter sharedRouter] jumpTo:url fromViewController:self];
}

@end
