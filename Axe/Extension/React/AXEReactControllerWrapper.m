//
//  AXEReactControllerWrapper.m
//  Axe
//
//  Created by 罗贤明 on 2018/3/14.
//

#import "AXEReactControllerWrapper.h"


@interface AXEReactControllerWrapper ()
@property (nonatomic,weak) AXEReactViewController *controller;
@end

@implementation AXEReactControllerWrapper

+ (instancetype)wrapperWithController:(AXEReactViewController *)controller {
    NSParameterAssert([controller isKindOfClass:[AXEReactViewController class]]);
    
    AXEReactControllerWrapper *wrapper = [[AXEReactControllerWrapper alloc] init];
    wrapper.controller = controller;
    return wrapper;
}

@end

NSString *const AXEReactControllerWrapperKey = @"AXEReactControllerWrapperKey";
