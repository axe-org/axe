//
//  AXEJavaScriptModelData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEModelTypeData.h"
#import "AXEData.h"


/**
 由 JS 创建的model类型的数据。
  js注意， 对于一个模型， 如果有key ,但是当前没值， 也必须使用 null 声明， 原生记录为 NSNull类型。 这样来记录完整的model的结构。
  对于 由 js 共享出去的 model类型， 不支持 NSInterger float等类型， 只支持基础类型 ，即 NSNumber,NSString,NSArray,NSDictionary.
 */
@interface AXEJavaScriptModelData : AXEModelTypeData

/**
  创建 javascriptmodel.

 @param value js传入NSDictionary.
 */
+ (instancetype)javascriptModelWithValue:(NSDictionary *)value;

@end



