//
//  AXEDataCenter.h
//  Axe-iOS8.0
//
//  Created by 罗贤明 on 2018/10/27.
//

#import <UIKit/UIKit.h>
#import "AXEData.h"

/**
 数据共享中枢， 继承于 AXEData ，接口相同，但是主要功能是供所有业务组件共享的数据传输中心。
 */
@interface AXEDataCenter : AXEData
/**
 公共数据。 单例。
 */
+ (instancetype)sharedDataCenter;

@end

