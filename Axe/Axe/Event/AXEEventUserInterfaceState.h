//
//  AXEEventUserInterfaceState.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 UI 活跃状态类， 页面打开关闭时，通知该状态进行变化。
 */
@interface AXEEventUserInterfaceState : NSObject

/**
 界面将要消失或退到后台.
 */
- (void)containerWillDisappear;

/**
 界面将要回到前台。
 */
- (void)containerWillAppear;


/**
  UI当前是否在前台。
 */
@property (nonatomic,readonly,assign) BOOL inFront;

/**
   创建函数。
 */
+ (instancetype)state;

// 待考虑。 TODO 
///**
//  释放所有监听。
// */
//- (void)removeListeners;

@end

/**
 UI 容器协议 ， 负责监控界面是否在前台。
 通过这种监控，来决定是否执行任务。
 */
@protocol AXEEventUserInterfaceContainer<NSObject>

/**
 持有 状态类，以监听页面前后台切换。
 */
@property (nonatomic,readonly,strong) AXEEventUserInterfaceState *AXEContainerState;

@end
