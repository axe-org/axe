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
 这里是放置于首页的tabbarController 。 所以默认注册协议 axe://home/page
  所有首页的ViewController 都包含在 UINavigationController中！！！
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
   设置该类型， 调用 -initWithRootViewController: 方法来创建指定类型的 NavigationController类的实例。
 @param cls navigationController基类
 */
+ (void)setNavigationControllerClass:(Class)cls;

/**
  单例。
 */
+ (instancetype)sharedTabBarController;

// 跳回到首页具体 index的页面。
- (void)backToIndex:(NSInteger)index fromViewController:(UIViewController *)fromVC;
@end

// 默认protocol名称 , home
extern NSString *AXETabBarRouterDefaultProtocolName;

// 注册的路由会附带两个参数
// index ，从0开始
extern NSString *const AXETabBarRouterIndexKey;
// path , 指 AXETabBarItem.pagePath
extern NSString *const AXETabBarRouterPathKey;;
