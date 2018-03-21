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

@interface AXEOfflineReactViewController ()<OPOfflineDownloadDelegate>
@property (nonatomic,copy) NSString *module;
@property (nonatomic,copy) NSString *subpath;
@property (nonatomic,strong) NSURL *localURL;// 最终的本地路径。
@property (nonatomic,weak) AXEOfflineDownloadView *downloadView;// 下载进度。
- (void)loadRCTViewWithURL:(NSString *)url;
@end

@implementation AXEOfflineReactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkUpdate];
}


+ (instancetype)controllerWithSubpath:(NSString *)subpath
                               Module:(NSString *)module
                               params:(AXEData *)params
                             callback:(AXERouterCallbackBlock)callback {
    NSParameterAssert([subpath isKindOfClass:[NSString class]]);
    NSParameterAssert([module isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    AXEOfflineReactViewController *controller = [AXEOfflineReactViewController controllerWithURL:nil params:params callback:callback];
    controller.module = module;
    controller.subpath = subpath;
    return controller;
}


- (void)checkUpdate {
    // 检测离线包模块。
    OPOfflineModule *module = [[OPOfflineManager sharedManager] moduleForName:_module];
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
            [self->_downloadView setRetryButtonTitle:@"重试" withBlock:^{
                [self checkUpdate];
            }];
        });
        return;
    }
    // 否则，就可以直接加载页面了。
    [self loadRCTViewWithModule:module];
}

- (void)loadRCTViewWithModule:(OPOfflineModule *)module {
    NSString *url = [module.path stringByAppendingPathComponent:_subpath];
    url = [@"file://" stringByAppendingString:url];
    
    [self loadRCTViewWithURL:url];
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
    [[AXERouter sharedRouter] registerProtocol:@"opreact" withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *url) {
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
            // 解析URL
            NSString *path = [url substringFromIndex:10];// opreact:// 10
            NSRange ranage = [path rangeOfString:@"/"];
            NSString *module = [path substringToIndex:ranage.location];
            NSString *subpath = [path substringFromIndex:ranage.location + 1];
            AXEOfflineReactViewController *controller = [AXEOfflineReactViewController controllerWithSubpath:subpath Module:module params:params callback:callback];
            controller.hidesBottomBarWhenPushed = YES;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"opreact" withRouteForVCBlock:^UIViewController *(NSString *url, AXEData *params, AXERouterCallbackBlock callback) {
        // 解析URL
        NSString *path = [url substringFromIndex:10];// opreact:// 10
        NSRange ranage = [path rangeOfString:@"/"];
        NSString *module = [path substringToIndex:ranage.location];
        NSString *subpath = [path substringFromIndex:ranage.location + 1];
        return [AXEOfflineReactViewController controllerWithSubpath:subpath Module:module params:params callback:callback];
    }];
}


@end
