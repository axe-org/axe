//
//  AXEDynamicRouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  动态路由
 */
@interface AXEDynamicRouter : NSObject

/// 单例
+ (instancetype)sharedDynamicRouter;


/**
  初始化

 @param serverURL 设置服务器地址， 如果为空，则表示不请求网络
 @param setting 默认配置， 必须要有默认配置，因为整个APP基于动态路由去加载，没有默认配置会导致初始化问题
                该模块的配置有三个来源， 默认配置 、 本地存储、 接口请求。 通过检测版本变更，来判断是使用本地存储还是默认配置。 如果本地修改测试时，需要注意这一点。

格式是 ：
 {
 "moduleA" : "http://www.xxx.com/xx/", 必须都以 /结尾
 "moduleB" : "axe://moduleB/" ,
 "moduleC" : "react://moduleC/"
 }
 
 */
- (void)setupWithURL:(NSString *)serverURL defaultSetting:(NSDictionary *)setting;


/**
  检测时间间隔， 默认10分钟。
 */
@property (nonatomic,assign) NSTimeInterval checkTimeInterval;


/**
  app 版本号，要求 三段式 。 默认自己读Info.plist，不需要设置。
 */
@property (nonatomic,strong) NSString *appVersion;

/**
  设置 tags ， 以用于AB测试。
 */
@property (nonatomic,strong) NSArray<NSString *> *tags;

@end
