//
//  AXEOfflineWebViewDownloadView.h
//  Axe
//
//  Created by 罗贤明 on 2018/3/20.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  下载进度条。
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
  进度条。

 @param progress 进度， 0-100
 */
- (void)didDownloadProgress:(NSInteger)progress;


/**
  成功下载回调
 */
- (void)didFinishLoadSuccess;


/**
 对于出错的处理，设计是由改错误下载页面进行展示， 即设置这里的重试按钮。 当然，这个函数要在 didFinishLoadFailed 之前进行设置。
  重试机制是 关掉当前 AXEOfflineDownloadView， 然后重新请求服务器。
 @param title 标题
 @param block 回调，即重新发请求
 */
- (void)setRetryButtonTitle:(NSString *)title withBlock:(void(^)(void))block;

/**
  下载失败回调。
 */
- (void)didFinishLoadFailed;

@end
