//
//  AXEModelTypeData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEModelTypeData.h"

@implementation AXEModelTypeData

+ (instancetype)modelDataWithValue:(id<AXEDataModelProtocol>)value {
    AXEModelTypeData *data = [AXEModelTypeData dataWithValue:value];
    return data;
}

@end
