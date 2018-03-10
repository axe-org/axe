//
//  AXERouter+list.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXERouter.h"
#import "AXEDefines.h"

#ifdef AXEROUTER_LIST_ENABLE

/**
  暴露列表， 以支持调试。
 */
@interface AXERouter(list)


/**
  当前全部的路由 URL 。 指axe协议下的。
 */
- (NSArray<NSString *> *)routerList;


/**
  当前所有的 获取VC的路由。
 */
- (NSArray<NSString *> *)vcRouterList;

@end

#endif
