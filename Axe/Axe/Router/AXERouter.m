//
//  AXERouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouter.h"
#import "AXERouteRequest.h"
#import "AXERouteDefinition.h"
#import "AXERouteProtocolDefinition.h"
#import "AXELog.h"

@interface AXERouter()
// 跳转路由
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouteProtocolDefinition *> *protocolJumpRoutes;
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouteDefinition *> *jumpRoutes;
// 视图路由。
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouteProtocolDefinition *> *protocolViewRoutes;
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouteDefinition *> *viewRoutes;

@property (nonatomic,strong) NSMutableArray<AXERoutePreprocessBlock> *preprocesses;

// 上次路由跳转时间， 在跳转路由上做一个简单的控制，时间间隔小于 0.3秒，就不跳转了。 避免用户频繁点击与响应速度较慢导致的多页面同时弹出的不合理情况。
@property (nonatomic,strong) NSDate *lastJumpTime;

@end

@implementation AXERouter

- (instancetype)init {
    if (self = [super init]) {
        _protocolJumpRoutes = [[NSMutableDictionary alloc] initWithCapacity:10];
        _jumpRoutes = [[NSMutableDictionary alloc] initWithCapacity:100];
        _protocolViewRoutes = [[NSMutableDictionary alloc] initWithCapacity:10];
        _viewRoutes = [[NSMutableDictionary alloc] initWithCapacity:100];
        _preprocesses = [[NSMutableArray alloc] initWithCapacity:10];
        _lastJumpTime = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

+ (instancetype)sharedRouter {
    static AXERouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[AXERouter alloc] init];
    });
    return router;
}

#pragma mark - register

