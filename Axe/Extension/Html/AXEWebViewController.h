//
//  AXEWebViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AXERouter.h"
#import "AXEViewController.h"
// 使用 WebViewJavascriptBridge 作为桥接
@class WebViewJavascriptBridge;

// 对于 H5默认路由， 关于回调的注意事项 。
// 参考 AXERouter.h中对于路由的描述 ,已知， 对于 跳转路由 ，回调时的界面关闭由 被调用者 实现， 对于 页面路由 ，界面关闭由调用者管理。
// 所以， 在 h5 默认实现中， 对于 jump route 带有回调时， js 正常调用回调接口即可， 页面关闭由 AXEWebViewController 实现了。

/**
  WebView容器， 使用 UIWebView
 */
@interface AXEWebViewController : AXEViewController


/**
  创建实例

 @param url url
 @return 实例
 */
+ (instancetype)webViewControllerWithURL:(NSString *)url;

/**
    需要注意的是 ，这个webview使用webviewJSBridge设置了delegate ,所以不能直接设置delegate， 请使用下面的 webViewDelegate属性。
 */
@property (nonatomic,readonly,strong) UIWebView *webView;

/**
  js bridge 。 通过WebViewJavascriptBridge来注册自己的插件，供h5调用.
 */
@property (nonatomic,readonly,strong) WebViewJavascriptBridge *javascriptBridge;

/**
  设置webView代理 .
 */
@property (nonatomic,weak) id<UIWebViewDelegate> webViewDelegate;


/**
  定制AXEWebViewController.
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEWebViewController *))block;

#pragma mark - router


/**
 注册 http协议， 使用UIWebView处理。
 */
+ (void)registerUIWebViewForHTTP;


/**
 注册 https协议 ， 使用UIWebView处理。
 */
+ (void)registerUIWebViewForHTTPS;


@end


