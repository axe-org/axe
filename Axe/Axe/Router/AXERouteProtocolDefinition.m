//
//  AXERouteProtocolDefinition.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouteProtocolDefinition.h"

@interface AXERouteProtocolDefinition()

@property (nonatomic,copy) NSString *protocol;

@property (nonatomic,copy) AXEJumpRouteHandler jumpHandler;

@property (nonatomic,copy) AXEViewRouteHandler viewHandler;

@property (nonatomic,assign) NSInteger routeCount;

@end

@implementation AXERouteProtocolDefinition

+ (instancetype)defineJumpRouteForProtocol:(NSString *)protocol withRouteHandler:(AXEJumpRouteHandler)handler {
    AXERouteProtocolDefinition *definition = [[AXERouteProtocolDefinition alloc] init];
    definition.routeCount = 0;
    definition.protocol = protocol;
    definition.jumpHandler = handler;
    return definition;
}

- (void)jumpForRequest:(AXERouteRequest *)request {
    _routeCount ++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_jumpHandler(request);
    });
}

// 返回VC路由
+ (instancetype)defineViewRouteForProtocol:(NSString *)protocol withRouteHandler:(AXEViewRouteHandler)handler {
    AXERouteProtocolDefinition *definition = [[AXERouteProtocolDefinition alloc] init];
    definition.routeCount = 0;
    definition.protocol = protocol;
    definition.viewHandler = handler;
    return definition;
}

- (UIViewController *)viewForRequest:(AXERouteRequest *)request {
    _routeCount ++;
    return _viewHandler(request);
}

@end
