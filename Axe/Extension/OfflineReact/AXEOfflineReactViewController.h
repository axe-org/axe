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
  实现了 oprn 协议的， 离线包的 rnviewcontroller. 以加载离线包的RN页面。
 
    当前实现react-native的离线包 是针对单页面应用 ， 所以我们约定了
 1. 基于原生导航栏的多页面应用。
 2. bundle文件名为 index.bundle
 3. URL oprn://module/page  module对应的是离线包的模块， 而page 对应的是 AppRegistry注册的页面。
 */
@interface AXEOfflineReactViewController : AXEReactViewController


/**
  实例方法。
 @param path bunlde文件的相对路径，默认为 'bundle.js'
 @param moduleName 通过AppRegistry注册的模块名，
 @param offlineModule 离线包的模块名。
 @return 返回创建vc.
 */
+ (instancetype)controllerWithBundlePath:(NSString *)path
                              moduleName:(NSString *)moduleName
                         inOfflineModule:(NSString *)offlineModule;

// 离线包的模块名。
@property (nonatomic,readonly,copy) NSString *offlineModule;

/**
 注册协议为 oprn://
 一般形式的路径为 oprn://moudleA/login
 
 则实际解析的URL为 ：
 file:///path/to/module/bundle.js
 
 */
+ (void)registerOfflineReactProtocol;

@end

// oprn
extern NSString *const AXEOfflineReactProtocol;
