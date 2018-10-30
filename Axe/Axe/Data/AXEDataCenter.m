//
//  AXEDataCenter.m
//  Axe-iOS8.0
//
//  Created by 罗贤明 on 2018/10/27.
//

#import "AXEDataCenter.h"
#import "AXELog.h"

@interface AXEData (private)

@property (nonatomic, strong) NSMutableDictionary<NSString *,AXEDataItem *> *storedDatas;
- (void)_setData:(AXEDataItem *)data forKey:(NSString *)key;
- (AXEDataItem *)_getDataForKey:(NSString *)key;
@end

@implementation AXEDataCenter

+ (instancetype)sharedDataCenter {
    static AXEDataCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AXEDataCenter alloc] init];
        instance.storedDatas = [[NSMutableDictionary alloc] initWithCapacity:100];
    });
    return instance;
}

#pragma mark - override.

- (void)removeDataForKey:(NSString *)key {
    [super removeDataForKey:key];
    
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(dataWillRemoveForKey:)]) {
        [tracker dataWillRemoveForKey:key];
    }
}

- (void)_setData:(AXEDataItem *)data forKey:(NSString *)key {
    [super _setData:data forKey:key];
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(dataWillSetData:forKey:)]) {
        [tracker dataWillSetData:data forKey:key];
    }
}

- (AXEDataItem *)_getDataForKey:(NSString *)key {
    AXEDataItem *data = [super _getDataForKey:key];
    id<AXEOperationTracker> tracker = AXEGetOperationTracker();
    if ([tracker respondsToSelector:@selector(dataWillGetData:forKey:)]) {
        [tracker dataWillGetData:data forKey:key];
    }
    return data;
}


@end
