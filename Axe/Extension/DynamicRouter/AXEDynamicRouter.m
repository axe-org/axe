//
//  AXEDynamicRouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEDynamicRouter.h"
#import "AXERouterRequest.h"
#import "Axe.h"
#import "AXEDefines.h"

static NSString *const SavedDynamicSettingKey = @"AXE_SavedDynamicSettingKey";
static NSString *const SavedLastAPPVersionKey = @"AXE_DynamicRouter_LastVersion";

@interface AXEDynamicRouter ()

@property (nonatomic,strong) NSDictionary *dynamicSetting;

@property (nonatomic,strong) NSURLSession *session;

@property (nonatomic,strong) NSDate *lastCheckTime;

@property (nonatomic,strong) NSURL *serverURL;

@end

@implementation AXEDynamicRouter


- (instancetype)init {
    if (self = [super init]) {
        _checkTimeInterval = 10 * 60;
        _lastCheckTime = [NSDate dateWithTimeIntervalSince1970:0];
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _tags = @[];
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

- (void)setupWithURL:(NSString *)serverURL defaultSetting:(NSDictionary *)setting {
    NSParameterAssert(!serverURL || [serverURL isKindOfClass:[NSString class]]);
    NSParameterAssert([setting isKindOfClass:[NSDictionary class]]);
    static dispatch_once_t onceToken;
    // 确保只执行一次。
    dispatch_once(&onceToken, ^{
        // 加载本地数据
        NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SavedDynamicSettingKey];
        if (saved) {
            // 检测版本是否变更。
            NSString *lastAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:SavedLastAPPVersionKey];
            if ([_appVersion isEqualToString:lastAppVersion]) {
                _dynamicSetting = saved;
            } else {
                _dynamicSetting = [setting copy];
                [[NSUserDefaults standardUserDefaults] setObject:_appVersion forKey:SavedLastAPPVersionKey];
            }
        } else {
            _dynamicSetting = [setting copy];
            [[NSUserDefaults standardUserDefaults] setObject:_appVersion forKey:SavedLastAPPVersionKey];
        }
        if (serverURL) {
            // 如果设置了URL ,设置监听
            _serverURL = [NSURL URLWithString:serverURL];
            [AXEEvent registerAsyncListenerForEventName:UIApplicationWillEnterForegroundNotification handler:^(AXEData *payload) {
                [self checkUpdate];
            } priority:AXEEventDefaultPriority inSerialQueue:YES];
            [self checkUpdate];
        }
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
    });
}

- (void)checkUpdate {
    NSDate *checkTime = [NSDate date];
    if ([checkTime timeIntervalSinceDate:_lastCheckTime] < _checkTimeInterval) {
        // 检测时间间隔。
        return;
    }
    _lastCheckTime = checkTime;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_serverURL];
    request.HTTPMethod = @"POST";
    if (!_tags || !_appVersion) {
        AXELogWarn(@"tags 或 appVersion 设置错误 ！！！");
        return;
    }
    NSDictionary *query = @{
                            @"tags": _tags,
                            @"version": _appVersion
                            };
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:query options:0 error:&error];
    if (error) {
        AXELogWarn(@"转换为json失败 ：%@",error);
        return;
    }
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [[_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            AXELogWarn(@" 请求动态路由， 发生网络异常 %@", error);
        } else {
            NSError *err;
            NSDictionary *dynamicSetting = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (err) {
                AXELogWarn(@" 解析返回数据失败 ：%@", err);
            } else {
                // 检测业务异常 , 所以不能设置一个模块叫做 error .....
                if (dynamicSetting[@"error"]) {
                    AXELogWarn(@" 服务器报错 ： %@", dynamicSetting[@"error"]);
                } else {
                    _dynamicSetting = dynamicSetting;
                    // 本地存储
                    [[NSUserDefaults standardUserDefaults] setObject:dynamicSetting forKey:SavedDynamicSettingKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }] resume];
    
}

@end
