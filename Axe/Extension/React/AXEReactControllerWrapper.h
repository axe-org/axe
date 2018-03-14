//
//  AXEReactControllerWrapper.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/14.
//

#import <Foundation/Foundation.h>
#import "AXEReactViewController.h"

/**
  使用弱引用 包装一下 AXEReactViewController
 */
@interface AXEReactControllerWrapper : NSObject


/**
  我们约束了 每个 react viewcontroller 都拥有自己的 rctbridge ,所以 每个module 都与一个 controller 相对应。
 */
@property (nonatomic,readonly,weak) AXEReactViewController *controller;


/**
 初始化

 @param controller <#controller description#>
 @return <#return value description#>
 */
+ (instancetype)wrapperWithController:(AXEReactViewController *)controller;


@property (nonatomic,strong) AXEData *routerData;

@property (nonatomic,copy) AXERouterCallbackBlock routerCallback;

@end

/// 我们规定每个AXEReactViewController 创建时， 都会将自己的弱引用传入，以供module使用。
extern NSString *const AXEReactControllerWrapperKey;
