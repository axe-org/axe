//
//  AXEData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEData.h"
#import "AXEBaseData.h"
#import "AXEBasicTypeData.h"
#import "AXEModelTypeData.h"
#import "AXEDefines.h"

@interface AXEData()

@property (nonatomic,strong) NSMutableDictionary<NSString *,AXEBaseData *> *storedDatas;

@end

@implementation AXEData

+ (instancetype)sharedData {
    static AXEData *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AXEData alloc] init];
        instance.storedDatas = [[NSMutableDictionary alloc] initWithCapacity:100];
    });
    return instance;
}

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
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithNumber:data] forKey:key];
    }else if ([data isKindOfClass:[NSString class]]) {
        AXELogTrace(@"存储NSString : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithString:data] forKey:key];
    }else if ([data isKindOfClass:[NSArray class]]) {
        AXELogTrace(@"存储NSArray : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithArray:data] forKey:key];
    }else if([data isKindOfClass:[NSDictionary class]]) {
        AXELogTrace(@"存储NSDictionary : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithDictionary:data] forKey:key];
    }else if ([data isKindOfClass:[UIImage class]]) {
        AXELogTrace(@"存储UIImage : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithImage:data] forKey:key];
    }else if ([data isKindOfClass:[NSData class]]) {
        AXELogTrace(@"存储NSData : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithData:data] forKey:key];
    }else if ([data isKindOfClass:[NSDate class]]) {
        AXELogTrace(@"存储NSDate : %@ = %@",key,data);
        [_storedDatas setObject:[AXEBasicTypeData basicDataWithDate:data] forKey:key];
    }else if ([data conformsToProtocol:@protocol(AXEDataModelProtocol)] ) {
        AXELogTrace(@"存储Model : %@ = %@",key,data);
        [_storedDatas setObject:[AXEModelTypeData modelDataWithValue:data] forKey:key];
    }else {
        AXELogWarn(@"检测数据不合法 , %@ : %@！！！",key,data);
    }
}

- (void)setBool:(BOOL)boo forKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXELogTrace(@"存储Boolean ： %@ = %@",key,boo ? @"true" : @"false");
    [_storedDatas setObject:[AXEBasicTypeData basicDataWithBoolean:boo] forKey:key];
}

- (void)removeDataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXELogTrace(@"删除数据 %@ ",key);
    [_storedDatas removeObjectForKey:key];
}

- (AXEBaseData *)dataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    return [_storedDatas objectForKey:key];
}


- (NSNumber *)numberForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSNumber *value = data.value;
    if (value && ![value isKindOfClass:[NSNumber class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSNumber ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSString *)stringForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSString *value = data.value;
    if (value && ![value isKindOfClass:[NSString class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSString ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSArray *value = data.value;
    if (value && ![value isKindOfClass:[NSArray class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSArray ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSDictionary *value = data.value;
    if (value && ![value isKindOfClass:[NSDictionary class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSDictionary ,值为 %@",key,value);
        return nil;
    }
    return value;
}

- (UIImage *)imageForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    UIImage *value = data.value;
    if (value && ![value isKindOfClass:[UIImage class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 UIImage ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (NSData *)NSDataForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSData *value = data.value;
    if (value && ![value isKindOfClass:[NSData class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSData ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (NSDate *)dateForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    NSDate *value = data.value;
    if (value && ![value isKindOfClass:[NSDate class]]) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 NSDate ,值为 %@",key,value);
        return nil;
    }
    return value;
}


- (BOOL)boolForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBasicTypeData *data = (AXEBasicTypeData *)[_storedDatas objectForKey:key];
    NSNumber *value = data.value;
    if (data && data.basicType != AXEDataBasicTypeBoolean) {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 Boolean ,值为 %@",key,value);
        return false;
    }
    return [value boolValue];
}


- (id)modelForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEBaseData *data = [_storedDatas objectForKey:key];
    if (!data) {
        AXELogTrace(@" 未查到 key值为 %@ 的model数据",key);
        return nil;
    }
    if ([data isKindOfClass:[AXEModelTypeData class]]) {
        return data.value;
    }else {
        AXELogWarn(@" 查找共享数据 key : %@ , 但是数据格式不是 Model类型 ,值为 %@",key,data.value);
        return nil;
    }
}

@end
