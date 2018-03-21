//
//  AXEOfflineWebViewDownloadView.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/20.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXEOfflineDownloadView.h"
/**
 渐变色的进度条
 */
@interface AXEOfflineGradientProgressView : UIView

@property (nonatomic,assign) float progress;

@property (nonatomic,weak) CAGradientLayer *glayer;



@end



@implementation AXEOfflineGradientProgressView


- (void)setProgress:(float)progress {
    _progress = progress;
    _glayer.frame = CGRectMake(0, 0, self.frame.size.width * _progress , self.frame.size.height);
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:235 / 255.0 blue:240 / 255.0 alpha:1];
//        self.backgroundColor = COLOR_WITH_HEX(@"E6EBf0");
        self.layer.cornerRadius = 4;
        _progress = 0.0;
        CAGradientLayer *layer = [[CAGradientLayer alloc] init];
        UIColor *startColor = [UIColor colorWithRed:108 / 255.0 green:230 / 255.0 blue:255/255.0 alpha:1];
        UIColor *endColor = [UIColor colorWithRed:96 / 255.0 green:163 / 255.0 blue:255/255.0 alpha:1];
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        layer.startPoint = CGPointMake(0, 0.5);
        layer.endPoint = CGPointMake(1, 0.5);
        layer.locations = @[@0.25,@0.7];
        layer.cornerRadius = 4;
        [self.layer addSublayer:layer];
        layer.frame = CGRectZero;
        _glayer = layer;
    }
    return self;
}
@end

@interface AXEOfflineDownloadView()

@property (nonatomic,weak) AXEOfflineGradientProgressView *progressView;
@property (nonatomic,weak) UIView *loadingView;
@property (nonatomic,weak) UILabel *title;
@property (nonatomic,copy) NSString *retryTitle;
@property (nonatomic,copy) void (^retryBlock)(void);

@end

static AXEOfflineDownloadView *(^implemation)(UIView *);

@implementation AXEOfflineDownloadView

+ (void)setCustomImplemation:(AXEOfflineDownloadView *(^)(UIView *))block {
    implemation = [block copy];
}

+ (AXEOfflineDownloadView *)showInView:(UIView *)view {
    NSParameterAssert([view isKindOfClass:[UIView class]]);
    if (implemation) {
        return implemation(view);
    }
    AXEOfflineDownloadView *downloadView = [[AXEOfflineDownloadView alloc] initWithFrame:view.bounds];
    
    [view addSubview:downloadView];
    downloadView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    downloadView.frame = view.bounds;
    
    UIView *loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor whiteColor];
    loadingView.layer.cornerRadius = 4;
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [downloadView addSubview:loadingView];
    downloadView.loadingView = loadingView;
    [downloadView addConstraint:[NSLayoutConstraint constraintWithItem:downloadView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:loadingView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [downloadView addConstraint:[NSLayoutConstraint constraintWithItem:downloadView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:loadingView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:loadingView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:180.0f]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:loadingView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:90.0f]];
    
    
    UILabel *title = [[UILabel alloc] init];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:17];
    title.textColor = [UIColor colorWithRed:128/255. green:128/255. blue:128/255. alpha:1];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"资源下载中";
    [loadingView addSubview:title];
    downloadView.title = title;
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:50.0f]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0f
                                                             constant:0]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0f
                                                             constant:0]];
    
    AXEOfflineGradientProgressView *progressView = [[AXEOfflineGradientProgressView alloc] init];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [loadingView addSubview:progressView];
    downloadView.progressView = progressView;
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0f
                                                             constant:0]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:10.0f]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0f
                                                             constant:15.f]];
    [loadingView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:loadingView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0f
                                                             constant:-15.f]];
    return downloadView;
}


- (void)setRetryButtonTitle:(NSString *)title withBlock:(void(^)(void))block {
    self.retryTitle = title;
    self.retryBlock = block;
}

- (void)retryClick {
    [self removeFromSuperview];
    if (_retryBlock) {
        _retryBlock();
    }
}

#pragma mark - response


- (void)didDownloadProgress:(NSInteger)progress {
    [_progressView setProgress:progress/100.];
}


- (void)didFinishLoadSuccess {
    _title.text = @"下载完成";
    CGRect frame = self.frame;
    frame.origin.y += self.frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)didFinishLoadFailed {
    // 错误页面，暂时错误标题与按钮。
    _title.text = @"下载失败，稍后重试";
    [_progressView removeFromSuperview];
    
    UIView *split = [[UIView alloc] init];
    split.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:0.5];
    split.frame = CGRectMake(0, 50, 180, 0.5);
    [_loadingView addSubview:split];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:_retryTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:79/255. green:148/255. blue:205/255. alpha:1] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, 50, 180, 40);
    [_loadingView addSubview:btn];
    [btn addTarget:self action:@selector(retryClick) forControlEvents:UIControlEventTouchUpInside];
}

@end
