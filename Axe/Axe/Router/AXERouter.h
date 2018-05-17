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

@class AXERouteRequest;
// 回调block
typedef void (^AXERouteCallbackBlock)(AXEData *payload);
// 跳转路由
typedef void (^AXEJumpRouteHandler)(AXERouteRequest *request);
// 视图路由
typedef UIViewController *(^AXEViewRouteHandler)(AXERouteRequest *request);
// 协议注册的跳转路由block
typedef void (^AXEProtoclJumpRouterBlock)(AXERouteRequest *request);
// 协议注册的视图路由block
typedef UIViewController *(^AXEProtoclViewRouterBlock)(AXERouteRequest *request);


/**
  路由， 负责根据URL实现页面跳转。
 路由模块的URL标准格式是 protocl://moduleName/PageName?params...
 
 路由根据表现形式，分为两种 ：
 
 * jump route : 跳转路由 ， 即 跳转到目标页面， 一般都是在 NavigationController下的push操作。
 * view route : 视图路由 ， 即 返回一个目标页面， 暂定为 ViewController 返回值。 一般用于一些特殊页面的展示，如TabBarController, tab页、侧边栏等等。
 
 路由根据协议分为两种， 一种是默认协议，即原生界面的路由， 使用默认协议 axe
 
 一种是其他协议， 通过注册协议路由实现。 在扩展中，我们的协议路由有
 
 * axes : 声明路由
 * react/reacts : 线上react-native
 * http/https: 线上h5
 * offline: 离线包 h5
 * oprn: 离线包 rn
 
 */
@interface AXERouter : NSObject

/**
 单例

 @return 实例
 */
+ (instancetype)sharedRouter;


#pragma mark - route

/**
 跳转
 路由方法， 都应该在主线程中调用。
 @param url url
 @param fromVC 当前页面 ，跳转路由必须要指定当前所在的ViewController。
 @param params 传递参数
 @param block 回调。
 */
- (void)jumpTo:(NSString *)url fromViewController:(UIViewController *)fromVC withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block;


/**
  跳转

 @param url URL
 @param fromVC 当前页面
 */
- (void)jumpTo:(NSString *)url fromViewController:(UIViewController *)fromVC;

// 视图路由与跳转路由 在跳转逻辑上有一些区别 ：
// 跳转路由是 模块内部实现跳转， 所以 模块知道自己是从何处开始， 所以结束时要自己处理 页面的关闭。
// 视图路由 是 由外部控制的界面展示， 所以 模块不知道自己是以何种形式弹出的， 不知道自己是在栈里 还是model形式push ， 甚至可能是直接添加到window上的。 所以页面的关闭，应该由调用者来实现，即一般情况下， 由调用者在回调函数中，设置页面的关闭操作。

/**
  视图路由

 @param url URL
 @return 返回 UIViewController， 需要注意 ， 如果路由没有注册，这里返回空值时， 要考虑崩溃处理问题。
 */
- (UIViewController *)viewForURL:(NSString *)url;


/**
  视图路由

 @param url 路由URL
 @param params 参数
 @param block 回调
 @return 返回 UIViewController.
 */
- (UIViewController *)viewForURL:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block;

#pragma mark - register

/**
 注册 原生页面的 跳转路由 在默认的 axe协议下

 @param path  路径，这里注册的pagePath，要求为 module/page 的形式 ， 则完整的URL为 axe://moduleName/pageName
 @param handler  路由处理
 */
- (void)registerPath:(NSString *)path withJumpRoute:(AXEJumpRouteHandler)handler;

/**
  注册 原生页面的 视图路由， 在axe协议下。

 @param path 页面路径
 @param handler 路由处理， 返回一个 UIViewController
 */
- (void)registerPath:(NSString *)path withViewRoute:(AXEViewRouteHandler)handler;

/**
 注册 基于协议的 跳转路由

 @param protocol 协议名称。
 @param handler 路由处理
 */
- (void)registerProtocol:(NSString *)protocol withJumpRoute:(AXEProtoclJumpRouterBlock)handler;


/**
  注册 基于协议的 视图路由

 @param protocol 协议名称
 @param handler 返回UIViewController的路由处理。
 */
- (void)registerProtocol:(NSString *)protocol withViewRoute:(AXEProtoclViewRouterBlock)handler;

@end

// 默认protocol名称 ， 由于不是 const ,所以这个协议名称是可以修改的。
extern NSString *AXERouterProtocolName;

