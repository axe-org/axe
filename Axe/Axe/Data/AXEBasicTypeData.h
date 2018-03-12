//
//  AXEBasicTypeData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEBaseData.h"

@class UIImage;
// 基础数据类型， 再继续细分。
typedef NS_ENUM(NSUInteger, AXEDataBasicType) {
    AXEDataBasicTypeNumber,// 数据类型只能存 number 类型， 其他的 int ,bool,float都需要转换成number.
    AXEDataBasicTypeString, // 字符串类型
    AXEDataBasicTypeArray, // 数组类型 ,
    AXEDataBasicTypeDictionary,// 字典类型
    // 以上是基础类型。
    // 以下是比较特殊的类型。
    AXEDataBasicTypeUIImage, // 支持图像类型。
    AXEDataBasicTypeBoolean, // bool 类型
    AXEDataBasicTypeData , // NSData 类型
    AXEDataBasicTypeDate , // NSDate类型
};
// 注意， 容器类型，字典和数组， 不支持Model类型，只能放基础数据类型。
// 注意 ， 如果 NSArray 和 NSDictionary中放嵌套的model类型， 正常在原生代码中没有问题，但是传递给js时会导致异常。
/**
  基础数据类型的data
 */
@interface AXEBasicTypeData : AXEBaseData


/**
  基础数据类型
 */
@property (nonatomic,readonly,assign) AXEDataBasicType basicType;

/**
  实例方法
 */
+ (instancetype)basicDataWithNumber:(NSNumber *)number;


/**
 实例方法
 */
+ (instancetype)basicDataWithString:(NSString *)string;


/**
 实例方法
 */
+ (instancetype)basicDataWithArray:(NSArray *)array;

/**
 实例方法
 */
+ (instancetype)basicDataWithDictionary:(NSDictionary *)dictionary;


/**
 实例方法
 */
+ (instancetype)basicDataWithImage:(UIImage *)image;

/**
 实例方法
 */
+ (instancetype)basicDataWithBoolean:(BOOL)boolean;

/**
 实例方法
 */
+ (instancetype)basicDataWithData:(NSData *)data;

/**
 实例方法
 */
+ (instancetype)basicDataWithDate:(NSDate *)date;

@end
