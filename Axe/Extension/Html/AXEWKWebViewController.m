//
//  AXEWKWebViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEWKWebViewController.h"
#import "Axe.h"
#import "AXEWebViewBridge.h"
#import "AXELog.h"
#import "WKWebViewJavascriptBridge.h"

@interface AXEWKWebViewController()<AXEEventUserInterfaceContainer>

@property (nonatomic,strong) AXEWebViewBridge *bridge;
@property (nonatomic,copy) NSString *startURL;
@end
static void (^customViewDidLoadBlock)(AXEWKWebViewController *);
@implementation AXEWKWebViewController

+ (void)setCustomViewDidLoadBlock:(void (^)(AXEWKWebViewController *))block {
    customViewDidLoadBlock = [block copy];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url {
    NSParameterAssert(!url || [url isKindOfClass:[NSString class]]);
    AXEWKWebViewController *controller = [[self alloc] init];
    controller.startURL = url;
    return controller;
}

- (void)loadView {
    _webView = [[WKWebView alloc] init];
    // 启动手势右滑返回。
    _webView.allowsBackForwardNavigationGestures = YES;
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_startURL) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL]]];
    }
    
    _bridge = [AXEWebViewBridge bridgeWithWKWebView:_webView];
    _bridge.webviewController = self;
    if (customViewDidLoadBlock) {
        customViewDidLoadBlock(self);
    }
}


- (WKWebViewJavascriptBridge *)javascriptBridge {
    return (WKWebViewJavascriptBridge *)_bridge.javascriptBridge;
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
    [(WKWebViewJavascriptBridge *)_bridge.javascriptBridge setWebViewDelegate:webViewDelegate];
}


#pragma mark - router register
+ (void)registerWKWebViewForHTTP {
    [[AXERouter sharedRouter] registerProtocol:@"http" withJumpRoute:^(AXERouteRequest *request) {
        UINavigationController *navigation;
        if ([request.fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)request.fromVC;
        }else if(request.fromVC.navigationController) {
            navigation = request.fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (request.callback) {
                AXERouteCallbackBlock originCallback = request.callback;
                UIViewController *topVC = navigation.topViewController;
                AXERouteCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    originCallback(data);
                };
                request.callback = autoCloseCallback;
            }
            AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:request.currentURL];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"http" withViewRoute:^UIViewController *(AXERouteRequest *request) {
        AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:request.currentURL];
        controller.routeRequest = request;
        return controller;
    }];
}


+ (void)registerWKWebViewForHTTPS {
    [[AXERouter sharedRouter] registerProtocol:@"https" withJumpRoute:^(AXERouteRequest *request) {
        UINavigationController *navigation;
        if ([request.fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)request.fromVC;
        }else if(request.fromVC.navigationController) {
            navigation = request.fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (request.callback) {
                AXERouteCallbackBlock originCallback = request.callback;
                UIViewController *topVC = navigation.topViewController;
                AXERouteCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    originCallback(data);
                };
                request.callback = autoCloseCallback;
            }
            AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:request.currentURL];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"https" withViewRoute:^UIViewController *(AXERouteRequest *request) {
        AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:request.currentURL];
        controller.routeRequest = request;
        return controller;
    }];
}



@end
