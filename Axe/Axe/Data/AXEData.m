//
//  AXEData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEData.h"
#import "AXEDataItem.h"
#import "AXEBasicDataItem.h"
#import "AXEModelDataItem.h"
#import "AXELog.h"

@interface AXEData()

@property (nonatomic, strong) NSMutableDictionary<NSString *,AXEDataItem *> *storedDatas;
@end

@implementation AXEData


+ (instancetype)dataForTransmission {
    AXEData *data = [[AXEData alloc] init];
    data.storedDatas = [[NSMutableDictionary alloc] init];
    return data;
}

- (void)setData:(id)data forKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    NSParameterAssert(data);
    if ([data isKindOfClass:[NSNumber class]]) {
        AXELogTrace(@"存储NSNumber : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithNumber:data] forKey:key];
    }else if ([data isKindOfClass:[NSString class]]) {
        AXELogTrace(@"存储NSString : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithString:data] forKey:key];
    }else if ([data isKindOfClass:[NSArray class]]) {
        AXELogTrace(@"存储NSArray : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithArray:data] forKey:key];
    }else if([data isKindOfClass:[NSDictionary class]]) {
        AXELogTrace(@"存储NSDictionary : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithDictionary:data] forKey:key];
    }else if ([data isKindOfClass:[UIImage class]]) {
        AXELogTrace(@"存储UIImage : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithImage:data] forKey:key];
    }else if ([data isKindOfClass:[NSData class]]) {
        AXELogTrace(@"存储NSData : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithData:data] forKey:key];
    }else if ([data isKindOfClass:[NSDate class]]) {
        AXELogTrace(@"存储NSDate : %@ = %@",key,data);
        [self _setData:[AXEBasicDataItem basicDataWithDate:data] forKey:key];
    }else if ([data conformsToProtocol:@protocol(AXESerializableModelProtocol)] ) {
        AXELogTrace(@"存储Model : %@ = %@",key,data);
        [self _setData:[AXEModelDataItem modelDataWithValue:data] forKey:key];
    }else {
        AXELogWarn(@"检测数据不合法 , %@ : %@！！！",key,data);
    }
}

- (void)setBool:(BOOL)boo forKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXELogTrace(@"存储Boolean ： %@ = %@",key,boo ? @"true" : @"false");
    [self _setData:[AXEBasicDataItem basicDataWithBoolean:boo] forKey:key];
}

- (void)removeDataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    AXELogTrace(@"删除数据 %@ ",key);
    [_storedDatas removeObjectForKey:key];
}

- (AXEDataItem *)dataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    return [self _getDataForKey:key];
}


- (NSNumber *)numberForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSNumber *value = data.value;
    if (value && ![value isKindOfClass:[NSNumber class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSNumber ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSString *)stringForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSString *value = data.value;
    if (value && ![value isKindOfClass:[NSString class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSString ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSArray *value = data.value;
    if (value && ![value isKindOfClass:[NSArray class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSArray ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSDictionary *value = data.value;
    if (value && ![value isKindOfClass:[NSDictionary class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSDictionary ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (UIImage *)imageForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    UIImage *value = data.value;
    if (value && ![value isKindOfClass:[UIImage class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 UIImage ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (NSData *)NSDataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSData *value = data.value;
    if (value && ![value isKindOfClass:[NSData class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSData ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (NSDate *)dateForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];
    NSDate *value = data.value;
    if (value && ![value isKindOfClass:[NSDate class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSDate ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (BOOL)boolForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBasicDataItem *data = (AXEBasicDataItem *)[self _getDataForKey:key];;
    NSNumber *value = data.value;
    if (data && data.basicType != AXEDataBasicTypeBoolean) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 Boolean ,值为 %@",key,value);
        return false;
    }
    return [value boolValue];
}


- (id)modelForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEDataItem *data = [self _getDataForKey:key];;
    if (!data) {
        AXELogTrace(@" 未查到 key值为 %@ 的model数据",key);
        return nil;
    }
    if ([data isKindOfClass:[AXEModelDataItem class]]) {
        return data.value;
    }else {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 Model类型 ,值为 %@",key,data.value);
        return nil;
    }
}

#pragma mark - private

- (void)_setData:(AXEDataItem *)data forKey:(NSString *)key {
    [_storedDatas setObject:data forKey:key];
}

- (AXEDataItem *)_getDataForKey:(NSString *)key {
    AXEDataItem *data = [_storedDatas objectForKey:key];
    return data;
}

@end
