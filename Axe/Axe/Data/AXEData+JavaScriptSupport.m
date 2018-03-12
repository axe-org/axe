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

- (NSDictionary *)javascriptModelForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    AXEModelTypeData *data = (AXEModelTypeData *)[self.storedDatas objectForKey:key];
    if (!data) {
        AXELogTrace(@"当前未找到model ： %@",key);
    }else if ([data isKindOfClass:[AXEModelTypeData class]]) {
        // 进行转换。
        return [data.value axe_modelToJSONObject];
    }else {
        AXELogTrace(@"当前数据格式不正确， 不是AXEModelTypeData 类型 ， key : %@ ,value : %@",key,data);
    }
    return nil;
}


- (void)setJavascriptModel:(NSDictionary *)model forKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    NSParameterAssert([model isKindOfClass:[NSDictionary class]]);
    
    AXEModelTypeData *data = (AXEModelTypeData *)[self.storedDatas objectForKey:key];
    if (!data) {
        AXEJavaScriptModelData *data = [AXEJavaScriptModelData javascriptModelWithValue:model];
        [self.storedDatas setObject:data forKey:key];
    }else if ([data isKindOfClass:[AXEModelTypeData class]]) {
        AXELogTrace(@"修改当前公共数据 %@ ",key);
        // 当前有数据， 进行转换 TODO 测试 NSNULL
        [data.value axe_modelSetWithJSON:model];
    }else {
        AXELogTrace(@"当前数据格式不正确， 不是AXEModelTypeData 类型 ， key : %@ ,value : %@",key,data);
    }
}


- (void)setJavascriptData:(NSDictionary *)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        AXELogTrace(@"javaScript设置共享数据 %@",data);
        NSString *key = [data objectForKey:@"key"];
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
                AXELogWarn(@" 设置共享属性， 设定类型为Array,但是当前数据格式校验错误 。 数据为 %@",data);
                return;
            }
            saved = [AXEBasicTypeData basicDataWithArray:list];
        }else if ([type isEqualToString:@"Object"]) {
            NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:valueData options:0 error:&error];
            if (error || ![dic isKindOfClass:[NSDictionary class]]) {
                AXELogWarn(@" 设置共享属性， 设定类型为Object,但是当前数据格式校验错误 。 数据为 %@",data);
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
                AXELogWarn(@" 设置共享属性， 设定类型为Model,但是当前数据格式校验错误 。 数据为 %@",data);
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

@end
