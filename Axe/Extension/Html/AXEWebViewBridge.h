//
//  AXEWebViewBridge.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridgeBase.h"
#import "AXEEvent.h"
#import "AXEEventUserInterfaceState.h"
#import "AXERouter.h"
#import "AXEViewController.h"

// wkWebview和uiwebview的 jsbridge 接口相同， 使用同样的方式去调用。
@protocol AXEWebViewJavaScriptBridge<NSObject>
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)removeHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)setWebViewDelegate:(id)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;
@end


/**
  桥接 axe的三大组件与webview。 桥接使用 WebviewJavaScriptBridge,
    请查看 axe-js项目
    https://github.com/axe-org/axe-js
 
 * 三大组件中， router 和 event 支持各种形式的h5页面。
    但是event 比较特殊， 容易发生 重复注册 和 内存泄漏问题， 目前只适配了基于Vue的单页面应用。
 */
@interface AXEWebViewBridge : NSObject


/**
  初始化
 */
+ (instancetype)bridgeWithUIWebView:(UIWebView *)webView;


/**
  初始化
 */
+ (instancetype)bridgeWithWKWebView:(WKWebView *)webView;

@property (nonatomic,readonly,strong) id<AXEWebViewJavaScriptBridge> javascriptBridge;


@property (nonatomic,weak) AXEViewController *webviewController;

@end
