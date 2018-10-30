//
//  AXEBasicTypeData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEBasicDataItem.h"

@interface AXEBasicDataItem ()
@property (nonatomic,assign) AXEDataBasicType basicType;
@end

@implementation AXEBasicDataItem

+ (instancetype)basicDataWithNumber:(NSNumber *)number {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:[number copy]];
    data.basicType = AXEDataBasicTypeNumber;
    return data;
}


+ (instancetype)basicDataWithString:(NSString *)string {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:[string copy]];
    data.basicType = AXEDataBasicTypeString;
    return data;
}

+ (instancetype)basicDataWithArray:(NSArray *)array {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:[array copy]];
    data.basicType = AXEDataBasicTypeArray;
    return data;
}

+ (instancetype)basicDataWithDictionary:(NSDictionary *)dictionary {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:[dictionary copy]];
    data.basicType = AXEDataBasicTypeDictionary;
    return data;
}


+ (instancetype)basicDataWithImage:(UIImage *)image {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:image];
    data.basicType = AXEDataBasicTypeUIImage;
    return data;
}


+ (instancetype)basicDataWithBoolean:(BOOL)boolean {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:@(boolean)];
    data.basicType = AXEDataBasicTypeBoolean;
    return data;
}

+ (instancetype)basicDataWithData:(NSData *)data {
    AXEBasicDataItem *d = [AXEBasicDataItem dataWithValue:data];
    d.basicType = AXEDataBasicTypeData;
    return d;
}

+ (instancetype)basicDataWithDate:(NSDate *)date {
    AXEBasicDataItem *data = [AXEBasicDataItem dataWithValue:date];
    data.basicType = AXEDataBasicTypeDate;
    return data;
}

@end
