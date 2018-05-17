//
//  AXEWebViewBridge.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEWebViewBridge.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "AXEDefines.h"
#import "AXEBasicTypeData.h"
#import "AXEJavaScriptModelData.h"
#import "AXEData+JavaScriptSupport.h"
#import "AXEEvent.h"


@interface AXEWebViewBridge()

/**
  当前注册的事件。
 */
@property (nonatomic,strong) NSMutableDictionary *registeredEvents;

@end

@implementation AXEWebViewBridge

+ (instancetype)bridgeWithUIWebView:(UIWebView *)webView {
    NSParameterAssert([webView isKindOfClass:[UIWebView class]]);
    
    return [[self alloc] initWithWebView:webView];
}

+ (instancetype)bridgeWithWKWebView:(WKWebView *)webView {
    NSParameterAssert([webView isKindOfClass:[WKWebView class]]);
    
    return [[self alloc] initWithWebView:webView];
}

- (instancetype)initWithWebView:(UIView *)webView {
    if (self = [super init]) {
        _registeredEvents = [[NSMutableDictionary alloc] init];
        if ([webView isKindOfClass:[UIWebView class]]) {
            _javascriptBridge = (id<AXEWebViewJavaScriptBridge>) [WebViewJavascriptBridge bridgeForWebView:webView];
        }else if ([webView isKindOfClass:[WKWebView class]]) {
            _javascriptBridge = (id<AXEWebViewJavaScriptBridge>) [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView *)webView];
        }
        [self setupBrige];
    }
    return self;
}

- (void)setupBrige {
    @weakify(self);
    // 初始化 jsbridge ,注入相关方法。
    // 设置共享数据数据
    [_javascriptBridge registerHandler:@"axe_data_set" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            [[AXEData sharedData] setJavascriptData:data forKey:[data objectForKey:@"key"]];
        } else {
            AXELogWarn(@"axe_data_set 应该传入 Object/NSDictionary 类型数据");
        }
    }];
    [_javascriptBridge registerHandler:@"axe_data_remove" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[AXEData sharedData] removeDataForKey:data];
        } else {
            AXELogWarn(@"axe_data_remove 应该传入 string 类型数据");
        }
    }];
    [_javascriptBridge registerHandler:@"axe_data_get" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            NSDictionary *value = [[AXEData sharedData] javascriptDataForKey:data];
            if (value) {
                responseCallback(value);
            }else {
                responseCallback([NSNull null]);
            }
        } else {
            AXELogWarn(@"axe_data_get 应该传入 string 类型数据");
        }
        
    }];
    
    
    // 事件通知
    [_javascriptBridge registerHandler:@"axe_event_register" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *eventName = data;
        if ([eventName isKindOfClass:[NSString class]]) {
            @strongify(self);
            if ([self->_registeredEvents objectForKey:eventName]) {
                // 重复注册的问题，一要有工具，二要有好的开发习惯。
                AXELogWarn(@"重复监听 ！！！");
                id<AXEListenerDisposable> disposable = [self->_registeredEvents objectForKey:eventName];
                [disposable dispose];
            }
            // 注册 UI 监听。
            id disposable = [self.webviewController registerUIEvent:eventName withHandler:^(AXEData *payload) {
                NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
                [post setObject:eventName forKey:@"name"];
                if (payload) {
                    // 如果有附带数据，则进行转换。
                    // 转换图片，阻塞主线程，所以大型图片，还是不要往JS里面传了，传些小头像就差不多了。
                    NSDictionary *javascriptData = [AXEData javascriptDataFromAXEData:payload];
                    if ([javascriptData isKindOfClass:[NSDictionary class]]) {
                        [post setObject:javascriptData forKey:@"payload"];
                    }
                }
                [self->_javascriptBridge callHandler:@"axe_event_callback" data:post];
            }];
            [self->_registeredEvents setObject:disposable forKey:eventName];
        } else {
            AXELogWarn(@"axe_event_register 应该传入 string 类型数据");
        }
    }];
    [_javascriptBridge registerHandler:@"axe_event_remove" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        if ([data isKindOfClass:[NSString class]]) {
            // 取消监听
            id<AXEListenerDisposable> disposable = self->_registeredEvents[data];
            if (disposable) {
                [self->_registeredEvents removeObjectForKey:data];
                [disposable dispose];
            }
        } else {
            AXELogWarn(@"axe_event_remove 应该传入 string 类型数据");
        }
        
    }];
    [_javascriptBridge registerHandler:@"axe_event_post" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *payload = [data objectForKey:@"data"];
            AXEData *payloadData;
            if (payload) {
                payloadData = [AXEData axeDataFromJavascriptData:payload];
            }
            [AXEEvent postEventName:[data objectForKey:@"name"] withPayload:payloadData];
        } else {
            AXELogWarn(@"axe_event_post 应该传入 Object/NSDictionary 类型数据");
        }
    }];
    
    
    // 路由跳转
    [_javascriptBridge registerHandler:@"axe_router_route" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *url = [data objectForKey:@"url"];
            NSDictionary *param = [data objectForKey:@"param"];
            AXEData *payload;
            if (param) {
                payload = [AXEData axeDataFromJavascriptData:param];
            }
            // 是否有回调。
            AXERouteCallbackBlock callback;
            BOOL needCallback = [data objectForKey:@"callback"];
            if (needCallback) {
                callback = ^(AXEData *returnData) {
                    NSDictionary *returnPayload;
                    if (returnData) {
                        returnPayload = [AXEData javascriptDataFromAXEData:returnData];
                    }
                    responseCallback(returnPayload);
                };
            }
            [self.webviewController jumpTo:url withParams:payload finishBlock:callback];
        } else {
            AXELogWarn(@"axe_router_route 应该传入 Object/NSDictionary 类型数据");
        }
    }];
    // 路由回调。
    [_javascriptBridge registerHandler:@"axe_router_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        AXERouteCallbackBlock callback = self.webviewController.routeRequest.callback;
        if (!callback) {
            // 如果当前没有设置回调，则表示 这里不能进行回调， 业务模块间的交互定义存在问题。
            AXELogWarn(@"H5模块调用路由回调， 但是调用者 %@ 并没有设置回调 。 请检测业务逻辑！！！", self.webviewController.routeRequest.fromVC);
            return;
        }
        AXEData *payload;
        if ([data isKindOfClass:[NSDictionary class]]) {
            payload = [AXEData axeDataFromJavascriptData:data];
        }
        callback(payload);
    }];
    // 获取路由信息，即参数以及来源。
    [_javascriptBridge registerHandler:@"axe_router_source" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:2];
        if (self.webviewController.routeRequest.params) {
            NSDictionary *javascriptData = [AXEData javascriptDataFromAXEData:self.webviewController.routeRequest.params];
            [ret setObject:javascriptData forKey:@"payload"];
        }
        if (self.webviewController.routeRequest.callback) {
            [ret setObject:@"true" forKey:@"needCallback"];
        }else {
            [ret setObject:@"false" forKey:@"needCallback"];
        }
        responseCallback(ret);
    }];
}


@end
