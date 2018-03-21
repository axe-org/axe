//
//  AXEViewController.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/21.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEViewController.h"

@interface AXEViewController ()

@end

@implementation AXEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)routeURL:(NSString *)url withParams:(AXEData *)params finishBlock:(AXERouterCallbackBlock)block {
    return [[AXERouter sharedRouter] routeURL:url fromViewController:self withParams:params finishBlock:block];
}

- (void)routeURL:(NSString *)url {
    return [[AXERouter sharedRouter] routeURL:url fromViewController:self];
}




@end
