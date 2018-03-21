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

@class RCTRootView;

/**
  React Native 的 VC 基类， 提供了默认的 路由实现，同时为react 提供了 axe 三大组件的使用。
 
 */
@interface AXEReactViewController : UIViewController<AXEEventUserInterfaceContainer>


/**
 设置回调， 在ViewDidLoad时执行， 以定制AXEReactViewController
 
 @param block 定制。
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEReactViewController *))block;

/**
  实例方法

 @param url url
 @param params 参数
 @param callback 回调。
 @return controller.
 */
+ (instancetype)controllerWithURL:(NSString *)url params:(AXEData *)params callback:(AXERouterCallbackBlock)callback;



/**
  需要注意， 如果一开始没有传入 , 则在viewDidLoad时，rctRootView为空。
  之后再设置 URL时，要正确设置rctRootView.
 */
@property (nonatomic,strong) RCTRootView *rctRootView;



/**
  为 react native 注册 react 协议。 即对于
 react://localhost:8081/index.bundle?platform=ios&_moduleName=login
  对于react 页面跳转， 要求在 AXEData或者URL中标明 moduleName ， 以正确展示页面。
  而实际的请求路径是将 react -> http , reacts -> https.
 */
+ (void)registerReactProtocol;



/**
  注册 reacts 协议， 实际访问 https.
 */
+ (void)registerReactsProtocol;

@end

/// 对于react 页面跳转， 要求在 AXEData或者URL中标明 moduleName ， 以正确展示页面。 key值为_moduleName
extern NSString *const AXEReactModuleNameKey;
