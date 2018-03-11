//
//  AXEData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEBaseData.h"
@class UIImage;

/**
  提供公共数据共享， 以及供axe系统使用的数据类型。
 */
@interface AXEData : NSObject

/**
  共享的公共数据。 单例。
 */
+ (instancetype)sharedData;


/**
  创建用于传输数据的data实例 。工厂方法

 @return 传输数据， 用于 事件和路由时传递数据。
 */
+ (instancetype)dataForTransmission;

/**
  设置数据时， 不需要指定数据类型。
 
 @param data 需要存储的数据 ， 如果是 model类型，就必须要满足 AXEDataModelProtocol
 @param key 键值
 */
- (void)setData:(id)data forKey:(NSString *)key;


/**
  删除共享数据

 @param key 键值。
 */
- (void)removeDataForKey:(NSString *)key;

/**
  获取数据时， 可以不指定数据类型。但是需要判断数据类型， 以避免出错。
 @param key 键值
 @return 如果当前有数据，则返回。一定要判断数据类型，避免处理出错。
 */
- (AXEBaseData *)sharedDataForKey:(NSString *)key;

/**
  根据键值， 获取一个 NSNumber
 */
- (NSNumber *)numberForKey:(NSString *)key;
/**
 根据键值， 获取一个 NSString
 */
- (NSString *)stringForKey:(NSString *)key;
/**
 根据键值， 获取一个 NSArray
 */
- (NSArray *)arrayForKey:(NSString *)key;
/**
 根据键值， 获取一个 NSDictionary
 */
- (NSDictionary *)dictionaryForKey:(NSString *)key;

/**
    根据键值 ，获取一个 UIImage.
 */
- (UIImage *)imageForKey:(NSString *)key;

/**
 根据键值， 获取一个 Model类型。
 */
- (id)modelForKey:(NSString *)key;

@end
