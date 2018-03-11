//
//  AXEBaseData.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/11.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  数据类型基类。
 */
@interface AXEBaseData : NSObject

/**
  存放的实际数据内容
 */
@property (nonatomic,strong,readonly) id value;


/**
  实例方法。
 */
+ (instancetype)dataWithValue:(id)value;

@end
