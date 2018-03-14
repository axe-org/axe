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
#import "AXEDefines.h"

@interface AXEWKWebViewController()<AXEEventUserInterfaceContainer>
// 路由参数
@property (nonatomic,copy) AXERouterCallbackBlock routeCallback;
@property (nonatomic,strong) AXEData *routeParams;


@property (nonatomic,strong) AXEWebViewBridge *bridge;
@property (nonatomic,strong) NSString *startURL;
@end
static void (^customViewDidLoadBlock)(AXEWKWebViewController *);
@implementation AXEWKWebViewController

+ (void)setCustomViewDidLoadBlock:(void (^)(AXEWKWebViewController *))block {
    customViewDidLoadBlock = [block copy];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url {
    return [self webViewControllerWithURL:url postParams:nil callback:nil];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url postParams:(AXEData *)params callback:(AXERouterCallbackBlock)callback {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    AXEWKWebViewController *controller = [[self alloc] init];
    controller.startURL = [url copy];
    controller.routeParams = params;
    controller.routeCallback = callback;
    return controller;
}


- (void)loadView {
    _webView = [[WKWebView alloc] init];
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL]]];
    
    _bridge = [AXEWebViewBridge bridgeWithWKWebView:_webView];
    _bridge.webviewController = self;
    _bridge.routeCallback = _routeCallback;
    _routeCallback = nil;
    _bridge.routeParams = _routeParams;
    _routeParams = nil;
    if (customViewDidLoadBlock) {
        customViewDidLoadBlock(self);
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_bridge.AXEContainerState containerWillAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_bridge.AXEContainerState containerWillDisappear];
}

- (WKWebViewJavascriptBridge *)javascriptBridge {
    return (WKWebViewJavascriptBridge *)_bridge.javascriptBridge;
}

- (AXEEventUserInterfaceState *)AXEContainerState {
    return _bridge.AXEContainerState;
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
    [(WKWebViewJavascriptBridge *)_bridge.javascriptBridge setWebViewDelegate:webViewDelegate];
}


#pragma mark - router register
+ (void)registerWKWebViewForHTTP {
    [[AXERouter sharedRouter] registerProtocol:@"http" withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *url) {
        UINavigationController *navigation;
        if ([fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)fromVC;
        }else if(fromVC.navigationController) {
            navigation = fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (callback) {
                UIViewController *topVC = navigation.topViewController;
                AXERouterCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    callback(data);
                };
                callback = autoCloseCallback;
            }
            AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:url postParams:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"http" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        return [AXEWKWebViewController webViewControllerWithURL:url postParams:params callback:callback];
    }];
}


+ (void)registerWKWebViewForHTTPS {
    [[AXERouter sharedRouter] registerProtocol:@"https" withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *url) {
        UINavigationController *navigation;
        if ([fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)fromVC;
        }else if(fromVC.navigationController) {
            navigation = fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (callback) {
                UIViewController *topVC = navigation.topViewController;
                AXERouterCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    callback(data);
                };
                callback = autoCloseCallback;
            }
            AXEWKWebViewController *controller = [AXEWKWebViewController webViewControllerWithURL:url postParams:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"https" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        return [AXEWKWebViewController webViewControllerWithURL:url postParams:params callback:callback];
    }];
}



@end
