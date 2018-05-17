//
//  AXEOfflineWKWebViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/19.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEOfflineWKWebViewController.h"
#import "OPOfflineManager.h"
#import "AXEOfflineDownloadView.h"
#import "AXEDefines.h"

@interface AXEOfflineWKWebViewController()<OPOfflineDownloadDelegate>

@property (nonatomic,copy) NSString *module;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *page;
@property (nonatomic,strong) NSURL *localURL;// 最终的本地路径。
@property (nonatomic,weak) AXEOfflineDownloadView *downloadView;// 下载进度。
@end

@implementation AXEOfflineWKWebViewController

+ (instancetype)webViewControllerWithFilePath:(NSString *)path
                                         page:(NSString *)page
                                     inModule:(NSString *)module {
    NSParameterAssert([path isKindOfClass:[NSString class]]);
    NSParameterAssert([module isKindOfClass:[NSString class]]);
    NSParameterAssert(!page || [page isKindOfClass:[NSString class]]);
    
    AXEOfflineWKWebViewController *webVC = [[self alloc] init];
    webVC.path = path;
    webVC.page = page;
    webVC.module = module;
    return webVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkUpdate];
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
            [self->_downloadView setErrorHandlerButtonTitle:@"重试" withBlock:^{
                [self checkUpdate];
            }];
        });
        return;
    }
    // 否则，就可以直接加载页面了。
    NSString *url = [NSString stringWithFormat:@"file://%@/%@", module.path, _path];
    
    if (_page) {
        // 推荐单页面应用。
        url = [url stringByAppendingFormat:@"#/%@",_page];
    }
    _localURL = [NSURL URLWithString:url];
    
    [self loadLocalHtml:module];
}

- (void)loadLocalHtml:(OPOfflineModule *)module {
    NSString *accessPath = [NSString stringWithFormat:@"file://%@/", module.path];
    NSURL *accessURL = [NSURL URLWithString:accessPath];
    
    if (@available(iOS 9.0, *)) {
        [self.webView loadFileURL:_localURL allowingReadAccessToURL:accessURL];
    } else {
        // 8.x 系统，需要将文件复制到 /temp/www 中
        NSFileManager *fileManager= [NSFileManager defaultManager];
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"www"];
        NSString *package = [accessURL lastPathComponent];
        NSString *distPath = [tmpPath stringByAppendingPathComponent:package];
        if (![fileManager fileExistsAtPath:tmpPath]) {
            [fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileManager fileExistsAtPath:[tmpPath stringByAppendingPathComponent:package]]) {
            // 复制文件
            [fileManager copyItemAtPath:module.path toPath:distPath error:nil];
        }
        
        NSString *newpath = [NSString stringWithFormat:@"file://%@/index.html#/%@", distPath, _page];
        NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:newpath]];
        [self.webView loadRequest:requst];
    }
}


#pragma mark - AXEOfflineDownloadView

- (void)module:(OPOfflineModule *)module didDownloadProgress:(NSInteger)progress {
    [_downloadView didDownloadProgress:progress];
}


- (void)moduleDidFinishDownload:(OPOfflineModule *)module {
    [_downloadView didFinishLoadSuccess];
    NSString *url = [NSString stringWithFormat:@"file://%@/%@", module.path, _path];
    if (_page) {
        // 推荐单页面应用。
        url = [url stringByAppendingFormat:@"/#/%@",_page];
    }
    _localURL = [NSURL URLWithString:url];
    
    [self loadLocalHtml:module];
}

- (void)module:(OPOfflineModule *)module didFailLoadWithError:(NSError *)error {
    [_downloadView didFinishLoadFailed];
}

#pragma mark - router register

+ (void)registerWKWebVIewForOfflineHtml {
    [[AXERouter sharedRouter] registerProtocol:@"ophttp" withJumpRoute:^(AXERouteRequest *request) {
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
            } else {
                AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
                return;
            }
            request.module = module;
            request.path = path;
            request.page = page;
            // filePath 固定为 index.html.
            AXEOfflineWKWebViewController *controller = [AXEOfflineWKWebViewController webViewControllerWithFilePath:@"index.html" page:page inModule:module];
            controller.hidesBottomBarWhenPushed = YES;
            controller.routeRequest = request;
            [navigation pushViewController:controller animated:YES];
        }else {
            AXELogWarn(@"当前 fromVC 设置有问题，无法进行跳转 ！！！fromVC : %@",request.fromVC);
        }
    }];
    [[AXERouter sharedRouter] registerProtocol:@"ophttp" withViewRoute:^UIViewController *(AXERouteRequest *request) {
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
        } else {
            AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
            return nil;
        }
        request.module = module;
        request.path = path;
        request.page = page;
        // filePath 固定为 index.html.
        AXEOfflineWKWebViewController *controller = [AXEOfflineWKWebViewController webViewControllerWithFilePath:@"index.html" page:page inModule:module];
        controller.routeRequest = request;
        return controller;
    }];
}
@end

