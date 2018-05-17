//
//  AXEWebViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEWebViewController.h"
#import "Axe.h"
#import "AXEWebViewBridge.h"
#import "AXEDefines.h"
#import "WebViewJavascriptBridge.h"


@interface AXEWebViewController ()<AXEEventUserInterfaceContainer>
// 传入URL
@property (nonatomic,copy) NSString *startURL;

@property (nonatomic,strong) AXEWebViewBridge *bridge;

@end

static void (^customViewDidLoadBlock)(AXEWebViewController *);

@implementation AXEWebViewController

+ (void)setCustomViewDidLoadBlock:(void (^)(AXEWebViewController *))block {
    customViewDidLoadBlock = [block copy];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url {
    NSParameterAssert(!url || [url isKindOfClass:[NSString class]]);
    AXEWebViewController *controller = [[self alloc] init];
    controller.startURL = url;
    return controller;
}


- (void)loadView {
    _webView = [[UIWebView alloc] init];
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_startURL) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL]]];
    }
    _bridge = [AXEWebViewBridge bridgeWithUIWebView:_webView];
    _bridge.webviewController = self;
    if (customViewDidLoadBlock) {
        customViewDidLoadBlock(self);
    }
}


- (WebViewJavascriptBridge *)javascriptBridge {
    return (WebViewJavascriptBridge *)_bridge.javascriptBridge;
}

- (void)setWebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
    [(WebViewJavascriptBridge *)_bridge.javascriptBridge setWebViewDelegate:webViewDelegate];
}

#pragma mark - router register 
+ (void)registerUIWebViewForHTTP {
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
            AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:request.currentURL];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"http" withViewRoute:^UIViewController *(AXERouteRequest *request) {
        AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:request.currentURL];
        controller.routeRequest = request;
        return controller;
    }];
}


+ (void)registerUIWebViewForHTTPS {
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
            AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:request.currentURL];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"https" withViewRoute:^UIViewController *(AXERouteRequest *request) {
        AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:request.currentURL];
        controller.routeRequest = request;
        return controller;
    }];
}



@end
