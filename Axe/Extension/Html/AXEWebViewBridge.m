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
        _state = [AXEEventUserInterfaceState state];
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
    // 初始化 jsbridge ,注入相关方法。
    // 设置共有数据
    [_javascriptBridge registerHandler:@"axe_data_set" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[AXEData sharedData] setJavascriptData:data];
    }];
    
    
}

@end
