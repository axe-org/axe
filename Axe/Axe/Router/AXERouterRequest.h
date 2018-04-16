//
//  AXERouterRequest.h
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
@interface AXERouterRequest : NSObject

/**
  是否合法，默认是YES.
    默认解析URL时进行判断 ， 可以在 AXERouterPreprocessBlock 中设置，即提供外界拒绝请求的能力。
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
  模块名
 */
@property (nonatomic,readonly,strong) NSString *moduleName;

/**
  页面名 ，可能为空。
 */
@property (nonatomic,readonly,strong) NSString *pageName;


/**
  页面路径，去除参数部分。
 */
@property (nonatomic,readonly,strong) NSString *pagePath;


/**
 格式化的URL  ，最后生成的  protocol://pagePath  的URL. 以去除参数
 */
@property (nonatomic,readonly,strong) NSString *formedURL;

/**
 源URL,最初传入的参数URL
 */
@property (nonatomic,readonly,copy) NSString *sourceURL;


/**
  参数
 */
@property (nonatomic,readonly,strong) AXEData *params;

/**
  所在页面.
 */
@property (nonatomic,readonly,strong) UIViewController *fromVC;

// 工厂方法。
+ (instancetype)requestWithSourceURL:(NSString *)sourceURL
                              params:(AXEData *)params
                              fromVC:(UIViewController *)fromVC;


@end


typedef void (^AXERouterPreprocessBlock)(AXERouterRequest *request);



@interface AXERouter(Preprocess)


/**
  添加预处理， 以修改请求内容。 或者添加一些检测记录的代码
   可用于重定向
 @param block 预处理。
 */
- (void)addPreprocess:(AXERouterPreprocessBlock)block;

@end
