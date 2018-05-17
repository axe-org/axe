//
//  AXEOfflineReactViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/21.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEOfflineReactViewController.h"
#import "AXEOfflineDownloadView.h"
#import "OPOfflineManager.h"
#import "AXEReactControllerWrapper.h"
#import "AXEDefines.h"

// 同时我们也规定，入口文件名，也固定 ，为 bundle.js
static NSString *const AXEDefaultBundleName = @"bundle.js";


@interface AXEOfflineReactViewController ()<OPOfflineDownloadDelegate>
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *offlineModule;
@property (nonatomic,copy) NSString *moduleName;
@property (nonatomic,strong) NSURL *localURL;// 最终的本地路径。
@property (nonatomic,weak) AXEOfflineDownloadView *downloadView;// 下载进度。

@end

@implementation AXEOfflineReactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkUpdate];
}


+ (instancetype)controllerWithBundlePath:(NSString *)path
                              moduleName:(NSString *)moduleName
                         inOfflineModule:(NSString *)offlineModule {
    NSParameterAssert([path isKindOfClass:[NSString class]]);
    NSParameterAssert([moduleName isKindOfClass:[NSString class]]);
    NSParameterAssert([offlineModule isKindOfClass:[NSString class]]);
    
    AXEOfflineReactViewController *controller = [[AXEOfflineReactViewController alloc] init];
    controller.path = path;
    controller.moduleName = moduleName;
    controller.offlineModule = offlineModule;
    return controller;
}


- (void)checkUpdate {
    // 检测离线包模块。
    OPOfflineModule *module = [[OPOfflineManager sharedManager] moduleForName:_offlineModule];
    // 要检测module ,一般肯定会返回，但是要以防万一。
    if (!module) {
        // TODO 展示错误页面。
        
        return;
    }
    if (module.needCheckUpdate) {
        // 如果需要检测更新， 则要展示进度条。
        module.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_downloadView = [AXEOfflineDownloadView showInView:self.view];
            [self->_downloadView setErrorHandlerButtonTitle:@"重试" withBlock:^{
                [self checkUpdate];
            }];
        });
        return;
    }
    // 否则，就可以直接加载页面了。
    [self loadRCTViewWithModule:module];
}

- (void)loadRCTViewWithModule:(OPOfflineModule *)module {
    NSString *url = [module.path stringByAppendingPathComponent:_path];
    url = [@"file://" stringByAppendingString:url];
    
    [self loadReactWithBundleURL:url moduleName:_moduleName];
}


#pragma mark - AXEOfflineDownloadView

- (void)module:(OPOfflineModule *)module didDownloadProgress:(NSInteger)progress {
    [_downloadView didDownloadProgress:progress];
}


- (void)moduleDidFinishDownload:(OPOfflineModule *)module {
    [_downloadView didFinishLoadSuccess];
    [self loadRCTViewWithModule:module];
}

- (void)module:(OPOfflineModule *)module didFailLoadWithError:(NSError *)error {
    [_downloadView didFinishLoadFailed];
}

#pragma mark router register
+ (void)registerOfflineReactProtocol {
    [[AXERouter sharedRouter] registerProtocol:AXEOfflineReactProtocol withJumpRoute:^(AXERouteRequest *request) {
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
            // 解析URL
            NSURLComponents *urlComponets = [NSURLComponents componentsWithString:request.currentURL];
            NSString *module = urlComponets.host;
            if (!module) {
                AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
                return;
            }
            NSString *page = urlComponets.path;
            NSString *path = module;
            if (page.length > 1) {
                path = [module stringByAppendingString:page];
                page = [page substringFromIndex:1];
            }
            request.module = module;
            request.path = path;
            request.page = page;
            
            
            AXEOfflineReactViewController *controller = [AXEOfflineReactViewController controllerWithBundlePath:AXEDefaultBundleName
                                                                                                     moduleName:page
                                                                                                inOfflineModule:module];
            controller.hidesBottomBarWhenPushed = YES;
            controller.routeRequest = request;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:AXEOfflineReactProtocol withViewRoute:^UIViewController *(AXERouteRequest *request) {
        // 解析URL
        NSURLComponents *urlComponets = [NSURLComponents componentsWithString:request.currentURL];
        NSString *module = urlComponets.host;
        if (!module) {
            AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
            return nil;
        }
        NSString *page = urlComponets.path;
        NSString *path = module;
        if (page.length > 1) {
            path = [module stringByAppendingString:page];
            page = [page substringFromIndex:1];
        }
        request.module = module;
        request.path = path;
        request.page = page;
        
        AXEOfflineReactViewController *controller = [AXEOfflineReactViewController controllerWithBundlePath:AXEDefaultBundleName
                                                                                                 moduleName:page
                                                                                            inOfflineModule:module];
        controller.routeRequest = request;
        return controller;
    }];
}


@end

NSString *const AXEOfflineReactProtocol = @"oprn";
