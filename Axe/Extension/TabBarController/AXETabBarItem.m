//
//  AXETabBarItem.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXETabBarItem.h"

@interface AXETabBarItem()

@property (nonatomic,copy) NSString *pagePath;
@property (nonatomic,copy) NSString *vcRouteURL;
@end

@implementation AXETabBarItem

+ (instancetype)itemWithPagePath:(NSString *)pagePath routURL:(NSString *)routeURL {
    NSParameterAssert([pagePath isKindOfClass:[NSString class]]);
    NSParameterAssert([routeURL isKindOfClass:[NSString class]]);
    
    AXETabBarItem *item = [[AXETabBarItem alloc] init];
    item.pagePath = pagePath;
    item.vcRouteURL = routeURL;
    return item;
}

@end
