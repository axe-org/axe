//
//  AXERouteRequest.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouteRequest.h"
#import "AXELog.h"

@interface AXERouteRequest()
@property (nonatomic,copy) NSString *sourceURL;
@property (nonatomic,weak) UIViewController *fromVC;
@property (nonatomic,strong) AXEData *params;
@end

@implementation AXERouteRequest

+ (instancetype)requestWithSourceURL:(NSString *)sourceURL
                              params:(AXEData *)params
                            callback:(AXERouteCallbackBlock)callback
                              fromVC:(UIViewController *)fromVC {
    AXERouteRequest *request = [[AXERouteRequest alloc] init];
    request.sourceURL = sourceURL;
    request.valid = YES;
    request.params = params;
    request.callback = callback;
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
    if (!_params) {
        _params = [AXEData dataForTransmission];
    }
    // 解析参数。
    NSString *query = urlComponets.query;
    if (query) {
        // 解析URL中的参数.
        for (NSURLQueryItem *item in urlComponets.queryItems) {
            [_params setData:item.value forKey:item.name];
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AXERouterRequest : %@>",_currentURL];
}


@end
