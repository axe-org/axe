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
 注册 在 axe://home/ 协议下的路径， 如果为 abc , 则路由协议为 axe://home/abc
 */
@property (nonatomic,readonly,copy) NSString *path;


/**
 已经注册的视图路由 ， 如 axe://login/register
    AXETabBarController 根据这个路由协议，去获取viewController，并进行配置。
 */
@property (nonatomic,readonly,copy) NSString *viewRoute;


/**
 实例方法
 @param path 页面路径
 @param viewRoute 视图路由
 @return 实例
 */
+ (instancetype)itemWithPath:(NSString *)path viewRoute:(NSString *)viewRoute;


+ (instancetype)new NS_UNAVAILABLE;

@end
