//
//  AXETabBarItem.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXETabBarItem.h"

@interface AXETabBarItem()

@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *viewRoute;
@end

@implementation AXETabBarItem

+ (instancetype)itemWithPath:(NSString *)path viewRoute:(NSString *)viewRoute {
    NSParameterAssert([path isKindOfClass:[NSString class]]);
    NSParameterAssert([viewRoute isKindOfClass:[NSString class]]);
    
    AXETabBarItem *item = [[AXETabBarItem alloc] init];
    item.path = path;
    item.viewRoute = viewRoute;
    return item;
}

@end
