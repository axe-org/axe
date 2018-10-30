//
//  AXEData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXEDataItem.h"


/**
 Data : 数据模块， 解决跨模块数据传递的问题。
  Data有两种用法 ：
 1. 共享数据，  设置一个单例来存储多模块共享的数据。
 2. 数据传输， 可以在 Event上附带数据，也可以在 Router的跳转和回调上附带数据。
 
 Data 目前支持以下数据类型 ：
 
 1. NSNumber
 2. NSString
 3. NSArray : 需要说明， 如果要做到跨语言共享，则不能包含非基础类型 （基础类型为 NSNumber,NSString,NSArray,NSDictionary）
 4. NSDictionary :  需要说明， 如果要做到跨语言共享，则不能包含非基础类型
 
 5. UIImage: 最常见也是最需要的 非常规对象
 6. NSData
 7. NSDate
 8. BOOL
 
 9。 Model： 在Axe中提及的 Model类型，指可以进行序列化，且一般由后台获取的Model类型。
        Model类型的要求 ： 如果是要做到跨语言共享，即与JS模块交互，则要求这类Model只能支持 基础类型。 如果只是原生模块共享，则无这个限制。
        Model类型的放置 ： 要视该 Model的管理模块的数量，如果一个Model只由一个模块创建，则应该归该模块所有。 如果这个Model可以由多个模块创建，或者所有模块都依赖（如用户信息相关的Model）, 则应该放到 公共业务部分。
 */
@interface AXEData : NSObject


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
  提供一个特殊的方法，用于设置 bool 值。

 @param boo BOOL
 @param key 键值。
 */
- (void)setBool:(BOOL)boo forKey:(NSString *)key;

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
- (AXEDataItem *)dataForKey:(NSString *)key;

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
 根据键值 ，获取一个 NSData.
 */
- (NSData *)NSDataForKey:(NSString *)key;

/**
 根据键值 ，获取一个 NSDate.
 */
- (NSDate *)dateForKey:(NSString *)key;

/**
 根据键值 ，获取一个 bool值.
  如果key 不存在，则返回 false.
 */
- (BOOL)boolForKey:(NSString *)key;

/**
 根据键值， 获取一个 Model类型。
 */
- (id)modelForKey:(NSString *)key;

@end
