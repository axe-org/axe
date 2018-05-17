//
//  AXERouteProtocolDefinition.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"
#import "AXERouteRequest.h"


/**
  协议路由的定义
 */
@interface AXERouteProtocolDefinition : NSObject

// 跳转路由
+ (instancetype)defineJumpRouteForProtocol:(NSString *)protocol withRouteHandler:(AXEJumpRouteHandler)handler;

- (void)jumpForRequest:(AXERouteRequest *)request;

// 返回VC路由
+ (instancetype)defineViewRouteForProtocol:(NSString *)protocol withRouteHandler:(AXEViewRouteHandler)handler;

- (UIViewController *)viewForRequest:(AXERouteRequest *)request;

@end
