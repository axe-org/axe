//
//  AXERouteDefinition.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"
#import "AXERouteRequest.h"

/**
  路由的配置。 每个配置生成一个definition.
 */
@interface AXERouteDefinition : NSObject

// 跳转路由的定义
+ (instancetype)defineJumpRouteForPath:(NSString *)path withRouteHandler:(AXEJumpRouteHandler)handler;

- (void)jumpForRequest:(AXERouteRequest *)request;

// 视图路由的定义
+ (instancetype)defineViewRouteForPath:(NSString *)path withRouteHandler:(AXEViewRouteHandler)handler;

- (UIViewController *)viewForRequest:(AXERouteRequest *)request;


@end
