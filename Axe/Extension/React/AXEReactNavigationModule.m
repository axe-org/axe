//
//  AXEReactNavigationModule.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactNavigationModule.h"
#import <React/RCTConvert.h>
#import "AXEReactViewController.h"
#import "AXEReactControllerWrapper.h"
#import <React/RCTBridge.h>
#import "AXELog.h"

@interface AXEReactNavigationModule()
@property (nonatomic,strong) AXEReactControllerWrapper *wrapper;
@end


@implementation AXEReactNavigationModule
RCT_EXPORT_MODULE(axe_navigation);
@synthesize bridge = _bridge;
- (AXEReactControllerWrapper *)wrapper{
    if (!_wrapper) {
        _wrapper = [self.bridge.launchOptions objectForKey:AXEReactControllerWrapperKey];
    }
    return _wrapper;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

// 打开页面。  提供这个工具模块的最主要原因，就是为了这个页面跳转 .
// 需要明确 ： 模块间内页面跳转 不能使用 `axe.router` 。
// axe.router 是模块间的交互，模块间的跳转。
RCT_EXPORT_METHOD(push:(NSString *)module){
    AXEReactViewController *current = self.wrapper.controller;
    // 跳转时使用 AXEReactViewController ， 同模块跳转时，不会检测更新离线包。
    AXEReactViewController *vc = [AXEReactViewController controllerWithURL:current.url
                                                                moduleName:module];
    // 默认将调用信息也传递给下一个页面。
    vc.routeRequest = current.routeRequest;
    [current.navigationController pushViewController:vc animated:YES];
}

// 重定向，指跳转到新页面后，从历史中将当前页面删除。
RCT_EXPORT_METHOD(redirect:(NSString *)module){
    AXEReactViewController *current = self.wrapper.controller;
    AXEReactViewController *vc = [AXEReactViewController controllerWithURL:current.url
                                                                moduleName:module];
    // 默认将调用信息也传递给下一个页面。
    vc.routeRequest = current.routeRequest;
    vc.didAppearBlock = ^{
        NSMutableArray *controllers = [current.navigationController.viewControllers mutableCopy];
        [controllers removeObjectAtIndex:controllers.count - 2];
        [current.navigationController setViewControllers:[controllers copy]];
    };
    [current.navigationController pushViewController:vc animated:YES];
}

// 关闭页面
RCT_EXPORT_METHOD(closePage){
    [self.wrapper.controller.navigationController popViewControllerAnimated:YES];
}

// 设置标题。
RCT_EXPORT_METHOD(setTitle:(NSString *)title){
    NSParameterAssert([title isKindOfClass:[NSString class]]);
    self.wrapper.controller.navigationItem.title = title;
}

@end

