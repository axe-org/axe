//
//  UIViewController+AXERouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"



@interface UIViewController(AXERouter)

/**
 路由到指定URL
 
 @param url url
 @param params 传递参数
 @param block 回调。
 */
- (void)routeURL:(NSString *)url withParams:(NSDictionary *)params finishBlock:(AXERouterCallbackBlock)block;


/**
 路由到指定URL
 
 @param url URL
 */
- (void)routeURL:(NSString *)url;



@end
