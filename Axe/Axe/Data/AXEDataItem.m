//
//  AXEBaseData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEDataItem.h"


@interface AXEDataItem()
@property (nonatomic,strong) id value;
@end

@implementation AXEDataItem

+ (instancetype)dataWithValue:(id)value {
    AXEDataItem *data = [[self alloc] init];
    data.value = value;
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ , value : %@" , NSStringFromClass([self class]),_value];
}

@end
