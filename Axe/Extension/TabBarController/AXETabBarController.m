//
//  AXETabBarController.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXETabBarController.h"
#import "Axe.h"
#import "AXELog.h"
#import "AXERouteRequest.h"


static NSMutableArray<AXETabBarItem *> *itemList = nil;
static void (^customDecorateBlock)(AXETabBarController *) = nil;
static Class NavigationControllerClass = NULL;

@interface AXETabBarController ()

@end




@implementation AXETabBarController

+ (void)setNavigationControllerClass:(Class)cls {
    NavigationControllerClass = cls;
}

+ (void)registerTabBarItem:(AXETabBarItem *)barItem {
    NSParameterAssert([barItem isKindOfClass:[AXETabBarItem class]]);
    
    if (!itemList) {
        itemList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    [itemList addObject:barItem];
}



+ (void)setCustomDecorateBlock:(void (^)(AXETabBarController *))block {
    NSParameterAssert(block);
    
    customDecorateBlock = [block copy];
}

+ (instancetype)sharedTabBarController {
    static AXETabBarController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!itemList.count) {
            AXELogWarn(@"[AXETabBarController tabBarController]： 当前没有设置任何的子界面!!!");
        }
        if (NULL == NavigationControllerClass) {
            NavigationControllerClass = [UINavigationController class];
        }
        instance = [[AXETabBarController alloc] init];
    });
    return instance;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSMutableArray *controllerList = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *validItemList = [[NSMutableArray alloc] initWithCapacity:10];
    NSInteger index = 0;
    for (AXETabBarItem *item in itemList) {
        AXEData *data = [AXEData dataForTransmission];
        [data setData:@(index) forKey:AXETabBarRouterIndexKey];
        [data setData:item.path forKey:AXETabBarRouterPathKey];
        UIViewController *controller = [[AXERouter sharedRouter] viewForURL:item.viewRoute withParams:data finishBlock:nil];
        if (!controller) {
            AXELogWarn(@" 当前 routeURL ： %@ ，未能正确返回ViewController！！！",item.viewRoute);
        }else {
            index ++;
            if (![controller isKindOfClass:[UINavigationController class]]) {
                // 则构建一个 navigationController
                UINavigationController *navigation = [[NavigationControllerClass alloc] initWithRootViewController:controller];
                controller = navigation;
            }
            [controllerList addObject:controller];
            [validItemList addObject:item];
        }
    }
    if (controllerList.count) {
        AXELogTrace(@"初始化成功，当前tab页数量为 %@",@(controllerList.count));
    }else {
        AXELogWarn(@"当前tab页数量为0，请检测是否配置错误!!!");
    }
    self.viewControllers = controllerList;
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
        __weak AXETabBarController *wself = self;
        [[AXERouter sharedRouter] registerPath:[NSString stringWithFormat:@"%@/%@", AXETabBarRouterDefaultProtocolName, item.path] withJumpRoute:^(AXERouteRequest *request) {
            [wself backToIndex:i fromViewController:request.fromVC];
        }];
    }
    
    if (customDecorateBlock) {
        customDecorateBlock(self);
        customDecorateBlock = nil;
    }
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

NSString *const AXETabBarRouterIndexKey = @"index";
NSString *const AXETabBarRouterPathKey = @"path";
