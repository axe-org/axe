//
//  AXEAutoreleaseEvent.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/8.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXEEvent.h"

/**
 AXEEvent 的派生类， 提供了简单的 自动释放的事件监听， 在事件执行一次后，会自动取消监听。
 */
@interface AXEAutoreleaseEvent : AXEEvent


@end
