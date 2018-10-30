//
//  AXELog.h
//  Axe
//
//  Created by 罗贤明 on 2018/10/25.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Logging macros.
 */
#define AXELog(...) _AXELog(AXELogLevelInfo, __VA_ARGS__)
#define AXELogTrace(...) _AXELog(AXELogLevelTrace, __VA_ARGS__)
#define AXELogInfo(...) _AXELog(AXELogLevelInfo, __VA_ARGS__)
#define AXELogWarn(...) _AXELog(AXELogLevelWarning, __VA_ARGS__)
#define AXELogError(...) _AXELog(AXELogLevelError, __VA_ARGS__)

/**
 * An enum representing the severity of the log message.
 */
typedef NS_ENUM(NSInteger, AXELogLevel) {
    AXELogLevelTrace = 0,
    AXELogLevelInfo = 1,
    AXELogLevelWarning = 2,
    AXELogLevelError = 3
};

/**
 * A block signature to be used for custom logging functions.
 */
typedef void (^AXELogFunction)(AXELogLevel level, NSString *message);

/**
 * The default logging function used by AXELog.
 */
extern AXELogFunction AXEDefaultLogFunction;

/**
 * These methods get and set the global logging function called by the AXELogXX
 * macros. You can use these to replace the standard behavior with custom log
 * functionality.
 */
extern void AXESetLogFunction(AXELogFunction logFunction);





#pragma mark - detail trace

@class AXEDataItem;
@class AXEData;



@protocol AXEOperationTracker <NSObject>
@optional

- (void)routerWillJumpRoute:(NSString *)url withPayload:(AXEData *)payload;

- (void)routerWillViewRoute:(NSString *)url withPayload:(AXEData *)payload;

- (void)dataWillSetData:(AXEDataItem *)data forKey:(NSString *)key;

- (void)dataWillRemoveForKey:(NSString *)key;

- (void)dataWillGetData:(AXEDataItem *)data forKey:(NSString *)key;

- (void)eventWillPost:(NSString *)eventName withPayload:(AXEData *)payload;

@end


/**
  Set a tracker to monitor the operation maked by axe.
  There is no tracker by default.
 */
extern void AXESetOperationTracker(id<AXEOperationTracker> tracker);



/**
 * Private logging function - ignore this.
 */
#define _AXELog(lvl, ...) _AXELogNativeInternal(lvl, __PRETTY_FUNCTION__, __FILE__, __LINE__, __VA_ARGS__)

extern void _AXELogNativeInternal(AXELogLevel, const char *, const char *, int, NSString *, ...) NS_FORMAT_FUNCTION(5,6);


extern id<AXEOperationTracker> AXEGetOperationTracker(void);
