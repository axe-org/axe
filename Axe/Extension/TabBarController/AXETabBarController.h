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
  根据配置，创建实例。

 @return <#return value description#>
 */
+ (instancetype)TabBarController;

@end

// 在初始化时，发送这个通知， 建议将初始化放在  AXEEventModulesBeginInitializing 之前，以提前初始化首页必须的 业务组件。
extern NSString *const AXEEventTabBarModuleInitializing;

// 默认protocol名称 , home://
extern NSString *AXETabBarRouterDefaultProtocolName;

