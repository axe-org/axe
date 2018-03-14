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

@implementation AXEReactDataModule
RCT_EXPORT_MODULE(axe_data);



RCT_EXPORT_METHOD(setData:(NSDictionary *)param){
    NSParameterAssert([param isKindOfClass:[NSDictionary class]]);

    [[AXEData sharedData] setJavascriptData:param forKey:[param objectForKey:@"key"]];
}

RCT_EXPORT_METHOD(removeData:(NSString *)key){
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    [[AXEData sharedData] removeDataForKey:key];
}


RCT_EXPORT_METHOD(getData:(NSString *)key callback:(RCTResponseSenderBlock)callback) {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    NSDictionary *data = [[AXEData sharedData] javascriptDataForKey:key];
    NSArray *response;
    if (data) {
        response = @[data];
    }
    callback(response);
}

@end
