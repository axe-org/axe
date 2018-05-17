//
//  AXEViewController.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/21.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXERouter.h"
#import "Axe.h"
#import "AXERouteRequest.h"

/**
  UIViewController 基类，使 webview、react和原生都使用同一个基类，以便于之后的扩展。
 
  我们没有声明 continuation class ， 所以要对 AXEViewController 扩展时就方便很多。
 */
@interface AXEViewController : UIViewController<AXEEventUserInterfaceContainer>


- (instancetype)init;


/**
    记录request, 以进行传递。
 */
@property (nonatomic,strong) AXERouteRequest *routeRequest;

// UI事件支持。
@property (nonatomic,strong) AXEEventUserInterfaceStatus *AXEContainerStatus;


/**
 注册UI监听， 如果在界面在后台接受到通知时，会等待界面回到前台才会执行。
 没有优先级设定，且必定是在主线程执行 。

 @param event 事件名
 @param block 回调。
 */
- (id<AXEListenerDisposable>)registerUIEvent:(NSString *)event withHandler:(AXEEventHandlerBlock)block;

// 直接调用的路由接口
- (void)jumpTo:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouteCallbackBlock)block;

- (void)jumpTo:(NSString *)url;



/**
  提供一个页面完成展示时的回调。
 */
@property (nonatomic,copy) void (^didAppearBlock)(void);

@end
