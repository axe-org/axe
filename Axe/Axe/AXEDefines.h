//
//  AXEDefines.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/9.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

// 一些常用的配置内容。

#if __OBJC__
#  import <Foundation/Foundation.h>
#endif

// 默认DEBUG情况下 设置AXE_DEBUG
#ifndef AXE_DEBUG
#if DEBUG
#define AXE_DEBUG 1
#else
#define AXE_DEBUG 0
#endif
#endif

#if AXE_DEBUG
#define AXELogTrace(...)        NSLog(@"AXE [Trace] : %@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define AXELogTrace(...)
#endif

#define AXELogWarn(...)         NSLog(@"AXE [Warn] : %@",[NSString stringWithFormat:__VA_ARGS__])


#if AXE_DEBUG

#ifndef AXEROUTER_LIST_ENABLE
// 支持路由列表功能， 将当前所有注册的路由暴露出来。
#define AXEROUTER_LIST_ENABLE
#endif

#endif
