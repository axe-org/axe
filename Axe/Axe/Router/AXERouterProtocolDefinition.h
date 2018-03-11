//
//  AXERouterProtocolDefinition.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"


/**
  协议路由的定义
 */
@interface AXERouterProtocolDefinition : NSObject

// 跳转路由
+ (instancetype)definitionWithProtocol:(NSString *)protocol block:(AXEProtoclRouterBlock)block;

- (void)excuteWithFromVC:(UIViewController *)fromVC
                  params:(AXEData *)params
           callbackBlock:(AXERouterCallbackBlock)callbackBlock
               sourceURL:(NSString *)sourceURL;

// 返回VC路由
+ (instancetype)definitionWithProtocol:(NSString *)protocol routeForVCBlock:(AXEProtoclRouteForVCBlock)block;

- (UIViewController *)getViewControllerWithParams:(AXEData *)params
                                        sourceURL:(NSString *)sourceURL;

@end
