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

@interface AXEData(JavaScriptSupportPrivate)

@property (nonatomic,strong) NSMutableDictionary<NSString *,AXEBaseData *> *storedDatas;
@end


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


@end
