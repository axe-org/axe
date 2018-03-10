//
//  AXEEventUserInterfaceState+Event.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEEventUserInterfaceState.h"


@interface AXEEventUserInterfaceState(Event)



/**
  当界面不在前台时， 存储事件 ， 等待页面恢复。

 @param name  事件名称
 @param block 回调。
 */
- (void)storeEventName:(NSString *)name handlerBlock:(dispatch_block_t)block;



/**
  清理存储的事件。
    当 事件取消监听时， 也要将这里存储的给清空。
 */
- (void)cleanStoredEvents;

@end
