//
//  AXEBaseData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEBaseData.h"


@interface AXEBaseData()
@property (nonatomic,strong) id value;
@end

@implementation AXEBaseData

+ (instancetype)dataWithValue:(id)value {
    AXEBaseData *data = [[self alloc] init];
    data.value = value;
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ , value : %@" , NSStringFromClass([self class]),_value];
}

@end
