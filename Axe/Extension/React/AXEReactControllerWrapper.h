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
    通过 launchOptions 传递给每个 NativeModule.
 */
@interface AXEReactControllerWrapper : NSObject


/**
  弱引用， 使每个 Module都可以获取当前页面。
 */
@property (nonatomic,readonly,weak) AXEReactViewController *controller;


/**
 初始化
 */
+ (instancetype)wrapperWithController:(AXEReactViewController *)controller;

@end

/// 我们规定每个AXEReactViewController 创建时， 都会将自己的弱引用传入，以供module使用。
extern NSString *const AXEReactControllerWrapperKey;
