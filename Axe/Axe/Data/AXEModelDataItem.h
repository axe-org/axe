//
//  AXEModelTypeData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXEDataItem.h"



/**
  model类型指的是 可以序列化的，用于前后端交互的 model类型。 所以能做到跨语言跨容器通用。
 
  model 协议， 存储的model类型，需要满足这个协议，以进行 序列化和反序列化。
 */
@protocol AXESerializableModelProtocol <NSObject>

/**
  使用一个json来 重置model。
 进行的是合并操作， 如现有值为 {a: 1,b: 2}
 则我们传入 {b: 3} , 只修改 b的值，不修改a的值。
 */
- (void)axe_modelSetWithJSON:(NSDictionary *)json;
/**
  model类型，必须支持能够转换成一个 json类型, 而且是map类型，不能是其他类型。
 */
- (NSDictionary *)axe_modelToJSONObject;

@end

/**
  model类型数据。
 */
@interface AXEModelDataItem : AXEDataItem



/**
 实例方法。

 @param value model
 @return 实例。
 */
+ (instancetype)modelDataWithValue:(id<AXESerializableModelProtocol>)value;

@end


