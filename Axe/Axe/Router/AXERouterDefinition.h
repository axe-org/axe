//
//  AXERouterDefinition.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"

/**
  路由的配置。 每个配置生成一个definition.
 */
@interface AXERouterDefinition : NSObject

// 路由跳转的定义
+ (instancetype)definitionWithPagePath:(NSString *)path block:(AXERouterBlock)block;

- (void)excuteWithFromVC:(UIViewController *)fromVC
                  params:(AXEData *)params
           callbackBlock:(AXERouterCallbackBlock)callbackBlock;

// 返回ViewController的路由定义
+ (instancetype)definitionWithPagePath:(NSString *)path routeForVCBlock:(AXERouteForVCBlock)block;

- (UIViewController *)getViewControllerWithParams:(AXEData *)params;


@end
