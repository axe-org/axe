//
//  AXEOfflineReactViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/21.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXEReactViewController.h"


/**
  实现了 opreact 协议的， 离线包的 rnviewcontroller. 以加载离线包的RN页面。
 */
@interface AXEOfflineReactViewController : AXEReactViewController


/**
  实例方法。

 @param subpath 子路径
 @param module 模块名
 @param params 参数
 @param callback 回调
 @return 返回创建vc.
 */
+ (instancetype)controllerWithSubpath:(NSString *)subpath
                               Module:(NSString *)module
                               params:(AXEData *)params
                             callback:(AXERouterCallbackBlock)callback;

/**
 注册协议为 opreact://
 一般形式的路径为 opreact://moudleA/index.bundle?_moduleName=login
 
 对于react 页面跳转， 要求在 AXEData或者URL中标明 moduleName ， 以正确展示页面。

 */
+ (void)registerOfflineReactProtocol;
@end
