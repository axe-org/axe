//
//  AXERouterDefinition.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouterDefinition.h"

@interface AXERouterDefinition()

@property (nonatomic,copy) NSString *pagePath;

@property (nonatomic,copy) AXERouterBlock block;

@property (nonatomic,copy) AXERouteForVCBlock getVCBlock;

@property (nonatomic,assign) NSInteger calledTime;
@end

@implementation AXERouterDefinition


+ (instancetype)definitionWithPagePath:(NSString *)path block:(AXERouterBlock)block {
    AXERouterDefinition *definition = [[AXERouterDefinition alloc] init];
    definition.calledTime = 0;
    definition.pagePath = path;
    definition.block = block;
    return definition;
}

- (void)excuteWithFromVC:(UIViewController *)fromVC
                  params:(NSDictionary *)params
           callbackBlock:(AXERouterCallbackBlock)callbackBlock {
    _calledTime ++ ;
    dispatch_async(dispatch_get_main_queue(), ^{
        _block(fromVC,params,callbackBlock);
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Router axe://%@>" , _pagePath];
}


+ (instancetype)definitionWithPagePath:(NSString *)path routeForVCBlock:(AXERouteForVCBlock)block {
    AXERouterDefinition *definition = [[AXERouterDefinition alloc] init];
    definition.calledTime = 0;
    definition.pagePath = path;
    definition.getVCBlock = block;
    return definition;
}

- (UIViewController *)getViewControllerWithParams:(NSDictionary *)params {
    _calledTime ++;
    return _getVCBlock(params);
}


@end
