//
//  AXETabBarItem.h
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
  记录 子项的相关数据 , 以供 AXETabBarController 配置相关界面和属性。
 */
@interface AXETabBarItem : NSObject


/**
  标题， 可为空
 */
@property (nonatomic,copy) NSString *title;


/**
  图标 , 可能为空
 */
@property (nonatomic,strong) UIImage *normalIcon;


/**
  选中时图标。
 */
@property (nonatomic,strong) UIImage *selectedIcon;



/**
 注册 在 home:// 协议下的路径， 如果为 abc , 则路由协议为 home://abc
 */
@property (nonatomic,readonly,copy) NSString *pagePath;


/**
 已经注册在 axe://协议下的获取 viewController的协议地址 ， 如 axe://login/main
    AXETabBarController 根据这个路由协议，去创建viewController，并进行配置。
 */
@property (nonatomic,readonly,copy) NSString *vcRouteURL;


/**
 实例方法

 @param pagePath <#pagePath description#>
 @param routeURL <#routeURL description#>
 @return <#return value description#>
 */
+ (instancetype)itemWithPagePath:(NSString *)pagePath routURL:(NSString *)routeURL;


+ (instancetype)new NS_UNAVAILABLE;

@end
