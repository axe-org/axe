//
//  AXEData+JavaScriptSupport.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEData+JavaScriptSupport.h"
#import "AXEJavaScriptModelData.h"
#import "AXEDefines.h"
#import "AXEBasicTypeData.h"


@implementation AXEData(JavaScriptSupport)

- (void)setJavascriptData:(NSDictionary *)data forKey:(NSString *)key{
    if ([data isKindOfClass:[NSDictionary class]] && [key isKindOfClass:[NSString class]]) {
        AXELogTrace(@"javaScript设置AXEData %@",data);
        NSString *value = [data objectForKey:@"value"];
        NSString *type = [data objectForKey:@"type"];
        AXEBaseData *saved;
        if ([type isEqualToString:@"Number"]) {
            saved = [AXEBasicTypeData basicDataWithNumber:[NSDecimalNumber decimalNumberWithString:value]];
        }else if ([type isEqualToString:@"String"]) {
            saved = [AXEBasicTypeData basicDataWithString:value];
        }else if ([type isEqualToString:@"Array"]) {
            NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSArray *list = [NSJSONSerialization JSONObjectWithData:valueData options:0 error:&error];
            if (error || ![list isKindOfClass:[NSArray class]]) {
                AXELogWarn(@" 设置AXEData， 设定类型为Array,但是当前数据格式校验错误 。 数据为 %@",data);
                return;
            }
            saved = [AXEBasicTypeData basicDataWithArray:list];
        }else if ([type isEqualToString:@"Object"]) {
            NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:valueData options:0 error:&error];
            if (error || ![dic isKindOfClass:[NSDictionary class]]) {
                AXELogWarn(@" 设置AXEData， 设定类型为Object,但是当前数据格式校验错误 。 数据为 %@",data);
                return;
            }
            saved = [AXEBasicTypeData basicDataWithDictionary:dic];
        }else if([type isEqualToString:@"Image"]) {
            NSData *reserved = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if ([reserved isKindOfClass:[NSData class]]) {
                saved = [AXEBasicTypeData basicDataWithImage:[UIImage imageWithData:reserved]];
            }
        }else if ([type isEqualToString:@"Data"]) {
            NSData *reserved = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if ([reserved isKindOfClass:[NSData class]]) {
                saved = [AXEBasicTypeData basicDataWithData:reserved];
            }
        }else if ([type isEqualToString:@"Date"]) {
            long long time = [value longLongValue];
            NSTimeInterval timeInterval = time / 1000.;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            saved = [AXEBasicTypeData basicDataWithDate:date];
        }else if ([type isEqualToString:@"Boolean"]) {
            BOOL boo = [value boolValue];
            saved = [AXEBasicTypeData basicDataWithBoolean:boo];
        }
        if (saved) {
            [self.storedDatas setObject:saved forKey:key];
            return;
        }
        if ([type isEqualToString:@"Model"]) {
            // model 类型。 还要再特殊处理一下
            NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:valueData options:0 error:&error];
            if (error || ![dic isKindOfClass:[NSDictionary class]]) {
                AXELogWarn(@" 设置AXEData， 设定类型为Model,但是当前数据格式校验错误 。 数据为 %@",data);
                return;
            }
            AXEModelTypeData *currentModelData = (AXEModelTypeData *)[self sharedDataForKey:key];
            if ([currentModelData isMemberOfClass:[AXEModelTypeData class]]) {
                // 如果当前 已有属性， 且为model类型， 则直接在上面进行修改操作.
                // 删除 原来字典中的空值，以避免出错。
                NSMutableDictionary *newModel = [dic copy];
                [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSNull class]]) {
                        [newModel removeObjectForKey:key];
                    }
                }];
                id<AXEDataModelProtocol> currentModel = currentModelData.value;
                [currentModel axe_modelSetWithJSON:[newModel copy]];
            }else {
                // 否则为 当前无model， 或者是 js的model， 则创建一个新的jsmodel.
                AXEJavaScriptModelData *modelData = [AXEJavaScriptModelData javascriptModelWithValue:dic];
                [self.storedDatas setObject:modelData forKey:key];
            }
        }
    }
}


