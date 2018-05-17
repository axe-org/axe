//
//  AXEReactRouterModule.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactRouterModule.h"
#import <React/RCTConvert.h>
#import "AXEData+JavaScriptSupport.h"
#import "AXEReactViewController.h"
#import "AXEReactControllerWrapper.h"
#import <React/RCTBridge.h>
#import "AXEDefines.h"

@interface AXEReactRouterModule()

@property (nonatomic,strong) AXEReactControllerWrapper *wrapper;

@end

@implementation AXEReactRouterModule
RCT_EXPORT_MODULE(axe_router);
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


RCT_EXPORT_METHOD(callback:(NSDictionary *)param){
    // 先要检测本地是否有回调。
    if (self.wrapper.controller.routeRequest.callback) {
        // 有回调才能触发。
        AXEData *data;
        if ([param isKindOfClass:[NSDictionary class]]) {
            data = [AXEData axeDataFromJavascriptData:param];
        }
        self.wrapper.controller.routeRequest.callback(data);
    }else {
        AXELogWarn(@"当前 页面并没有设置路由回调！！！");
    }
}


RCT_EXPORT_METHOD(route:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback) {
    if ([param isKindOfClass:[NSDictionary class]]) {
        if (!self.wrapper.controller) {
            return;
        }
        NSString *url = [param objectForKey:@"url"];
        NSDictionary *jsdata = [param objectForKey:@"param"];
        AXEData *payload;
        if (jsdata) {
            payload = [AXEData axeDataFromJavascriptData:jsdata];
        }
        // 有回调。
        AXERouteCallbackBlock routerCallback = ^(AXEData *returnData) {
            NSArray *response;
            if (returnData) {
                response = @[[AXEData javascriptDataFromAXEData:returnData]];
            }
            callback(response);
        };
        [self.wrapper.controller jumpTo:url withParams:payload finishBlock:routerCallback];
    } else {
        AXELogWarn(@"param 需要为 NSDictionary 类型！");
    }
}

RCT_EXPORT_METHOD(routeWithoutCallback:(NSDictionary *)param) {
    if ([param isKindOfClass:[NSDictionary class]]) {
        if (!self.wrapper.controller) {
            return;
        }
        NSString *url = [param objectForKey:@"url"];
        NSDictionary *jsdata = [param objectForKey:@"param"];
        AXEData *payload;
        if (jsdata) {
            payload = [AXEData axeDataFromJavascriptData:jsdata];
        }
        [[AXERouter sharedRouter] jumpTo:url fromViewController:self.wrapper.controller withParams:payload finishBlock:nil];
    } else {
        AXELogWarn(@"param 需要为 NSDictionary 类型！");
    }
}

// 将路由信息使用常量进行暴露。
- (NSDictionary *)constantsToExport {
    NSMutableDictionary *sourceRouteInfo = [[NSMutableDictionary alloc] init];
    [sourceRouteInfo setObject:self.wrapper.controller.routeRequest.callback ? @"true" : @"false" forKey:@"needCallback"];
    if (self.wrapper.controller.routeRequest.params) {
        [sourceRouteInfo setObject:[AXEData javascriptDataFromAXEData:self.wrapper.controller.routeRequest.params] forKey:@"payload"];
    }
    return @{@"lastRouteInfo" : sourceRouteInfo};
}



@end
