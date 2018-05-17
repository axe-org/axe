//
//  AXEDynamicRouter.h
//  Axe
//
//  Created by 罗贤明 on 2018/4/16.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  动态路由, 使用路由，表示我们使用声明路由与实现路由结合的 动态化路由跳转方案。
  声明路由 为 axes://module/page 形式
  实现路由 为 axe://module/page 或者 http://xxx.xx/xx/#/page
 
 我们定义的动态路由规则为 ：
 
 'module' => 'axe://module/'
 左侧为模块名， 右侧为重定向地址。
 右侧的重定向地址可以是 "http://xxx.xx/xxx/#/"
            或者 'reacts://demo.axe-org.cn/login-react/bundle.js?module='这样的地址。
 最终组装URL =  redirectURL + page  (注意，这里就是直接拼装， 所以这个page可以被添加到 锚点、参数和URL上。)
 
 即 如果一个声明路由为 axes://module/page
 则如上的http的重定向，指向了 "http://xxx.xx/xxx/#/page"
 
 。
 */
@interface AXEDynamicRouter : NSObject

/// 单例
+ (instancetype)sharedDynamicRouter;


/**
  初始化

 @param serverURL 设置服务器地址， 如果为空，则表示不请求网络
 @param setting 默认配置， 必须要有默认配置，因为整个APP基于动态路由去加载，没有默认配置会导致初始化问题
 
格式是 ：
 {
 "moduleA" : "http://www.xxx.com/xx/",
 "moduleB" : "axe://moduleB/" ,
 "moduleC" : "react://moduleC/"
 }
 
 该模块的配置有三个来源， 默认配置 、 本地存储、 接口请求。 通过检测版本变更，来判断是使用本地存储还是默认配置。 如果本地修改测试时，需要注意这一点。
 
 */
- (void)setupWithURL:(NSString *)serverURL defaultSetting:(NSDictionary *)setting;


/**
  检测时间间隔， 默认10分钟。 检测时机是 进入前台且间隔10分钟。
 */
@property (nonatomic,assign) NSTimeInterval checkTimeInterval;


/**
  app 版本号，要求 三段式 。 默认自己读Info.plist，不需要设置 （但是如果Info.plist不是三段式格式，后台会报错）。
 */
@property (nonatomic,strong) NSString *appVersion;

/**
  设置 tags ， 以用于AB测试。
 */
@property (nonatomic,strong) NSArray<NSString *> *tags;

@end

// 声明路由的协议， 默认为 axes，可以修改
extern NSString *AXEStatementRouterProtocol;
