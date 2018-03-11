//
//  AXEBasicTypeData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEBasicTypeData.h"

@interface AXEBasicTypeData ()
@property (nonatomic,assign) AXEDataBasicType basicType;
@end

@implementation AXEBasicTypeData

+ (instancetype)basicDataWithNumber:(NSNumber *)number {
    AXEBasicTypeData *data = [AXEBasicTypeData dataWithValue:[number copy]];
    data.basicType = AXEDataBasicTypeNumber;
    return data;
}


+ (instancetype)basicDataWithString:(NSString *)string {
    AXEBasicTypeData *data = [AXEBasicTypeData dataWithValue:[string copy]];
    data.basicType = AXEDataBasicTypeString;
    return data;
}

+ (instancetype)basicDataWithImage:(UIImage *)image {
    AXEBasicTypeData *data = [AXEBasicTypeData dataWithValue:image];
    data.basicType = AXEDataBasicTypeUIImage;
    return data;
}

+ (instancetype)basicDataWithArray:(NSArray *)array {
    AXEBasicTypeData *data = [AXEBasicTypeData dataWithValue:[array copy]];
    data.basicType = AXEDataBasicTypeArray;
    return data;
}

+ (instancetype)basicDataWithDictionary:(NSDictionary *)dictionary {
    AXEBasicTypeData *data = [AXEBasicTypeData dataWithValue:[dictionary copy]];
    data.basicType = AXEDataBasicTypeDictionary;
    return data;
}

@end
