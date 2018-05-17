//
//  AXERouteDefinition.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouteDefinition.h"

@interface AXERouteDefinition()

@property (nonatomic,copy) NSString *path;

@property (nonatomic,copy) AXEJumpRouteHandler jumpHandler;

@property (nonatomic,copy) AXEViewRouteHandler viewHandler;
// 简单的统计。。
@property (nonatomic,assign) NSInteger routeCount;
@end

@implementation AXERouteDefinition


+ (instancetype)defineJumpRouteForPath:(NSString *)path withRouteHandler:(AXEJumpRouteHandler)handler; {
    AXERouteDefinition *definition = [[AXERouteDefinition alloc] init];
    definition.routeCount = 0;
    definition.path = path;
    definition.jumpHandler = handler;
    return definition;
}

- (void)jumpForRequest:(AXERouteRequest *)request {
    _routeCount ++ ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_jumpHandler(request);
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@://%@>" , _jumpHandler ? @"JumpRoute" : @"ViewRoute", AXERouterProtocolName , _path];
}


+ (instancetype)defineViewRouteForPath:(NSString *)path withRouteHandler:(AXEViewRouteHandler)handler {
    AXERouteDefinition *definition = [[AXERouteDefinition alloc] init];
    definition.routeCount = 0;
    definition.path = path;
    definition.viewHandler = handler;
    return definition;
}

- (UIViewController *)viewForRequest:(AXERouteRequest *)request {
    _routeCount ++;
    return _viewHandler(request);
}

@end
