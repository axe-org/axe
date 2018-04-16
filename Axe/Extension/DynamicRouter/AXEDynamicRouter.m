//
//  AXEDynamicRouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEDynamicRouter.h"
#import "AXERouterRequest.h"

@interface AXEDynamicRouter ()

@property (nonatomic,strong) NSMutableDictionary *dynamicSetting;

@end

@implementation AXEDynamicRouter


- (instancetype)init {
    if (self = [super init]) {
        _dynamicSetting = [[NSMutableDictionary alloc] initWithCapacity:100];
        // 动态路由设置。
        [[AXERouter sharedRouter] addPreprocess:^(AXERouterRequest *request) {
            NSString *redirectPath = [_dynamicSetting objectForKey:request.protocol];
            if (redirectPath) {
                redirectPath = [redirectPath stringByAppendingString:request.pagePath];
                // 需要重定向， 但是特殊处理一下 http和https.
                NSURL *url = [NSURL URLWithString:redirectPath];
                if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
                    // 对于http的请求，我们要拼接原始 URL的参数。
                    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:request.sourceURL];
                    if (urlComponents.query) {
                        redirectPath = [redirectPath stringByAppendingFormat:@"?%@",urlComponents.query];
                    }
                }
                request.currentURL = redirectPath;
            }
        }];
    }
    return self;
}


+ (instancetype)sharedDynamicRouter {
    static AXEDynamicRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[AXEDynamicRouter alloc] init];
    });
    return router;
}


- (void)setup:(NSDictionary *)setting {
    NSParameterAssert([setting isKindOfClass:[NSDictionary class]]);
    _dynamicSetting = [setting mutableCopy];
}

- (void)addRuleForModule:(NSString *)moduleName redirectPath:(NSString *)redirectPath {
    NSParameterAssert([moduleName isKindOfClass:[NSString class]]);
    NSParameterAssert([redirectPath isKindOfClass:[NSString class]]);
    
    [_dynamicSetting setObject:redirectPath forKey:moduleName];
}

@end
