//
//  AXETabBarController.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXETabBarController.h"
#import "Axe.h"
#import "AxeDefines.h"


static NSMutableArray *itemList = nil;
static void (^customDecorateBlock)(AXETabBarController *) = nil;

@interface AXETabBarController ()


/**
  路由记录。
 */
@property (nonatomic,strong) NSArray<NSString *> *routeURLs;

@end

@implementation AXETabBarController

+ (void)registerTabBarItem:(AXETabBarItem *)barItem {
    NSParameterAssert([barItem isKindOfClass:[AXETabBarItem class]]);
    NSParameterAssert([barItem.pagePath isKindOfClass:[NSString class]]);
    NSParameterAssert([barItem.vcRouteURL isKindOfClass:[NSString class]]);
    
    if (!itemList) {
        itemList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    [itemList addObject:barItem];
}



+ (void)setCustomDecorateBlock:(void (^)(AXETabBarController *))block {
    NSParameterAssert(block);
    
    customDecorateBlock = [block copy];
}

+ (instancetype)TabBarController {
    if (!itemList.count) {
        AXELogWarn(@"[AXETabBarController tabBarController]： 当前没有设置任何的子界面!!!");
    }
    [AXEEvent postEventName:AXEEventTabBarModuleInitializing];
    AXETabBarController *controller = [[AXETabBarController alloc] init];
    return controller;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *controllerList = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *validItemList = [[NSMutableArray alloc] initWithCapacity:10];
    for (AXETabBarItem *item in itemList) {
        UIViewController *controller = [[AXERouter sharedRouter] viewControllerForRouterURL:item.vcRouteURL params:nil];
        if (!controller) {
            AXELogWarn(@"[AXETabBarController viewDidLoad] : 当前 routeURL ： %@ ，未能正确返回ViewController！！！",item.vcRouteURL);
        }else {
            [controllerList addObject:controller];
            [validItemList addObject:item];
        }
    }
    if (controllerList.count) {
        AXELogTrace(@"[AXETabBarController viewDidLoad] : 初始化成功，当前tab页数量为 %@",@(controllerList.count));
    }else {
        AXELogWarn(@"[AXETabBarController viewDidLoad] : 当前tab页数量为0，请检测是否配置错误!!!");
    }
    self.viewControllers = controllerList;
    NSMutableArray *routeURLs = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger i = 0; i < controllerList.count; i ++) {
        UIViewController *controller = controllerList[i];
        AXETabBarItem *item = validItemList[i];
        
        if (item.title) {
            controller.tabBarItem.title = item.title;
        }
        if (item.normalIcon) {
            controller.tabBarItem.image = item.normalIcon;
        }
        if (item.selectedIcon) {
            controller.tabBarItem.selectedImage = item.selectedIcon;
        }
        [routeURLs addObject:[NSString stringWithFormat:@"%@://%@",AXETabBarRouterDefaultProtocolName,item.pagePath]];
    }
    _routeURLs = routeURLs;
    
    if (customDecorateBlock) {
        customDecorateBlock(self);
        customDecorateBlock = nil;
    }
    [[AXERouter sharedRouter] registerProtocol:AXETabBarRouterDefaultProtocolName withRouterBlock:^(UIViewController *fromVC, AXEData *params, AXERouterCallbackBlock callback, NSString *sourceURL) {
        NSInteger index = 0;
        for (; index < self->_routeURLs.count; index ++) {
            if ([sourceURL isEqualToString:self->_routeURLs[index]]) {
                break;
            }
        }
        if (index < self->_routeURLs.count) {
            // 则找到页面
            [self backToIndex:index fromViewController:fromVC];
        }else {
            AXELogWarn(@"AXETabBarController 路由未找到支持的跳转 %@ !!!",sourceURL);
        }
    }];
}

- (void)backToIndex:(NSInteger)index fromViewController:(UIViewController *)fromVC {
    // 退回首页，需要处理所有的弹出页面。
    if (![fromVC isKindOfClass:[UIViewController class]]) {
        AXELogWarn(@"当前没有正确设置fromVC");
        return;
    }
    UIViewController *presented;
    while (fromVC.presentedViewController) {
        presented = fromVC.presentedViewController;
        [fromVC dismissViewControllerAnimated:NO completion:nil];
        fromVC = presented;
    }
    // 然后如果首页是UINavigationController，则退回到root。
    UINavigationController *navigation;
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        navigation = (UINavigationController *)fromVC;
    }else if(fromVC.navigationController) {
        navigation = fromVC.navigationController;
    }
    if (navigation) {
        [navigation popToRootViewControllerAnimated:NO];
    }
    // 最后选择到指定的index。
    self.selectedIndex = index;
}

@end

NSString *AXETabBarRouterDefaultProtocolName = @"home";

NSString *const AXEEventTabBarModuleInitializing = @"AXEEventTabBarModuleInitializing";