- (void)registerPath:(NSString *)path withJumpRoute:(AXEJumpRouteHandler)handler {
    NSParameterAssert([path isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    NSAssert(![_jumpRoutes objectForKey:path], @"当前路径 %@ 已被注册，请检查！！",path);
    
    AXERouteDefinition *definition = [AXERouteDefinition defineJumpRouteForPath:path withRouteHandler:handler];
    [_jumpRoutes setObject:definition forKey:path];
}

- (void)registerPath:(NSString *)path withViewRoute:(AXEViewRouteHandler)handler {
    NSParameterAssert([path isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    NSAssert(![_viewRoutes objectForKey:path], @"当前路径 %@ 已被注册，请检查！！",path);
    
    AXERouteDefinition *definition = [AXERouteDefinition defineViewRouteForPath:path withRouteHandler:handler];
    [_viewRoutes setObject:definition forKey:path];
}

- (void)registerProtocol:(NSString *)protocol withJumpRoute:(AXEProtoclJumpRouterBlock)handler {
    NSParameterAssert([protocol isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    NSAssert(![_protocolJumpRoutes objectForKey:protocol], @"当前协议 %@ 已被注册，请检查！！",protocol);
    
    AXERouteProtocolDefinition *definition = [AXERouteProtocolDefinition defineJumpRouteForProtocol:protocol withRouteHandler:handler];
    [_protocolJumpRoutes setObject:definition forKey:protocol];
}


- (void)registerProtocol:(NSString *)protocol withViewRoute:(AXEProtoclViewRouterBlock)handler {
    NSParameterAssert([protocol isKindOfClass:[NSString class]]);
    NSParameterAssert(handler);
    NSAssert(![_protocolViewRoutes objectForKey:protocol], @"当前协议 %@ 已被注册，请检查！！",protocol);
    
    AXERouteProtocolDefinition *definition = [AXERouteProtocolDefinition defineViewRouteForProtocol:protocol withRouteHandler:handler];
    [_protocolViewRoutes setObject:definition forKey:protocol];
}



#pragma mark - route

static NSTimeInterval const RouteMinInterval = 0.3;

- (void)jumpTo:(NSString *)url fromViewController:(UIViewController *)fromVC withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert([fromVC isKindOfClass:[UIViewController class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    NSDate *now = [NSDate date];
    if ([now timeIntervalSinceDate:_lastJumpTime] < RouteMinInterval) {
        AXELogWarn(@"这里做一个简单防误点的功能， 防止由于系统反应慢，导致用户多次点击按钮，导致页面多次弹出");
        return;
    }
    _lastJumpTime = now;
    
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(routerWillJumpRoute:withPayload:)]) {
        [tracker routerWillJumpRoute:url withPayload:params];
    }
    
    AXERouteRequest *request = [AXERouteRequest requestWithSourceURL:url params:params callback:block fromVC:fromVC];
    [_preprocesses enumerateObjectsUsingBlock:^(AXERoutePreprocessBlock  _Nonnull preprocess, NSUInteger idx, BOOL * _Nonnull stop) {
        preprocess(request);
    }];
    if (request.valid) {
        [self jumpForRequest:request];
    }
}

- (void)jumpTo:(NSString *)url fromViewController:(UIViewController *)vc {
    return [self jumpTo:url fromViewController:vc withParams:nil finishBlock:nil];
}

- (void)jumpForRequest:(AXERouteRequest *)request {
    // 首先查看协议。
    if ([request.protocol isEqualToString:AXERouterProtocolName]) {
        // 如果是axe协议, 先把模块、页面信息解析一下。
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
        
        AXERouteDefinition *definition = _jumpRoutes[request.path];
        if (!definition) {
            AXELogWarn(@"当前未支持路由跳转: %@",request.currentURL);
        }else {
            [definition jumpForRequest:request];
        }
    }else {
        // 在协议注册中寻找
        AXERouteProtocolDefinition *definition = _protocolJumpRoutes[request.protocol];
        if (!definition) {
            AXELogWarn(@"当前未支持协议: %@",request.protocol);
        }else{
            [definition jumpForRequest:request];
        }
    }
}

- (__kindof UIViewController *)viewForURL:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(routerWillViewRoute:withPayload:)]) {
        [tracker routerWillViewRoute:url withPayload:params];
    }
    
    AXERouteRequest *request = [AXERouteRequest requestWithSourceURL:url params:params callback:block fromVC:nil];
    [_preprocesses enumerateObjectsUsingBlock:^(AXERoutePreprocessBlock  _Nonnull preprocess, NSUInteger idx, BOOL * _Nonnull stop) {
        preprocess(request);
    }];
    if (request.valid) {
        if ([request.protocol isEqualToString:AXERouterProtocolName]) {
            // 如果是axe协议, 先把模块、页面信息解析一下。
            NSURLComponents *urlComponets = [NSURLComponents componentsWithString:request.currentURL];
            NSString *module = urlComponets.host;
            if (!module) {
                AXELogWarn(@"当前URL 设置出错！ %@",request.currentURL);
                return nil;
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
            
            AXERouteDefinition *definition = _viewRoutes[request.path];
            if (!definition) {
                AXELogWarn(@"当前未支持路由跳转: %@",request.currentURL);
                return nil;
            }else {
                return [definition viewForRequest:request];
            }
        }else {
            // 在协议注册中寻找
            AXERouteProtocolDefinition *definition = _protocolViewRoutes[request.protocol];
            if (!definition) {
                AXELogWarn(@"当前未支持协议: %@",request.protocol);
                return nil;
            }else{
                return [definition viewForRequest:request];
            }
        }
    }else {
        AXELogWarn(@"当前 request : %@ 检测失败 ，无法跳转",request);
        return nil;
    }
}

- (__kindof UIViewController *)viewForURL:(NSString *)url {
    return [self viewForURL:url withParams:nil finishBlock:nil];
}



- (void)addPreprocess:(AXERoutePreprocessBlock)block {
    NSParameterAssert(block);
    
    [_preprocesses addObject:[block copy]];
}

@end


// 默认协议名称为 axe 。
NSString *AXERouterProtocolName = @"axe";
