//
//  AXEModelTypeData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXEBaseData.h"



/**
  model 协议， 存储的model类型，需要满足这个协议，以进行 序列化和反序列化。
 */
@protocol AXEDataModelProtocol <NSObject>

/**
  使用一个json来 重置model
 */
- (void)axe_modelSetWithJSON:(NSDictionary *)json;
/**
  model类型，必须支持能够转换成一个 json类型, 而且是map类型，不能是其他类型。
 */
- (NSDictionary *)axe_modelToJSONObject;

@end

/**
  model类型的基础数据。
 */
@interface AXEModelTypeData : AXEBaseData



/**
 实例方法。

 @param value model
 @return 实例。
 */
+ (instancetype)modelDataWithValue:(id<AXEDataModelProtocol>)value;

@end


