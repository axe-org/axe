//
//  AXEModelTypeData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEModelDataItem.h"

@implementation AXEModelDataItem

+ (instancetype)modelDataWithValue:(id<AXESerializableModelProtocol>)value {
    AXEModelDataItem *data = [AXEModelDataItem dataWithValue:value];
    return data;
}

@end
