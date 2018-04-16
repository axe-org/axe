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
// 使用 WebViewJavascriptBridge 作为桥接
@class WebViewJavascriptBridge;

// 对于 H5默认路由， 关于回调的注意事项 。
// 参考 AXERouter.h中对于路由的描述 ,已知， 对于 jump route ，回调时的界面关闭由被调用者实现， 对于 controller route ，界面关闭由调用者管理。
// 所以， 在 h5 默认实现中， 对于 jump route 带有回调时， js 正常调用回调接口即可， 页面关闭由 AXEWebViewController 实现了。
// 而 已知 controller route 的关闭由调用者负责， 所以 js端可以完全不用关注页面的关闭逻辑。
// 只需要注意， 一次带有回调了调用，应该在当前页面, 当前webview完成， 打开新的webview后，回调不会被传递到新的webview中。

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
+ (instancetype)webViewControllerWithURL:(NSString *)url postParams:(AXEData *)params callback:(AXERouterCallbackBlock)callback;

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

#pragma mark - router and setting

/**
 设置回调， 在ViewDidLoad时执行， 以定制AXEWebViewController
 
 @param block <#block description#>
 */
+ (void)setCustomViewDidLoadBlock:(void(^)(AXEWebViewController *))block;

/**
 注册 http协议， 使用UIWebView处理。 建议生成环境不要启用，只使用https.
 
  讨论 ， 取消回调的处理。 如果用户点击关闭页面时， 这个取消回调，是否提供默认实现。
 */
+ (void)registerUIWebViewForHTTP;


/**
 注册 https协议 ， 使用UIWebView处理。
 */
+ (void)registerUIWebViewForHTTPS;


@end


