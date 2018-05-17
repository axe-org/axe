//
//  AXEOfflineWKWebViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/19.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEWKWebViewController.h"


/**
  使用 wkwebview实现的离线包的 webviewController.
 
 我们推荐使用单页面应用 ：
 1.是单页面应用， 使用router， 页面通过 #/page 访问。
 2.固定页面入口为 index.html文件， 放在根目录下。
 */
@interface AXEOfflineWKWebViewController : AXEWKWebViewController


/**
 创建离线webviewController
 
 @param path 入口文件， 固定为 index.html
 @param page 页面. 设置表示使用 #/page，通过路由访问具体页面。
 @param module 离线包模块。
 */
+ (instancetype)webViewControllerWithFilePath:(NSString *)path
                                         page:(NSString *)page
                                     inModule:(NSString *)module;



/**
 注册 UIWebview 用于处理离线的网页请求。 该实现 只支持单页面应用
 注册的协议为 ophttp://moduleName/pageName
 解析后 ， 通过 file:///path/to/index.html#/pageName 来访问页面。
 */
+ (void)registerWKWebVIewForOfflineHtml;

@end
