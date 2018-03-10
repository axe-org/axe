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

@end

@implementation AXERouterRequest

+ (instancetype)requestWithSourceURL:(NSString *)sourceURL
                              params:(NSDictionary *)params
                              fromVC:(UIViewController *)fromVC {
    AXERouterRequest *request = [[AXERouterRequest alloc] init];
    request.sourceURL = sourceURL;
    request.params = params;
    request.fromVC = fromVC;
    request.invalid = NO;
    return request;
}


- (BOOL)checkRequestIsValid {
    if (_invalid) {
        return NO;
    }else {
        if (_pagePath) {
            // 如果已经解析过，则不再解析。
            return YES;
        }
        NSString *urlString = _redirectURL ? :_sourceURL;
        NSURLComponents *urlComponets = [NSURLComponents componentsWithString:urlString];
        NSString *protocol = urlComponets.scheme;
        if (!protocol) {
            AXELogWarn(@"AXERouterRequest 检测失败 ,URL : %@有误！！",urlString);
            return NO;
        }
        _protocol = protocol;
        NSString *moduleName = urlComponets.host;
        if (!moduleName) {
            AXELogWarn(@"AXERouterRequest 检测失败 ,URL : %@有误！！",urlString);
            return NO;
        }
        _moduleName = moduleName;
        _pagePath = moduleName;
        NSString *pageName = urlComponets.path;
        if (pageName.length > 1) {
            _pageName = [pageName substringFromIndex:1];
            _pagePath = [_moduleName stringByAppendingString:pageName];
        }
        _formedURL = [NSString stringWithFormat:@"%@://%@",_protocol,_pagePath];
        NSString *query = urlComponets.query;
        if (query) {
            // 解析URL中的参数.
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [urlComponets.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [params setObject:obj.name forKey:obj.value];
            }];
            if (_params) {
                [params addEntriesFromDictionary:_params];
            }
            _params = [params copy];
        }
        return YES;
    }
}

- (NSString *)description {
    if (_invalid) {
        return [NSString stringWithFormat:@"<Invalid AXERouterRequest : %@>",_sourceURL];
    }else {
        return [NSString stringWithFormat:@"<AXERouterRequest : %@>",_formedURL];
    }
}


@end