- (NSDictionary *)javascriptDataForKey:(NSString *)key {
    if (![key isKindOfClass:[NSString class]]) {
        return nil;
    }
    AXEBaseData *data = [self.storedDatas objectForKey:key];
    if (!data) {
        return nil;
    }
    NSMutableDictionary *javascriptData = [[NSMutableDictionary alloc] initWithCapacity:2];
    // 检测数据类型，并做相应的转换。
    if ([data isKindOfClass:[AXEBasicTypeData class]]) {
        // 基础数据类型。
        AXEDataBasicType type = [(AXEBasicTypeData *)data basicType];
        if (type == AXEDataBasicTypeNumber) {
            javascriptData[@"type"] = @"Number";
            javascriptData[@"value"] = [data.value stringValue];
        }else if (type == AXEDataBasicTypeString) {
            javascriptData[@"type"] = @"String";
            javascriptData[@"value"] = data.value;
        }else if (type == AXEDataBasicTypeArray) {
            javascriptData[@"type"] = @"Array";
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data.value options:0 error:&error];
            if (error) {
                AXELogWarn(@" javascript 所需要的 Array类型，必须能转换为json， 当前json转换出错 %@",error);
                return nil;
            }
            javascriptData[@"value"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }else if (type == AXEDataBasicTypeDictionary) {
            javascriptData[@"type"] = @"Object";
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data.value options:0 error:&error];
            if (error) {
                AXELogWarn(@" javascript 所需要的 Object类型，必须能转换为json， 当前json转换出错 %@",error);
                return nil;
            }
            javascriptData[@"value"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }else if (type == AXEDataBasicTypeUIImage) {
            javascriptData[@"type"] = @"Image";
            UIImage *image = data.value;
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8);// 默认0.8
            NSString *base64Data = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            javascriptData[@"value"] = base64Data;
        }else if (type == AXEDataBasicTypeData) {
            javascriptData[@"type"] = @"Data";
            javascriptData[@"value"] = [data.value base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }else if (type == AXEDataBasicTypeDate) {
            javascriptData[@"type"] = @"Date";
            NSDate *date = data.value;
            long long value = [date timeIntervalSince1970] * 1000;
            javascriptData[@"value"] = [@(value) stringValue];
        }else if (type == AXEDataBasicTypeBoolean) {
            javascriptData[@"type"] = @"Boolean";
            javascriptData[@"value"] = [data.value boolValue] ? @"true":@"false";
        }
    }else if ([data isKindOfClass:[AXEModelTypeData class]]) {
        // model类型。
        javascriptData[@"type"] = @"Model";
        id<AXEDataModelProtocol> model = data.value;
        NSDictionary *modeDict = [model axe_modelToJSONObject];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modeDict options:0 error:&error];
        if (error) {
            AXELogWarn(@" javascript 所需要的 Model类型，必须能转换为json， 当前json转换出错 %@",error);
            return nil;
        }
        javascriptData[@"value"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return javascriptData;
}


+ (NSDictionary *)javascriptDataFromAXEData:(AXEData *)data {
    if ([data isKindOfClass:[AXEData class]]) {
        NSMutableDictionary *javascriptData = [[NSMutableDictionary alloc] init];
        [data.storedDatas enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, AXEBaseData * _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *singleData = [data javascriptDataForKey:key];
            if (singleData) {
                [javascriptData setObject:singleData forKey:key];
            }
        }];
        return javascriptData;
    }else {
        return  nil;
    }
}

+ (AXEData *)axeDataFromJavascriptData:(NSDictionary *)javascriptData {
    if ([javascriptData isKindOfClass:[NSDictionary class]]) {
        AXEData *data = [AXEData dataForTransmission];
        [javascriptData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [data setJavascriptData:obj forKey:key];
        }];
        return data;
    }
    return nil;
}

@end
