//
//  AXELog.m
//  Axe
//
//  Created by 罗贤明 on 2018/10/25.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "AXELog.h"
#include <asl.h>

static const char *AXELogLevels[] = {
    "trace",
    "info",
    "warn",
    "error"
};



AXELogFunction AXEDefaultLogFunction = ^(AXELogLevel level, NSString *message) {
    printf("%s\n",message.UTF8String);
};

static AXELogFunction AXECurrentLogFunction = NULL;


void _AXELogNativeInternal(AXELogLevel level, const char *functionName, const char *fileName, int lineNumber, NSString *format, ...) {
    NSMutableString *log = [NSMutableString new];
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ";
    });
    [log appendString:[formatter stringFromDate:[NSDate date]]];
    [log appendFormat:@"[AXE:%s] ", AXELogLevels[level]];
    NSString *functionString = [NSString stringWithUTF8String:functionName];
    [log appendString:functionString];
    NSString *fileString = [NSString stringWithUTF8String:fileName];
    fileString = fileString.lastPathComponent;
    [log appendFormat:@"[%@:%d]  ", fileString, lineNumber];
    // Get message
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [log appendString:message];
    if (!AXECurrentLogFunction) {
        AXECurrentLogFunction = AXEDefaultLogFunction;
    }
    AXECurrentLogFunction(level, log);
}


void AXESetLogFunction(AXELogFunction logFunction) {
    AXECurrentLogFunction = logFunction;
}


#pragma mark - detail trace

static id<AXEOperationTracker> AXECurrentTracker = NULL;

void AXESetOperationTracker(id<AXEOperationTracker> tracker) {
    AXECurrentTracker = tracker;
}

id<AXEOperationTracker> AXEGetOperationTracker(void) {
    return AXECurrentTracker;
}
