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

@interface ViewController ()

@end

@protocol Test <NSObject>

@property (nonatomic,strong) NSString *hello;
@property (nonatomic,strong) NSNumber *hel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"你好!!!";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"self.tabbarController : %@",self.tabBarController);
    NSLog(@"self.presentedViewController : %@",self.presentedViewController);
    
    NSDictionary *dic = @{@"hello":@"world",@"hel":@(213)};
    [[AXEData sharedData] setJavascriptModel:dic forKey:@"test"];
    
    id<Test> test = [[AXEData sharedData] modelForKey:@"test"];
    NSLog(@"%@",test.hello);
    test.hel = @(1);
    NSLog(@"%@",test);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
