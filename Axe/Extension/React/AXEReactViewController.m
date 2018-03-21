//
//  AXEReactViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactViewController.h"
#import <React/RCTRootView.h>
#import "AXEDefines.h"
#import "Axe.h"
#import "AXEReactControllerWrapper.h"

#import "AXEData+JavaScriptSupport.h"

@interface AXEReactViewController ()

// 路由参数
@property (nonatomic,copy) AXERouterCallbackBlock routeCallback;
@property (nonatomic,strong) AXEData *routeParams;
@property (nonatomic,strong) NSString *startURL;
@property (nonatomic,strong) AXEEventUserInterfaceState *AXEContainerState;

@end

static void (^CustomViewDidLoadBlock)(AXEReactViewController *);

@implementation AXEReactViewController

+ (void)setCustomViewDidLoadBlock:(void(^)(AXEReactViewController *))block {
    CustomViewDidLoadBlock = [block copy];
}

+ (instancetype)controllerWithURL:(NSString *)url params:(AXEData *)params callback:(AXERouterCallbackBlock)callback {
    NSParameterAssert(!url || [url isKindOfClass:[NSString class]]);
    NSParameterAssert([params isKindOfClass:[AXEData class]]);
    
    AXEReactViewController *controller = [[self alloc] init];
    controller.startURL = [url copy];
    controller.routeParams = params;
    controller.routeCallback = callback;
    controller.AXEContainerState = [AXEEventUserInterfaceState state];
    controller.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    return controller;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (_startURL) {
        [self loadRCTViewWithURL:_startURL];
    }

    if (CustomViewDidLoadBlock) {
        CustomViewDidLoadBlock(self);
    }
}

- (void)loadRCTViewWithURL:(NSString *)urlStr {
    NSString *moduleName = [_routeParams stringForKey:AXEReactModuleNameKey];
    if (![moduleName isKindOfClass:[NSString class]]) {
        AXELogWarn(@"对于React Native模块 ，参数中必须带有 AXEReactModuleNameKey 参数！！！");
        return;
    }
    AXEReactControllerWrapper *wrapper = [AXEReactControllerWrapper wrapperWithController:self];
    wrapper.routerData = _routeParams;
    wrapper.routerCallback =  _routeCallback;
    _routeParams = nil;
    _routeCallback = nil;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *launchOptions = @{AXEReactControllerWrapperKey : wrapper};
    _rctRootView = [[RCTRootView alloc] initWithBundleURL:url moduleName:moduleName initialProperties:nil launchOptions:launchOptions];
    
    [self.view addSubview:_rctRootView];
    _rctRootView.frame = self.view.bounds;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_AXEContainerState containerWillAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_AXEContainerState containerWillDisappear];
}



#pragma mark - router register
+ (void)registerReactProtocol {
    [[AXERouter sharedRouter] registerProtocol:@"react" withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *url) {
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
            // 将url 修改回http
            url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@"http"];
            AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url params:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"react" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        // 将url 修改回http
        url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@"http"];
        return [AXEReactViewController controllerWithURL:url params:params callback:callback];
    }];
}

+ (void)registerReactsProtocol {
    [[AXERouter sharedRouter] registerProtocol:@"reacts" withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *url) {
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
            // 将url 修改回http
            url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"https"];
            AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url params:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"react" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        // 将url 修改回http
        url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"https"];
        return [AXEReactViewController controllerWithURL:url params:params callback:callback];
    }];
}



@end

NSString *const AXEReactModuleNameKey = @"_moduleName";
