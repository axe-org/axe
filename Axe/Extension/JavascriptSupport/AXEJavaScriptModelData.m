//
//  AXEJavaScriptModelData.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEJavaScriptModelData.h"
#import <objc/runtime.h>
#import "AXELog.h"


/**
  封装真实数据， 同时提供get set 接口，供外部调用， 以模拟真实的model类型。
   TODO 添加 performToSelector支持， 以提高稳定性。
 */
@interface AXEJavaScriptModelWrapper : NSObject <AXESerializableModelProtocol>


+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic,strong) NSMutableDictionary *axe_dictionary;



@end


@implementation AXEJavaScriptModelWrapper

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    AXEJavaScriptModelWrapper *wrapper = [[AXEJavaScriptModelWrapper alloc] init];
    wrapper.axe_dictionary = [dictionary mutableCopy];
    return wrapper;
}


- (void)axe_modelSetWithJSON:(NSDictionary *)json {
    _axe_dictionary = [json mutableCopy];
}

- (NSDictionary *)axe_modelToJSONObject {
    return [_axe_dictionary copy];
}


- (id)objectForKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    id object = [_axe_dictionary objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) {
        // 注意处理 NSNull
        return nil;
    }
    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    
    if ([_axe_dictionary objectForKey:key]) {
        if (object == nil) {
            // 设置值为空时， 我们实际设置的是 NSNull类型，通过NSNull以记住完成的model结构。
            [_axe_dictionary setObject:[NSNull null] forKey:key];
        }else {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]
                || [object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                [_axe_dictionary setObject:object forKey:key];
            }else {
                AXELogWarn(@" 对 javascriptModel 设置非基础数据类型 , %@ = %@",key,object);
            }
            
        }
    }else {
        AXELogTrace(@"当前没找到对应 key : %@",key);
    }
}

// 通过 OC的动态性，将JavaScriptModel 伪装成一个 model类型， 进行get set操作。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *selectorName = NSStringFromSelector(selector);
    if ([selectorName hasPrefix:@"set"] && selectorName.length > 4) {
        // set 方法
        NSString *ivarName = [selectorName substringWithRange:NSMakeRange(3, selectorName.length - 4)];
        ivarName = [ivarName lowercaseString];
        id item = [_axe_dictionary objectForKey:ivarName];
        if (item) {
            NSMethodSignature *signature = [AXEJavaScriptModelWrapper instanceMethodSignatureForSelector:@selector(setObject:forKey:)];
            return signature;
        }
    }else {
        // get 方法。
        NSString *ivarName = selectorName;
        id item = [_axe_dictionary objectForKey:ivarName];
        if (item ) {
            NSMethodSignature *signature = [AXEJavaScriptModelWrapper instanceMethodSignatureForSelector:@selector(objectForKey:)];
            return signature;
        }
    }
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (invocation) {
        NSString *selectorName = NSStringFromSelector(invocation.selector);
        if ([selectorName hasPrefix:@"set"] && selectorName.length > 3) {
            // set 方法
            NSString *ivarName = [selectorName substringWithRange:NSMakeRange(3, selectorName.length - 4)];
            ivarName = [ivarName lowercaseString];
            id item = [_axe_dictionary objectForKey:ivarName];
            if (item) {
                // 如果找到方法。
                invocation.selector = @selector(setObject:forKey:);
                // 0: self, 1:cmd, 2:value , 3:ivarName/key
                [invocation setArgument:&ivarName atIndex:3];
                [invocation invoke];
            }
        }else {
            // get 方法。
            NSString *ivarName = selectorName;
            id item = [_axe_dictionary objectForKey:ivarName];
            if (item ) {
                invocation.selector = @selector(objectForKey:);
                [invocation setArgument:&ivarName atIndex:2];
                [invocation invoke];
            }
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@" <AXEJavaScriptModelWrapper> : %@" ,_axe_dictionary];
}

@end


@implementation AXEJavaScriptModelData

+ (instancetype)javascriptModelWithValue:(NSDictionary *)value {
    AXEJavaScriptModelWrapper *wrapper = [AXEJavaScriptModelWrapper modelWithDictionary:value];
    AXEJavaScriptModelData *data = [AXEJavaScriptModelData dataWithValue:wrapper];
    return data;
}



@end
