//
//  AXEData+JavaScriptSupport.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEData.h"


/**
    扩展 AXEData ,以支持 JavaScript中使用 AXEData.
 TODO 修改命名为 serialzation.
 */
@interface AXEData (JavaScriptSupport)

/**
  设置 JavaScriptData
 从 JS传入的是 NSDictionary类型的数据，其中声明了数据的具体类型， 然后转换成原生对应的类型。
 @param data 数据
 */
- (void)setJavascriptDataItem:(NSDictionary *)data forKey:(NSString *)key;


/**
  获取数据，转换成javascript中可以使用的类型。
 @param key 键值
 @return 数据。 可能为空。
 */
- (NSDictionary *)javascriptDataForKey:(NSString *)key;


/**
  将一个 dataItem进行序列化。

 @param item 具体对象
 @return 返回一个序列化后的结果，可以在所有Axe系统中进行传递。
 */
+ (NSDictionary *)serializeJSONFromDataItem:(AXEDataItem *)item;


/**
  将 axedata 转换成 javascript可以理解的格式。
 @param data axedata 不能为空。
 @return 值, 如果解析失败，会返回空值。
 */
+ (NSDictionary *)javascriptDataFromAXEData:(AXEData *)data;


/**
  将 javascript数据转换为 AXEData.
 */
+ (AXEData *)axeDataFromJavascriptData:(NSDictionary *)javascriptData;

@end


