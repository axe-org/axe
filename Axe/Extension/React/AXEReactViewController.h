//
//  AXEReactViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXERouter.h"
#import "AXEEventUserInterfaceState.h"
#import "AXEViewController.h"

@class RCTRootView;

/**
  React Native 的 VC 基类， 提供了默认的 路由实现，同时为react 提供了 axe 三大组件的支持。
    需要注意，我们推荐 使用基于原生导航栏的多页面应用。
 */
@interface AXEReactViewController : AXEViewController

/**
 设置回调， 在ViewDidLoad时执行， 以定制AXEReactViewController
 
 @param block 定制。
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEReactViewController *))block;

/**
 创建viewController
 我们推荐使用 多页面应用
 @param url URL
 @param moduleName AppRegistry中注册的模块名。
 */
+ (instancetype)controllerWithURL:(NSString *)url moduleName:(NSString *)moduleName;

@property (nonatomic,readonly,copy) NSString *url;
@property (nonatomic,readonly,copy) NSString *page;


/**
  RCTRootView
 */
@property (nonatomic,readonly) RCTRootView *rctRootView;


/**
  为 react native 注册 react 协议。 适用的URL形式为：
 react://localhost:8081/index.bundle?platform=ios&module=login
  对于react 页面跳转， 要求在 AXEData或者URL中标明 module ， 以加载具体页面
  而实际的请求路径是将 react -> http , reacts -> https.
 */
+ (void)registerReactProtocol;



/**
  注册 reacts 协议， 实际访问 https.
 */
+ (void)registerReactsProtocol;


/**
  创建RCTRootView ,并加载页面
 */
- (void)loadReactWithBundleURL:(NSString *)urlStr moduleName:(NSString *)moduleName;

@end

/// 对于react 页面跳转， 要求在 AXEData或者URL中标明 pageName ， 以正确展示页面。 key值为page
extern NSString *const AXEReactPageNameKey;
// 对于单页面应用， 默认的 AppRegistry中注册的 moduleName必须为 'App'
extern NSString *const AXEDefaultModuleName;
// react
extern NSString *const AXEReactHttpProtocol;
// reacts
extern NSString *const AXEReactHttpsProtocol;
