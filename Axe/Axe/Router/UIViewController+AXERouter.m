//
//  UIViewController+AXERouter.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "UIViewController+AXERouter.h"

@implementation UIViewController(AXERouter)

- (void)routeURL:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouterCallbackBlock)block {
    return [[AXERouter sharedRouter] routeURL:url fromViewController:self withParams:params finishBlock:block];
}

- (void)routeURL:(NSString *)url {
    return [[AXERouter sharedRouter] routeURL:url fromViewController:self];
}

@end
