//
//  AXEReactEventModule.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/13.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEReactEventModule.h"
#import <React/RCTConvert.h>
#import "AXEData+JavaScriptSupport.h"
#import "AXEData+JavaScriptSupport.h"
#import "AXEReactViewController.h"
#import "AXEReactControllerWrapper.h"
#import <React/RCTBridge.h>
#import "AXELog.h"
#import "AXEEvent.h"

@interface AXEReactEventModule()

@property (nonatomic,strong) AXEReactControllerWrapper *wrapper;
@property (nonatomic,strong) NSMutableDictionary *registeredEvents;
@end

@implementation AXEReactEventModule
RCT_EXPORT_MODULE(axe_event);
@synthesize bridge = _bridge;

- (AXEReactControllerWrapper *)wrapper{
    if (!_wrapper) {
        _wrapper = [self.bridge.launchOptions objectForKey:AXEReactControllerWrapperKey];
    }
    return _wrapper;
}

- (NSMutableDictionary *)registeredEvents {
    if (!_registeredEvents) {
        _registeredEvents = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _registeredEvents;
}

// 注册监听。
RCT_EXPORT_METHOD(registerListener:(NSString *)eventName){
    if ([eventName isKindOfClass:[NSString class]]) {
        if ([self.registeredEvents objectForKey:eventName]) {
            AXELogWarn(@"重复监听 ！！！");
            id<AXEListenerDisposable> disposable = [self.registeredEvents objectForKey:eventName];
            [disposable dispose];
        }
        @weakify(self);
        id disposable = [self.wrapper.controller registerUIEvent:eventName withHandler:^(AXEData *payload) {
            @strongify(self);
            if (!self) {
                AXELogWarn(@"当前页面已释放， 通知还存在，请检测是否存在内存问题！！！");
                return;
            }
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            [post setObject:eventName forKey:@"name"];
            if (payload) {
                // 如果有附带数据，则进行转换。
                NSDictionary *javascriptData = [AXEData javascriptDataFromAXEData:payload];
                if ([javascriptData isKindOfClass:[NSDictionary class]]) {
                    [post setObject:javascriptData forKey:@"payload"];
                }
            }
            [self.bridge enqueueJSCall:@"axe_event" method:@"callback" args:@[post] completion:nil];
        }];
        [self.registeredEvents setObject:disposable forKey:eventName];
    } else {
        AXELogWarn(@"eventName 需要为 NSString 类型！");
    }
}



RCT_EXPORT_METHOD(removeListener:(NSString *)eventName){
    if ([eventName isKindOfClass:[NSString class]]) {
        id<AXEListenerDisposable> disposable = self.registeredEvents[eventName];
        if (disposable) {
            [self.registeredEvents removeObjectForKey:eventName];
            [disposable dispose];
        }
    } else {
        AXELogWarn(@"eventName 需要为 NSString 类型！");
    }
    
}

RCT_EXPORT_METHOD(postEvent:(NSDictionary *)event){
    if ([event isKindOfClass:[NSDictionary class]]) {
        NSDictionary *payload = [event objectForKey:@"data"];
        AXEData *payloadData;
        if (payload) {
            payloadData = [AXEData axeDataFromJavascriptData:payload];
        }
        [AXEEvent postEventName:[event objectForKey:@"name"] withPayload:payloadData];
    } else {
        AXELogWarn(@"event 需要为 NSDictionary 类型！");
    }
    
}

@end
