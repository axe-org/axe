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

#define AXE_DEBUG 0

//#if DEBUG
//#define AXE_DEBUG 1
//#else
//#define AXE_DEBUG 0
//#endif

#if AXE_DEBUG
#define AXELogTrace(...)        fprintf(stderr,"%s\n",[NSString stringWithFormat:@"[AXE Trace] %@.%d %s \n: %@",\
                                        [[NSString stringWithUTF8String:__FILE__] lastPathComponent] ,\
                                        __LINE__ ,__PRETTY_FUNCTION__ , [NSString stringWithFormat:__VA_ARGS__]].UTF8String)
#else
#define AXELogTrace(...)
#endif

#define AXELogWarn(...)         fprintf(stderr,"%s\n",[NSString stringWithFormat:@"[AXE Warn] %@.%d %s \n: %@",\
                                        [[NSString stringWithUTF8String:__FILE__] lastPathComponent] ,\
                                        __LINE__ ,__PRETTY_FUNCTION__ , [NSString stringWithFormat:__VA_ARGS__]].UTF8String)

