//
//  ViewController.m
//  Demo
//
//  Created by 罗贤明 on 2018/3/10.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "ViewController.h"

#import "Axe.h"
#import "AXEData+JavaScriptSupport.h"
#import "AXEJavaScriptModelData.h"

#import "AXEOfflineDownloadView.h"

@interface ViewController ()

@end

@protocol Test <NSObject>

@property (nonatomic,strong) NSString *hello;
@property (nonatomic,strong) NSNumber *hel;

@end

@implementation ViewController

- (void)vmuapp {
    NSLog(@"vmuapp");
    [[AXERouter sharedRouter] routeURL:@"ophttp://vmuapp/index.html#/feteamdevnav" fromViewController:self];
}

- (void)echo {
    [[AXERouter sharedRouter] routeURL:@"ophttp://echo/echo.html" fromViewController:self];
}

- (void)react {
    [[AXERouter sharedRouter] routeURL:@"opreact://react/bundle.js?_moduleName=Awesome" fromViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    self.title = @"你好!!!";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"echo" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(echo) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 200, 100, 44);
    [self.view addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"vumapp" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(vmuapp) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 280, 100, 44);
    [self.view addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"react" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(react) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 350, 100, 44);
    [self.view addSubview:btn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//
//    id<Test> test = [[AXEData sharedData] modelForKey:@"test"];
//    NSLog(@"%@",test.hello);
//    test.hel = @(1);
//    NSLog(@"%@",test);
    NSLog(@"viewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
