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
    if (self.wrapper.routerCallback) {
        // 有回调才能触发。
        AXEData *data;
        if ([param isKindOfClass:[NSDictionary class]]) {
            data = [AXEData axeDataFromJavascriptData:param];
        }
        self.wrapper.routerCallback(data);
        self.wrapper.routerCallback = nil;
    }else {
        AXELogWarn(@"当前 页面并没有路由回调， 不能执行回调函数！！！");
    }
}


RCT_EXPORT_METHOD(route:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback) {
    NSParameterAssert([param isKindOfClass:[NSDictionary class]]);
    if (!self.wrapper.controller) {
        return;
    }
    NSString *url = [param objectForKey:@"url"];
    NSDictionary *jsdata = [param objectForKey:@"param"];
    AXEData *payload;
    if (jsdata) {
        payload = [AXEData axeDataFromJavascriptData:jsdata];
    }
    // 是否有回调。
    AXERouterCallbackBlock routerCallback = ^(AXEData *returnData) {
        NSArray *response;
        if (returnData) {
            response = @[[AXEData javascriptDataFromAXEData:returnData]];
        }
        callback(response);
    };
    [[AXERouter sharedRouter] routeURL:url fromViewController:self.wrapper.controller withParams:payload finishBlock:routerCallback];
}

RCT_EXPORT_METHOD(routeWithoutCallback:(NSDictionary *)param) {
    NSParameterAssert([param isKindOfClass:[NSDictionary class]]);
    if (!self.wrapper.controller) {
        return;
    }
    NSString *url = [param objectForKey:@"url"];
    NSDictionary *jsdata = [param objectForKey:@"param"];
    AXEData *payload;
    if (jsdata) {
        payload = [AXEData axeDataFromJavascriptData:jsdata];
    }
    [[AXERouter sharedRouter] routeURL:url fromViewController:self.wrapper.controller withParams:payload finishBlock:nil];
}


- (NSDictionary *)constantsToExport {
    NSMutableDictionary *sourceRouteInfo = [[NSMutableDictionary alloc] init];
    [sourceRouteInfo setObject:self.wrapper.routerCallback ? @"true" : @"false" forKey:@"needCallback"];
    if (self.wrapper.routerData) {
        [sourceRouteInfo setObject:[AXEData javascriptDataFromAXEData:self.wrapper.routerData] forKey:@"payload"];
    }
    return @{@"lastRouteInfo" : sourceRouteInfo};
}



@end
