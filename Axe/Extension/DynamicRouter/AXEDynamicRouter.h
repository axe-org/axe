//
//  AXEDynamicRouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  动态路由，先提供本地的动态路由， 以供测试， 后台稍后开发。
 */
@interface AXEDynamicRouter : NSObject

/// 单例
+ (instancetype)sharedDynamicRouter;


/**
  设置动态路由

 @param setting 设置内容为一个字典类型，结构是 {
 "moduleA" : "http://www.xxx.com/xx/", // 这里就可以根据动态路由设置来配置生产和测试环境下不同的h5地址。
 "moduleB" : "axe://moduleB/" ,
 "moduleC" : "react://moduleC/"
 }
    必须为这种格式。
 */
- (void)setup:(NSDictionary *)setting;


/**
  单独添加一个配置，配置内容如上所示,
    一般来说不会调用该接口， 且setup 会刷新这个接口设置的内容。

 @param moduleName 模块名， 即动态路由下的协议名 ， 如 moduleA
 @param redirectPath  实际路由跳转的根目录 ， 如 http://www.xxx.com/xx/
 */
- (void)addRuleForModule:(NSString *)moduleName redirectPath:(NSString *)redirectPath;

@end
