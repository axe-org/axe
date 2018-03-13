//
//  AXEData+JavaScriptSupport.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEData.h"

@interface AXEData(JavaScriptSupportPrivate)

@property (nonatomic,strong) NSMutableDictionary<NSString *,AXEBaseData *> *storedDatas;
@end

/**
 支持 javascript。
 */
@interface AXEData (JavaScriptSupport)


/**
  封装 js的设置方法， 规定好交互逻辑

 @param data 数据
 */
- (void)setJavascriptData:(NSDictionary *)data forKey:(NSString *)key;


/**
  获取数据，并做转换，以支持传入 javascript中供调用

 @param key 键值
 @return 数据。 可能为空。
 */
- (NSDictionary *)javascriptDataForKey:(NSString *)key;



/**
  将 axedata 转换成 javascript可以理解的格式。

 @param data axedata 不能为空。
 @return 值, 如果解析失败，会返回空值。
 */
+ (NSDictionary *)javascriptDataFromAXEData:(AXEData *)data;


/**
  将 javascript数据转换为 AXEData.

 @param javascriptData <#javascriptData description#>
 @return <#return value description#>
 */
+ (AXEData *)axeDataFromJavascriptData:(NSDictionary *)javascriptData;

@end


