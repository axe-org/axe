//
//  AXERouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AXEData.h"


// 回调block
typedef void (^AXERouterCallbackBlock)(AXEData *payload);
// 路由block
typedef void (^AXERouterBlock)(UIViewController *fromVC,AXEData *params,AXERouterCallbackBlock callback);
// 返回 UIViewController形式的 路由block
typedef UIViewController *(^AXERouteForVCBlock)(AXEData *params,AXERouterCallbackBlock callback);
// 协议注册的路由block
typedef void (^AXEProtoclRouterBlock)(UIViewController *fromVC,AXEData *params,AXERouterCallbackBlock callback,NSString *url);
// 协议注册的 返回 VC形式 的路由。
typedef UIViewController *(^AXEProtoclRouteForVCBlock)(NSString *url,AXEData *params,AXERouterCallbackBlock callback);
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
// 路由方法， 都应该在主线程中调用。

/**
 路由到指定URL

 @param url url
 @param fromVC 所在页面
 @param params 传递参数
 @param block 回调。
 */
- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)fromVC withParams:(AXEData *)params finishBlock:(AXERouterCallbackBlock)block;


/**
  路由到指定URL

 @param url URL
 @param vc 必须要指定当前所在的ViewController， 以提高使router对应的block知道如何跳转页面。
 */
- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)vc;

// 从整个业务系统的组件化结构来说， 两种路由的区别在于，
// 前者是 模块内部实现跳转， 所以 模块知道自己是从何处开始， 所以结束时要自己处理 页面的关闭。
// 后者是 由外部控制的跳转， 所以 模块不知道自己是以何种形式弹出的， 不知道自己是在栈里 还是model形式push ， 甚至可能是直接添加到window上的。 所以页面的关闭，应该由调用者来实现，即一般情况下， 由调用者在回调函数中，设置页面的关闭操作。

// 所以 综上所诉， 两种路由对应的场景是不同的，应该这样区分 。
// 跳转路由 ： 模块内自行实现跳转逻辑 。 适用于直接页面跳转的情况，简化操作，且不建议有回调。
// Controller路由 ： 模块创建一个ViewController返回， 由调用者处理页面弹出逻辑 。 适用于有回调的情况， 由调用者完全管理页面的调用以及回调关闭页面的逻辑。 同时也适用于 组合页面，即一个页面由多个子页面组成的情况。

/**
  直接从 URL 获取到一个新建的 ViewController.

 @param url 路由URL
 @return 返回 UIViewController， 需要注意 ， 如果路由没有注册，这里返回空值时， 要考虑崩溃处理问题。
 */
- (UIViewController *)viewControllerForRouterURL:(NSString *)url;


/**
  直接从 URL 获取到一个新建的 ViewController.

 @param url 路由URL
 @param params 参数
 @param block 回调
 @return 返回 UIViewController.
 */
- (UIViewController *)viewControllerForRouterURL:(NSString *)url params:(AXEData *)params finishBlock:(AXERouterCallbackBlock)block;

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

