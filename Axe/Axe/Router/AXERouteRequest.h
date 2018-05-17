//
//  AXERouteRequest.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"

/**
  路由的一次请求信息。
 */
@interface AXERouteRequest : NSObject

/**
  是否合法，默认是YES.
    可以在 AXERouterPreprocessBlock 中设置，即提供外界拒绝请求的能力。
 */
@property (nonatomic,assign) BOOL valid;


/**
  用于重定向， 可以 AXERouterPreprocessBlock 修改URL，以使一个地址指向另外一个路径。
   重定向时，不应该添加参数。修改参数建议直接获取 params 进行设置。
   初始化时， 值为传入的 sourceURL
 */
@property (nonatomic,copy) NSString *currentURL;

/**
  所在协议
 */
@property (nonatomic,readonly,strong) NSString *protocol;

/**
 源URL,最初传入的参数URL
 */
@property (nonatomic,readonly,copy) NSString *sourceURL;


/**
  参数
 */
@property (nonatomic,readonly,strong) AXEData *params;


/**
  回调
 */
@property (nonatomic,copy) AXERouteCallbackBlock callback;

/**
  所在页面.
 */
@property (nonatomic,readonly,weak) UIViewController *fromVC;

+ (instancetype)requestWithSourceURL:(NSString *)sourceURL
                              params:(AXEData *)params
                            callback:(AXERouteCallbackBlock)callback
                              fromVC:(UIViewController *)fromVC;

// 以下三个属性，需要路由自己解析并设置。 对于模块化的路由协议，会进行解析。 但是对于URL类型的协议，如http 或者https， 就无法解析的到模块信息了。
// 模块化的路由，要满足我们的要求 ： protocol://module/page , 我们按照这种固定形式去解析。
/**
 模块名 , axe://login/register  的module为 login
 */
@property (nonatomic,strong) NSString *module;

/**
 页面名, axe://login/register  的page为 register
 */
@property (nonatomic,strong) NSString *page;

/**
 页面路径. 如 axe://login/register , path为 login/register
 */
@property (nonatomic,strong) NSString *path;


@end

// 对请求信息做一些处理或者重定向。
typedef void (^AXERoutePreprocessBlock)(AXERouteRequest *request);



@interface AXERouter(Preprocess)


/**
  添加预处理， 以修改请求内容。 或者添加一些检测记录的代码 ,可用于重定向
 @param block 预处理。
 */
- (void)addPreprocess:(AXERoutePreprocessBlock)block;

@end
