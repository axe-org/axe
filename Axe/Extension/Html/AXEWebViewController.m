//
//  AXEWebViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEWebViewController.h"
#import "Axe.h"

// 注意， 参数和回调，是持久存在的， 但是监听， 必须要在页面跳转后，进行清理。但是 如果进行了清理，那么在页面来回跳转时，如何进行监听 ？
// 注意测试 ，两个页面来回切换，会不会导致内存出大问题。
@interface AXEWebViewController ()<AXEEventUserInterfaceContainer>

// 路由参数
@property (nonatomic,copy) AXERouterCallbackBlock routeCallback;
@property (nonatomic,copy) NSDictionary *routeParams;

@end

@implementation AXEWebViewController

+ (instancetype)webViewControllerWithURL:(NSString *)url {
    return [self webViewControllerWithURL:url postParams:nil callback:nil];
}

+ (instancetype)webViewControllerWithURL:(NSString *)url postParams:(NSDictionary *)params callback:(AXERouterCallbackBlock)callback {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[NSDictionary class]]);
    
    AXEWebViewController *controller = [[AXEWebViewController alloc] init];
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
    
    
    
    
}



@end
