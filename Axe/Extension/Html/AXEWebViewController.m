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

// 注意， 参数和回调，是持久存在的， 但是监听， 必须要在页面跳转后，进行清理。但是 如果进行了清理，那么在页面来回跳转时，如何进行监听 ？
// TODO 注意测试 ，两个页面来回切换，会不会导致内存出大问题。
@interface AXEWebViewController ()<AXEEventUserInterfaceContainer>

// 路由参数
@property (nonatomic,copy) AXERouterCallbackBlock routeCallback;
@property (nonatomic,strong) AXEData *routeParams;


@property (nonatomic,strong) AXEWebViewBridge *bridge;
@property (nonatomic,strong) NSString *startURL;
@end

static void (^customViewDidLoadBlock)(AXEWebViewController *);

@implementation AXEWebViewController

+ (void)setCustomViewDidLoadBlock:(void (^)(AXEWebViewController *))block {
    customViewDidLoadBlock = [block copy];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url {
    return [self webViewControllerWithURL:url postParams:nil callback:nil];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url postParams:(AXEData *)params callback:(AXERouterCallbackBlock)callback {
    NSParameterAssert(!url || [url isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    AXEWebViewController *controller = [[self alloc] init];
    controller.startURL = [url copy];
    controller.routeParams = params;
    controller.routeCallback = callback;
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

- (WebViewJavascriptBridge *)javascriptBridge {
    return (WebViewJavascriptBridge *)_bridge.javascriptBridge;
}

- (AXEEventUserInterfaceState *)AXEContainerState {
    return _bridge.AXEContainerState;
}

- (void)setWebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
    [(WebViewJavascriptBridge *)_bridge.javascriptBridge setWebViewDelegate:webViewDelegate];
}

#pragma mark - router register 
+ (void)registerUIWebViewForHTTP {
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
            AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:url postParams:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"http" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        return [AXEWebViewController webViewControllerWithURL:url postParams:params callback:callback];
    }];
}


+ (void)registerUIWebViewForHTTPS {
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
            AXEWebViewController *controller = [AXEWebViewController webViewControllerWithURL:url postParams:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"https" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        return [AXEWebViewController webViewControllerWithURL:url postParams:params callback:callback];
    }];
}



@end
