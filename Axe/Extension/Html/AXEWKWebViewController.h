//
//  AXEWKWebViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AXERouter.h"
#import "AXEViewController.h"
// 使用WebViewJavascriptBridge 作为桥接。
@class WKWebViewJavascriptBridge;

/**
  使用 WKWebView展示网页
  推荐使用 WKWebView， 性能更好。
 */
@interface AXEWKWebViewController : AXEViewController

/**
 创建实例
 
 @param url url
 @return 实例
 */
+ (instancetype)webViewControllerWithURL:(NSString *)url;


/**
 需要注意的是 ，这个webview使用webviewJSBridge设置了delegate , 所以不能直接设置delegate， 请使用下面的 webViewDelegate属性。
 */
@property (nonatomic,strong,readonly) WKWebView *webView;


/**
 js bridge 。 通过这个来注册自己的插件，供h5调用.
 */
@property (nonatomic,readonly,strong) WKWebViewJavascriptBridge *javascriptBridge;

/**
 设置代理 不能直接操作上面的webview的delegate
 */
@property (nonatomic,weak) id<WKNavigationDelegate> webViewDelegate;

/**
 定制AXEWebViewController.
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEWKWebViewController *))block;

#pragma mark - router and setting


/**
 注册 http协议， 使用WKWebView处理。
 */
+ (void)registerWKWebViewForHTTP;


/**
 注册 https协议 ， 使用WKWebView处理。
 */
+ (void)registerWKWebViewForHTTPS;
@end
