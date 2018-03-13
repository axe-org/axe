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
  桥接 axe的三大组件与webview。 桥接使用 WebviewJavaScriptBridge, 为js添加一下方法 ：

 // TODO 加一个 NSData 和 NSDate 两种类型。。
 window.axe.route(URL,data {object 类型},handler);
 window.axe.sharedData.getObjectForKey(key)
 // 在 js中 对data的操作，与 原生代码中正好相反， 原生代码中，设置不需要指明类型，而读取时 需要指明类型。 而js中设置需要指明类型，而读取时不需要指明类型。
 
 window.axe.sharedData.setModel(model,key)
 window.axe.sharedData.removeItem(key)
 window.axe.event.post(name,data)
 window.axe.event.register(name,handler)
 
 */
@interface AXEWebViewBridge : NSObject <AXEEventUserInterfaceContainer>


/**
  初始化
 */
+ (instancetype)bridgeWithUIWebView:(UIWebView *)webView;


/**
  初始化
 */
+ (instancetype)bridgeWithWKWebView:(WKWebView *)webView;

@property (nonatomic,readonly,strong) id<AXEWebViewJavaScriptBridge> javascriptBridge;

@property (nonatomic,readonly,strong) AXEEventUserInterfaceState *AXEContainerState;

@property (nonatomic,weak) UIViewController *webviewController;


/**
  如果是路由跳转过来的，可能会拥有回调.
 */
@property (nonatomic,copy) AXERouterCallbackBlock routeCallback;

/**
  路由跳转时， 所带的参数。 javascript 通过
   axe.router.source 来判断是否是有路由跳转过来，是否带有参数，是否带有回调。
 */
@property (nonatomic,strong) AXEData *routeParams;

@end
