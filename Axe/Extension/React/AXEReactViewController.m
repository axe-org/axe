//
//  AXEReactViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactViewController.h"
#import <React/RCTRootView.h>
#import "AXELog.h"
#import "Axe.h"
#import "AXEReactControllerWrapper.h"

#import "AXEData+JavaScriptSupport.h"

NSString *const AXEReactHttpProtocol = @"react";
NSString *const AXEReactHttpsProtocol = @"reacts";
NSString *const AXEReactModuleNameKey = @"module";

@interface AXEReactViewController ()


@property (nonatomic,copy) NSString *module;
@property (nonatomic,copy) NSString *url;

@end

static void (^CustomViewDidLoadBlock)(AXEReactViewController *);

@implementation AXEReactViewController

+ (void)setCustomViewDidLoadBlock:(void(^)(AXEReactViewController *))block {
    CustomViewDidLoadBlock = [block copy];
}

+ (instancetype)controllerWithURL:(NSString *)url moduleName:(NSString *)moduleName {
    NSParameterAssert(!url || [url isKindOfClass:[NSString class]]);
    NSParameterAssert([moduleName isKindOfClass:[NSString class]]);
    
    AXEReactViewController *controller = [[self alloc] init];
    controller.url = url;
    controller.module = moduleName;
    return controller;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = false;
    self.view.backgroundColor = [UIColor whiteColor];
    if (_url) {
        [self loadReactWithBundleURL:_url moduleName:_module];
    }

    if (CustomViewDidLoadBlock) {
        CustomViewDidLoadBlock(self);
    }
}

- (void)loadReactWithBundleURL:(NSString *)urlStr moduleName:(NSString *)moduleName {
    if (_rctRootView) {
        [_rctRootView removeFromSuperview];
    }

    _url = urlStr;
    _module = moduleName;
    AXEReactControllerWrapper *wrapper = [AXEReactControllerWrapper wrapperWithController:self];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *launchOptions = @{AXEReactControllerWrapperKey : wrapper};
    _rctRootView = [[RCTRootView alloc] initWithBundleURL:url
                                               moduleName:_module
                                        initialProperties:nil
                                            launchOptions:launchOptions];
    
    [self.view addSubview:_rctRootView];
    
    _rctRootView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_rctRootView);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_rctRootView]-0-|"
                                            options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_rctRootView]-0-|"
                                                          options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:constraints];
}



#pragma mark - router register
+ (void)registerReactProtocol {
    [[AXERouter sharedRouter] registerProtocol:AXEReactHttpProtocol withJumpRoute:^(AXERouteRequest *request) {
        UINavigationController *navigation;
        if ([request.fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)request.fromVC;
        }else if(request.fromVC.navigationController) {
            navigation = request.fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (request.callback) {
                UIViewController *topVC = navigation.topViewController;
                AXERouteCallbackBlock originCallback = request.callback;
                AXERouteCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    originCallback(data);
                };
                request.callback = autoCloseCallback;
            }
            // 对于react 协议的请求。 如 react://localhost:8081/index.bundle?platform=ios&module=register
            // 我们约定， URL中必须声明 module ,以表示 单页面中的具体展示页面。
            NSString *module = [request.params stringForKey:AXEReactModuleNameKey];
            NSParameterAssert([module isKindOfClass:[NSString class]]);
            // 将 react -> http
            NSString *url = [request.currentURL stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@"http"];
            AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url moduleName:module];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:AXEReactHttpProtocol withViewRoute:^UIViewController *(AXERouteRequest *request) {
        NSString *module = [request.params stringForKey:AXEReactModuleNameKey];
        NSParameterAssert([module isKindOfClass:[NSString class]]);
        // 将 react -> http
        NSString *url = [request.currentURL stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@"http"];
        AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url moduleName:module];
        controller.routeRequest = request;
        return controller;
    }];
}

+ (void)registerReactsProtocol {
    [[AXERouter sharedRouter] registerProtocol:AXEReactHttpsProtocol withJumpRoute:^(AXERouteRequest *request) {
        UINavigationController *navigation;
        if ([request.fromVC isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)request.fromVC;
        }else if(request.fromVC.navigationController) {
            navigation = request.fromVC.navigationController;
        }
        if (navigation) {
            // 对于 跳转路由， 自动在执行回调时关闭页面。
            if (request.callback) {
                UIViewController *topVC = navigation.topViewController;
                AXERouteCallbackBlock originCallback = request.callback;
                AXERouteCallbackBlock autoCloseCallback = ^(AXEData *data) {
                    [navigation popToViewController:topVC animated:YES];
                    originCallback(data);
                };
                request.callback = autoCloseCallback;
            }
            // 对于react 协议的请求。 如 reacts://localhost:8081/index.bundle?platform=ios&module=register
            // 我们约定， URL中必须声明 module ,以表示 单页面中的具体展示页面。
            NSString *module = [request.params stringForKey:AXEReactModuleNameKey];
            NSParameterAssert([module isKindOfClass:[NSString class]]);
            // 将 reacts -> https
            NSString *url = [request.currentURL stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"https"];
            AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url moduleName:module];
            controller.routeRequest = request;
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:AXEReactHttpsProtocol withViewRoute:^UIViewController *(AXERouteRequest *request) {
        NSString *module = [request.params stringForKey:AXEReactModuleNameKey];
        NSParameterAssert([module isKindOfClass:[NSString class]]);
        // 将 reacts -> https
        NSString *url = [request.currentURL stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"https"];
        AXEReactViewController *controller = [AXEReactViewController controllerWithURL:url moduleName:module];
        controller.routeRequest = request;
        return controller;
    }];
}



@end

