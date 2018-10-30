//
//  AXEDynamicRouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEDynamicRouter.h"
#import "AXERouteRequest.h"
#import "Axe.h"
#import "AXELog.h"


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
            if ([self->_appVersion isEqualToString:lastAppVersion]) {
                self->_dynamicSetting = saved;
            } else {
                self->_dynamicSetting = [setting copy];
                [[NSUserDefaults standardUserDefaults] setObject:self->_dynamicSetting forKey:SavedDynamicSettingKey];
                [[NSUserDefaults standardUserDefaults] setObject:self->_appVersion forKey:SavedLastAPPVersionKey];
            }
        } else {
            self->_dynamicSetting = [setting copy];
        }
        if (serverURL) {
            // 如果设置了URL ,设置监听
            self->_serverURL = [NSURL URLWithString:serverURL];
            [AXEEvent registerSerialListenerForEventName:UIApplicationWillEnterForegroundNotification handler:^(AXEData *payload) {
                [self checkUpdate];
            } priority:AXEEventDefaultPriority];
            [self checkUpdate];
        }
        // 动态路由设置。
        [[AXERouter sharedRouter] addPreprocess:^(AXERouteRequest *request) {
            if ([request.protocol isEqualToString:AXEStatementRouterProtocol]) {
                // 如果是声明路由则处理。
                NSURLComponents *urlComponets = [NSURLComponents componentsWithString:request.currentURL];
                NSString *module = urlComponets.host;
                if (!module) {
                    AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
                    return;
                }
                NSString *page = urlComponets.path;
                NSString *path = module;
                if (page.length > 1) {
                    path = [module stringByAppendingString:page];
                    page = [page substringFromIndex:1];
                }
                request.module = module;
                request.path = path;
                request.page = page;
                
                NSString *redirectPath = [self->_dynamicSetting objectForKey:request.module];
                if (redirectPath) {
                    redirectPath = [redirectPath stringByAppendingString:request.page];
                    AXELogTrace(@"动态路由进行重定向 ： %@ => %@", request.currentURL,redirectPath);
                    request.currentURL = redirectPath;
                } else {
                    AXELogWarn(@"当前启用动态路由，但是 %@ 并没有查找到映射规则，路由处理失败！！", request);
                    request.valid = NO;
                }
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
                    self->_dynamicSetting = dynamicSetting;
                    AXELogTrace(@"更新动态路由规则： %@", dynamicSetting);
                    // 本地存储
                    [[NSUserDefaults standardUserDefaults] setObject:dynamicSetting forKey:SavedDynamicSettingKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }] resume];
    
}

@end

// axe + s , s 表示 statement ,声明。
NSString *AXEStatementRouterProtocol = @"axes";
