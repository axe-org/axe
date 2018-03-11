//
//  AXEWebViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"
#import "AXERouter.h"

/**
  使用 UIWebView展示页面
 */
@interface AXEWebViewController : UIViewController


/**
  创建实例

 @param url url
 @return 实例
 */
+ (instancetype)webViewControllerWithURL:(NSString *)url;


/**
  创建实例， 同时传递一定的数据
    标准路由支持的传输 , 需要注意， 参数和回调在当前这个webview内一直可用，所以有回调和参数传递的 h5页面跳转后， 不应该再多次跳转，而应该在页面内完成处理操作。
 @param url 路由URL
 @param params 参数
 @param callback 回调。
 @return 实例
 */
+ (instancetype)webViewControllerWithURL:(NSString *)url postParams:(NSDictionary *)params callback:(AXERouterCallbackBlock)callback;

/**
  设置回调， 在ViewDidLoad时执行， 以定制AXEWebViewController

 @param block <#block description#>
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEWebViewController *))block;

/**
  注册 http协议， 使用UIWebView处理。 建议生成环境不要启用，只使用https.
 */
+ (void)registerUIWebViewForHTTP;


/**
  注册 https协议 ， 使用UIWebView处理。
 */
+ (void)registerUIWebViewForHTTPS;


/**
  该controller只有一个webview。
    需要注意的是 ，这个webview使用webviewJSBridge设置了delegate , 所以不能修改该delegate.
 */
@property (nonatomic,readonly,strong) UIWebView *webView;

/**
  js bridge 。 通过这个来注册自己的插件，供h5调用.
 */
@property (nonatomic,readonly,strong) WebViewJavascriptBridge *javascriptBridge;

/**
  设置代理，必须使用这个。 不能直接操作上面的webview的delegate
 */
@property (nonatomic,weak) id<UIWebViewDelegate> webViewDelegate;

@end
