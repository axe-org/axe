//
//  AXERouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/7.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouter.h"
#import "AXERouterRequest.h"
#import "AXERouterDefinition.h"
#import "AXERouterProtocolDefinition.h"
#import "AXERouter+list.h"

@interface AXERouter()
// 跳转路由
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouterProtocolDefinition *> *protocols;
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouterDefinition *> *routes;
// 返回uiViewController的路由。
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouterProtocolDefinition *> *vcProtocols;
@property (nonatomic,strong) NSMutableDictionary<NSString *,AXERouterDefinition *> *vcRoutes;

@property (nonatomic,strong) NSMutableArray<AXERouterPreprocessBlock> *preprocesses;

@end

@implementation AXERouter

- (instancetype)init {
    if (self = [super init]) {
        _protocols = [[NSMutableDictionary alloc] initWithCapacity:10];
        _routes = [[NSMutableDictionary alloc] initWithCapacity:100];
        _vcProtocols = [[NSMutableDictionary alloc] initWithCapacity:10];
        _vcRoutes = [[NSMutableDictionary alloc] initWithCapacity:100];
        _preprocesses = [[NSMutableArray alloc] initWithCapacity:10];
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

#ifdef AXEROUTER_LIST_ENABLE
- (NSArray<NSString *> *)routerList {
    return _routes.allKeys;
}

- (NSArray<NSString *> *)vcRouterList {
    return _vcRoutes.allKeys;
}
#endif
#pragma mark - register

- (void)registerPagePath:(NSString *)pagePath withRouterBlock:(AXERouterBlock)block {
    NSParameterAssert([pagePath isKindOfClass:[NSString class]]);
    NSParameterAssert(block);
    NSAssert(![_routes objectForKey:pagePath], @"当前路径 %@ 已被注册，请检查！！",pagePath);
    
    AXERouterDefinition *definition = [AXERouterDefinition definitionWithPagePath:pagePath block:block];
    [_routes setObject:definition forKey:pagePath];
}

- (void)registerPagePath:(NSString *)pagePath withRouterForVCBlock:(AXERouteForVCBlock)block {
    NSParameterAssert([pagePath isKindOfClass:[NSString class]]);
    NSParameterAssert(block);
    NSAssert(![_vcRoutes objectForKey:pagePath], @"当前路径 %@ 已被注册，请检查！！",pagePath);
    
    AXERouterDefinition *definition = [AXERouterDefinition definitionWithPagePath:pagePath routeForVCBlock:block];
    [_vcRoutes setObject:definition forKey:pagePath];
}

- (void)registerProtocol:(NSString *)protocolName withRouterBlock:(AXEProtoclRouterBlock)block {
    NSParameterAssert([protocolName isKindOfClass:[NSString class]]);
    NSParameterAssert(block);
    NSAssert(![_protocols objectForKey:protocolName], @"当前协议 %@ 已被注册，请检查！！",protocolName);
    
    AXERouterProtocolDefinition *definition = [AXERouterProtocolDefinition definitionWithProtocol:protocolName block:block];
    [_protocols setObject:definition forKey:protocolName];
}

- (void)registerProtocol:(NSString *)protocolName withRouteForVCBlock:(AXEProtoclRouteForVCBlock)block {
    NSParameterAssert([protocolName isKindOfClass:[NSString class]]);
    NSParameterAssert(block);
    NSAssert(![_vcProtocols objectForKey:protocolName], @"当前协议 %@ 已被注册，请检查！！",protocolName);
    
    AXERouterProtocolDefinition *definition = [AXERouterProtocolDefinition definitionWithProtocol:protocolName routeForVCBlock:block];
    [_vcProtocols setObject:definition forKey:protocolName];
}

#pragma mark - route

static NSTimeInterval const RouteMinInterval = 1;

- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)fromVC withParams:(AXEData *)params finishBlock:(AXERouterCallbackBlock)block {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert([fromVC isKindOfClass:[UIViewController class]]);
    NSParameterAssert(!params || [params isKindOfClass:[AXEData class]]);
    
    static NSTimeInterval lastRouteTime = 0;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - lastRouteTime < RouteMinInterval) {
        lastRouteTime = now;
        AXELogWarn(@"这里做一个简单防误点的功能， 防止由于系统反应慢，导致用户多次点击按钮，导致页面多次弹出");
        return;
    }
    lastRouteTime = now;
    
    AXERouterRequest *request = [AXERouterRequest requestWithSourceURL:url params:params fromVC:fromVC];
    [_preprocesses enumerateObjectsUsingBlock:^(AXERouterPreprocessBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
        block(request);
    }];
    if ([request checkRequestIsValid]) {
        [self routeRequest:request withCallBack:(AXERouterCallbackBlock)block];
    }
}

- (void)routeRequest:(AXERouterRequest *)request withCallBack:(AXERouterCallbackBlock)block {
    // 首先查看协议。
    if ([request.protocol isEqualToString:AXERouterDefaultProtocolName]) {
        // 如果是axe协议
        AXERouterDefinition *definition = _routes[request.pagePath];
        if (!definition) {
            AXELogWarn(@"当前未支持路由跳转链接 %@",request.formedURL);
        }else {
            [definition excuteWithFromVC:request.fromVC params:request.params callbackBlock:block];
        }
    }else {
        // 在协议注册中寻找
        AXERouterProtocolDefinition *definition = _protocols[request.protocol];
        if (!definition) {
            AXELogWarn(@"当前未支持协议 %@",request.protocol);
        }else{
            [definition excuteWithFromVC:request.fromVC params:request.params callbackBlock:block sourceURL:request.redirectURL ? : request.sourceURL];
        }
    }
}

- (void)routeURL:(NSString *)url fromViewController:(UIViewController *)vc {
    return [self routeURL:url fromViewController:vc withParams:nil finishBlock:nil];
}

- (UIViewController *)viewControllerForRouterURL:(NSString *)url params:(AXEData *)params {
    NSParameterAssert([url isKindOfClass:[NSString class]]);
    NSParameterAssert(!params || [params isKindOfClass:[NSDictionary class]]);
    
    AXERouterRequest *request = [AXERouterRequest requestWithSourceURL:url params:params fromVC:nil];
    [_preprocesses enumerateObjectsUsingBlock:^(AXERouterPreprocessBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
        block(request);
    }];
    if ([request checkRequestIsValid]) {
        if ([request.protocol isEqualToString:AXERouterDefaultProtocolName]) {
            // 如果是axe协议
            AXERouterDefinition *definition = _vcRoutes[request.pagePath];
            if (!definition) {
                AXELogWarn(@"当前未支持路由跳转链接 %@",request.formedURL);
                return nil;
            }else {
                return [definition getViewControllerWithParams:request.params];
            }
        }else {
            // 在协议注册中寻找
            AXERouterProtocolDefinition *definition = _vcProtocols[request.protocol];
            if (!definition) {
                AXELogWarn(@"当前未支持协议 %@",request.protocol);
                return nil;
            }else{
                return [definition getViewControllerWithParams:request.params sourceURL:request.sourceURL];
            }
        }
    }else {
        AXELogWarn(@"当前 request : %@ 检测失败 ，无法跳转",request);
        return nil;
    }
}


- (void)addPreprocess:(AXERouterPreprocessBlock)block {
    NSParameterAssert(block);
    
    [_preprocesses addObject:[block copy]];
}

@end


// 默认协议名称为 axe 。
NSString *AXERouterDefaultProtocolName = @"axe";
