//
//  AXERouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// 回调block
typedef void (^AXERouterCallbackBlock)(NSDictionary *payload);
// 路由block
typedef void (^AXERouterBlock)(UIViewController *fromVC,NSDictionary *params,AXERouterCallbackBlock callback);
// 返回 UIViewController形式的 路由block
typedef UIViewController *(^AXERouteForVCBlock)(NSDictionary *params);
// 协议注册的路由block
typedef void (^AXEProtoclRouterBlock)(UIViewController *fromVC,NSDictionary *params,AXERouterCallbackBlock callback,NSString *sourceURL);
// 协议注册的 返回 VC形式 的路由。
typedef UIViewController *(^AXEProtoclRouteForVCBlock)(NSString *sourceURL,NSDictionary *params);
/**
  路由， 负责根据URL实现页面跳转。
 管理URL，管理模块。
 路由模块的URL标准格式是 axe://moduleName/PageName?params...

 */
@interface AXERouter : NSObject

/**
 单例

 @return 实例
 */
+ (instancetype)sharedRouter;


#pragma mark - router
/**
 路由到指定URL

 @param url url
 @param fromVC 所在页面
 @param params 传递参数
 @param block 回调。
 */
- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)fromVC withParams:(NSDictionary *)params finishBlock:(AXERouterCallbackBlock)block;


/**
  路由到指定URL

 @param url URL
 @param vc 必须要指定当前所在的ViewController， 以提高使router对应的block知道如何跳转页面。
 */
- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)vc;


/**
  直接从 URL 获取到一个新建的 ViewController.

 @param url 路由URL
 @param params 参数
 @return 返回 UIViewController， 需要注意 ， 如果路由没有注册，这里返回空值时， 要考虑崩溃处理问题。
 */
- (UIViewController *)viewControllerForRouterURL:(NSString *)url params:(NSDictionary *)params;

#pragma mark - register

/**
 注册 具体路由 在默认的 axe协议下

 @param pagePath 这里注册的pagePath，建议为 moduleName/pageName 的形式 ， 则完整的URL为 axe://moduleName/pageName
 @param block  路由处理
 */
- (void)registerPagePath:(NSString *)pagePath withRouterBlock:(AXERouterBlock)block;

/**
  注册 具体路由， 在axe协议下。
   这里使用 返回ViewController 形式的路由

 @param pagePath 页面路径
 @param block 路由处理， 返回一个 UIViewController
 */
- (void)registerPagePath:(NSString *)pagePath withRouterForVCBlock:(AXERouteForVCBlock)block;

/**
 注册 基于协议的路由。

 @param protocolName 协议名称。 默认注册的是 axe 。 可以使用这个来注册 http 等协议。
 @param block 路由处理 
 */
- (void)registerProtocol:(NSString *)protocolName withRouterBlock:(AXEProtoclRouterBlock)block;


/**
  注册 基于协议的路由

 @param protocolName 协议名称
 @param block 返回UIViewController的路由处理。
 */
- (void)registerProtocol:(NSString *)protocolName withRouteForVCBlock:(AXEProtoclRouteForVCBlock)block;

@end

// 默认protocol名称
extern NSString *AXERouterDefaultProtocolName;

