//
//  AXEGround.m
//  Ground
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEGround.h"
#import "Axe.h"

@implementation AXEGround

+ (void)setup {
    [[AXERouter sharedRouter] registerPagePath:@"hello" withRouterBlock:^(UIViewController *fromVC, NSDictionary *params, AXERouterCallbackBlock callback) {
        NSLog(@"fucku");
    }];
}

@end
