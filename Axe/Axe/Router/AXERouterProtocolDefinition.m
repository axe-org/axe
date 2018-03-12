//
//  AXERouterProtocolDefinition.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXERouterProtocolDefinition.h"

@interface AXERouterProtocolDefinition()

@property (nonatomic,copy) NSString *protocol;

@property (nonatomic,copy) AXEProtoclRouterBlock block;

@property (nonatomic,copy) AXEProtoclRouteForVCBlock getVCBlock;

@property (nonatomic,assign) NSInteger calledTime;

@end

@implementation AXERouterProtocolDefinition

+ (instancetype)definitionWithProtocol:(NSString *)protocol block:(AXEProtoclRouterBlock)block {
    AXERouterProtocolDefinition *definition = [[AXERouterProtocolDefinition alloc] init];
    definition.calledTime = 0;
    definition.protocol = protocol;
    definition.block = block;
    return definition;
}

- (void)excuteWithFromVC:(UIViewController *)fromVC
                  params:(AXEData *)params
           callbackBlock:(AXERouterCallbackBlock)callbackBlock
                     URL:(NSString *)url {
    _calledTime ++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_block(fromVC,params,callbackBlock,url);
    });
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<ProtocolRouter %@://>",_protocol];
}


+ (instancetype)definitionWithProtocol:(NSString *)protocol routeForVCBlock:(AXEProtoclRouteForVCBlock)block {
    AXERouterProtocolDefinition *definition = [[AXERouterProtocolDefinition alloc] init];
    definition.calledTime = 0;
    definition.protocol = protocol;
    definition.getVCBlock = block;
    return definition;
}

- (UIViewController *)getViewControllerWithParams:(AXEData *)params
                                              URL:(NSString *)url
                                    callbackBlock:(AXERouterCallbackBlock)callback {
    _calledTime ++;
    return _getVCBlock(url,params,callback);
}

@end
