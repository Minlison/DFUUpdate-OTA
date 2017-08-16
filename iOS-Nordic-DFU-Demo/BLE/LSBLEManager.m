//
//  LSBLEManager.m
//  TenCount
//
//  Created by 刘爽 on 16/10/15.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import "LSBLEManager.h"
#import "BLE.h"
@interface LSBLEManager()<BLEDelegate>
{
    
}

@property (nonatomic, assign) NSTimeInterval timeOut;
@end
static id returnAlloc;

@implementation LSBLEManager

+ (instancetype)shared{
    
    return [[self alloc]init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (returnAlloc == nil) {
        @synchronized(self) {
            returnAlloc = [super allocWithZone:zone];
        }
    }
    return returnAlloc;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.device = [[BLE alloc]init];
        [self.device controlSetup];
        self.device.delegate = self;
    }
    return self;
}

- (void)setDiscoverTimeOut:(NSTimeInterval)time{
    self.timeOut = time;
}

- (void)discoverPeripherals{
    [self.device findBLEPeripherals:self.timeOut ? self.timeOut : 5];
}

- (void)bleDidConnect{
    
    if ([self.deleagte respondsToSelector:@selector(LSBLEManagerDeviceDidConnected)]) {
        [self.deleagte LSBLEManagerDeviceDidConnected];
    }
}
- (void)bleDidDisconnect{
    
    if ([self.deleagte respondsToSelector:@selector(LSBLEManagerDeviceDidDisConnected)]) {
        [self.deleagte LSBLEManagerDeviceDidDisConnected];
    }
}
- (void)bleDidReceiveData:(unsigned char *)data length:(int)length{
    
    if ([self.deleagte respondsToSelector:@selector(LSBLEManagerDeviceDidReceiveData:length:)]) {
        [self.deleagte LSBLEManagerDeviceDidReceiveData:data length:length];
    }
}

- (BOOL)isLSBLEManagerConnected{
    return self.device.isConnected;
}
- (NSArray *)LSBLEManagerFoundPeripheralArray{
    return self.device.peripherals;
}
@end
