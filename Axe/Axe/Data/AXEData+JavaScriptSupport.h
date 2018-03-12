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
 javascript 获取model方法 ， 获取的model自动转换为 dictionary.
 
 @param key 键值
 @return 将model转换后返回。
 */
- (NSDictionary *)javascriptModelForKey:(NSString *)key;


/**
 设置方法， 传一个 model 进行设置。
 这里有两种情况， 一种是当前已有值时， 进行的是修改操作。
 一种是没有值时， 进行新增操作。
 @param model 从 js 传过来的对象，js传json类型，传到这里为 NSDictionary类型。
 @param key 键值
 */
- (void)setJavascriptModel:(NSDictionary *)model forKey:(NSString *)key;



/**
  封装 js的设置方法， 规定好交互逻辑

 @param data 数据
 @param key 键值。
 */
- (void)setJavascriptData:(NSDictionary *)data;

@end


