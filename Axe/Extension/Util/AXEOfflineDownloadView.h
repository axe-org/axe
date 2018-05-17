//
//  AXEOfflineWebViewDownloadView.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/20.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  离线包 下载进度条。
 */
@interface AXEOfflineDownloadView : UIView


/**
  设置自定义实现。
 */
+ (void)setCustomImplemation:(AXEOfflineDownloadView *(^)(UIView *))block;


/**
 在页面上显示

 @param view 展示在view或者window.
 @return AXEOfflineWebViewDownloadView 下载view.
 */
+ (AXEOfflineDownloadView *)showInView:(UIView *)view;


/**
 设置一个按钮的标题与回调。 用于出错时处理。出错一般有两种思路 ：
 1. 提供一个关闭页面按钮 ： 问题是 如果当前页面是放在首页的，不能关闭的页面，就会很尴尬。
 2. 提供一个重试按钮。 即再次请求，重新下载。 我们当前默认使用重试按钮。
 
 @param title 标题
 @param block 回调
 */
- (void)setErrorHandlerButtonTitle:(NSString *)title withBlock:(void(^)(void))block;


// 以下三个函数是回调，自定义时，需要实现以下三个函数。

/**
 进度条。
 
 @param progress 进度， 0-100
 */
- (void)didDownloadProgress:(NSInteger)progress;


/**
 成功下载回调
 */
- (void)didFinishLoadSuccess;

/**
 下载失败回调。
 */
- (void)didFinishLoadFailed;
@end
