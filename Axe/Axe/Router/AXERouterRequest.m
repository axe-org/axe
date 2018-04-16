//
//  AXERouterRequest.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouterRequest.h"
#import "AXEDefines.h"

@interface AXERouterRequest()
@property (nonatomic,copy) NSString *sourceURL;
@property (nonatomic,strong) UIViewController *fromVC;
@property (nonatomic,strong) AXEData *params;
@end

@implementation AXERouterRequest

+ (instancetype)requestWithSourceURL:(NSString *)sourceURL
                              params:(AXEData *)params
                              fromVC:(UIViewController *)fromVC {
    AXERouterRequest *request = [[AXERouterRequest alloc] init];
    request.sourceURL = sourceURL;
    request.valid = YES;
    request.params = params;
    request.fromVC = fromVC;
    request.currentURL = sourceURL;
    return request;
}


- (void)setCurrentURL:(NSString *)currentURL {
    _currentURL = [currentURL copy];
    // 解析url解析。
    NSURLComponents *urlComponets = [NSURLComponents componentsWithString:_currentURL];
    NSString *protocol = urlComponets.scheme;
    if (!protocol) {
        AXELogWarn(@"AXERouterRequest 检测失败 ,URL : %@有误！！",_currentURL);
        _valid = NO;
    }
    _protocol = protocol;
    NSString *moduleName = urlComponets.host;
    if (!moduleName) {
        AXELogWarn(@"AXERouterRequest 检测失败 ,URL : %@有误！！",_currentURL);
        _valid = NO;
    }
    _moduleName = moduleName;
    _pagePath = moduleName;
    NSString *pageName = urlComponets.path;
    if (pageName.length > 1) {
        _pageName = [pageName substringFromIndex:1];
        _pagePath = [_moduleName stringByAppendingString:pageName];
    }
    _formedURL = [NSString stringWithFormat:@"%@://%@",_protocol,_pagePath];
    if (!_params) {
        _params = [AXEData dataForTransmission];
    }
    // TODO 考虑是否有必要去解析 URL中的参数， 已知提供了接口供 传递参数， 那么 使用URL 传递参数的场景在于哪里？
    // 对于 h5模块，默认从URL中获取参数， 如果解析了参数，会修改其默认实现。
    NSString *query = urlComponets.query;
    if (query) {
        // 解析URL中的参数.
        for (NSURLQueryItem *item in urlComponets.queryItems) {
            [_params setData:item.value forKey:item.name];
        }
    }
    
}


- (NSString *)description {
    if (!_valid) {
        return [NSString stringWithFormat:@"<Invalid AXERouterRequest : %@>",_sourceURL];
    }else {
        return [NSString stringWithFormat:@"<AXERouterRequest : %@>",_formedURL];
    }
}


@end
