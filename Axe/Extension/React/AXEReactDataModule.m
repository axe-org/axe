//
//  AXEReactDataModule.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactDataModule.h"
#import <React/RCTConvert.h>
#import "AXEData+JavaScriptSupport.h"
#import "AXELog.h"
#import "AXEDataCenter.h"

@implementation AXEReactDataModule
RCT_EXPORT_MODULE(axe_data);



RCT_EXPORT_METHOD(setData:(NSDictionary *)param){
    if ([param isKindOfClass:[NSDictionary class]]) {
        [[AXEDataCenter sharedDataCenter] setJavascriptDataItem:param forKey:[param objectForKey:@"key"]];
    } else {
        AXELogWarn(@"param 需要为 NSDictionary类型！");
    }
}

RCT_EXPORT_METHOD(removeData:(NSString *)key){
    if ([key isKindOfClass:[NSString class]]) {
        [[AXEDataCenter sharedDataCenter] removeDataForKey:key];
    } else {
        AXELogWarn(@"key 需要为 NSString 类型！");
    }
    
}


RCT_EXPORT_METHOD(getData:(NSString *)key callback:(RCTResponseSenderBlock)callback) {
    if ([key isKindOfClass:[NSString class]]) {
        NSDictionary *data = [[AXEDataCenter sharedDataCenter] javascriptDataForKey:key];
        NSArray *response;
        if (data) {
            response = @[data];
        }
        callback(response);
    } else {
        AXELogWarn(@"key 需要为 NSString 类型！");
    }
}

@end
