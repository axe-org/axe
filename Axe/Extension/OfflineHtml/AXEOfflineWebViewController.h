//
//  AXEOfflineWebViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/19.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEWebViewController.h"
#import "AXEOfflineDownloadView.h"

/**
  离线包的页面跳转， 采用先跳转， 再检测更新。

 */
@interface AXEOfflineWebViewController : AXEWebViewController


/**
  创建离线webviewController.

 @param subpath 指的是具体路径 , 需要注意 ， 离线包不是web服务器，不支持自动填写index.html的功能，所以路径一定要写全。
 @param module 指的是离线模块名， 即OfflinePackage中的moduleName.
 @return 创建VC
 */
+ (instancetype)webViewControllerWithSubPath:(NSString *)subpath inModule:(NSString *)module;


/**
 创建vc

 @param subpath 具体路径， 获取到本地路径后，会拼接起来，生成最终的路径
 @param module 离线模块名
 @param params 参数
 @param callback 回调
 @return 返回VC
 */
+ (instancetype)webViewControllerWithSubPath:(NSString *)subpath
                                    inModule:(NSString *)module
                                      params:(AXEData *)params
                                    callback:(AXERouterCallbackBlock)callback;



/**
  注册 UIWebview 用于处理离线的网页请求。
 注册的协议为 ophttp://
 */
+ (void)registerUIWebVIewForOfflineHtml;

@end
