//
//  AXETabBarController.h
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AXETabBarItem.h"



/**
  基于Axe ， 实现简单的TabBarController路由
 这里是放置于首页的tabbarController 。 所以默认注册协议 home://
  所有首页的ViewController 必须包含在 UINavigationController中！！！
 TODO 处理 离线包形式的特殊页面， 要求设置特殊参数。
 */
@interface AXETabBarController : UITabBarController

/**
  注册一个子项。 注意 tarbar的子界面的顺序，由注册的顺序决定。

 @param barItem 详细配置
 */
+ (void)registerTabBarItem:(AXETabBarItem *)barItem;


/**
  在viewDidLoad时，回调该block， 以再做一些barItem的定制化

 @param block 定制block
 */
+ (void)setCustomDecorateBlock:(void (^)(AXETabBarController *))block;


/**
  设置 navigationController 基类。
   对于所有返回值， 如果返回的是  UINavigationControlller ,则直接设置，
   否则， 通过该类型， 调用 -initWithRootViewController: 方法来创建一个导航栈。
 @param cls <#cls description#>
 */
+ (void)setNavigationControllerClass:(Class)cls;

/**
  根据配置，创建实例。
  不是单例， 这是一个工厂函数。
 @return <#return value description#>
 */
+ (instancetype)TabBarController;

@end

// 在初始化时，发送这个通知， 建议将初始化放在  AXEEventModulesBeginInitializing 之前，以提前初始化首页必须的 业务组件。
extern NSString *const AXEEventTabBarModuleInitializing;

// 默认protocol名称 , home://
extern NSString *AXETabBarRouterDefaultProtocolName;
// 对于所有通过 tabbar注册的 路由， 发送一个 data ，key 为AXETabBarRouteFlagKey ， 值为当前页面所在index.
extern NSString *const AXETabBarRouteFlagKey;
