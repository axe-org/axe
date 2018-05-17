//
//  AXEEventUserInterfaceStatus.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 界面状态类， 页面打开关闭时，通知该状态进行变化。
 */
@interface AXEEventUserInterfaceStatus : NSObject

/**
 界面将要消失或隐藏
 */
- (void)containerWillDisappear;

/**
  界面显示。
 */
- (void)containerDidAppear;


/**
  UI当前是否在前台或展示中。
 */
@property (nonatomic,readonly,assign) BOOL inFront;

/**
   创建函数。
 */
+ (instancetype)status;


/**
  清理存储内容。
 */
- (void)cleanStoredEvents;
@end

/**
 UI 容器协议 ， 负责监控界面是否在前台。
 通过监控，来决定是否响应事件。
 */
@protocol AXEEventUserInterfaceContainer<NSObject>

/**
 持有 状态类，以监听页面前后台切换。
 */
@property (nonatomic,readonly,strong) AXEEventUserInterfaceStatus *AXEContainerStatus;

@end
