//
//  DFUTools.m
//  DFU
//
//  Created by MinLison on 2017/8/24.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "DFUTools.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface DFUTools () <DFUServiceDelegate,DFUProgressDelegate>
@property(nonatomic, strong) DFUServiceController *controller;
@property(nonatomic, strong) DFUServiceInitiator *initiator;
@property(nonatomic, strong) DFUFirmware *selectedFirmware;
@end

@implementation DFUTools

+ (instancetype)dfutoolWithUpdateFilePath:(NSString *)updateFilePath
                            centerManager:(CBCentralManager *)centerManager
                         updatePeripheral:(CBPeripheral *)updatePeripheral
{
        if (!updateFilePath || !centerManager || !updatePeripheral) {
                return nil;
        }
        DFUTools *tools = [[DFUTools alloc] init];
        DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:updateFilePath]];
        tools.selectedFirmware = selectedFirmware;
        if ( ![tools _InitInitatorCenterManager:centerManager updatePeripheral:updatePeripheral] )
        {
                return nil;
        }
        
        return tools;
}

- (BOOL)_InitInitatorCenterManager:(CBCentralManager *)centerManager updatePeripheral:(CBPeripheral *)updatePeripheral
{
        if (!self.selectedFirmware)
        {
                return NO;
        }
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:centerManager target:updatePeripheral];
        self.initiator = [initiator withFirmware:self.selectedFirmware];
        self.initiator.forceDfu = YES; // 这个是强制升级, 如果是YES无论硬件是不是最新版本, 都重新写入程序.  如果是NO, 硬件如果是最新版本,就不升级.
        self.initiator.delegate = self; // - to be informed about current state and errors
        self.initiator.progressDelegate = self; // - to show progress bar
        
        return (self.initiator != nil);
}

- (BOOL)startWithStateChanged:(nullable DFUStateChangedBlock)stateChanged progress:(nullable DFUToolsProgressBlock)progress success:(DFUToolsSuccessBlock)success failed:(DFUToolsFailedBlock)failed
{
        self.stateBlock = stateChanged;
        self.progressBlock = progress;
        self.successBlock = success;
        self.failedBlock = failed;
        return [self start];
}
- (BOOL)start
{
        self.controller = [self.initiator start];
        return (self.controller != nil);
}



- (BOOL)abort
{
        if (self.controller) {
                return [self.controller abort];
        }
        return NO;
}
- (void)restart
{
        if (self.controller && self.controller.aborted) {
                [self.controller restart];
        }
}
- (void)paused
{
        if (self.controller) {
                return [self.controller pause];
        }
}
- (void)resume
{
        if (self.controller && self.controller.paused) {
                [self.controller resume];
        }
}

/// 进度
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
        if (self.progressBlock) {
                self.progressBlock(part, totalParts, ((progress * 1.0) / 100.0), currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
        }
}
- (void)dfuStateDidChangeTo:(enum DFUState)state;
{
        if (self.stateBlock) {
                self.stateBlock((DFUToolsState)state);
        }
}
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message
{
        if (self.failedBlock) {
                self.failedBlock([NSError errorWithDomain:@"DFUToolsError" code:(NSInteger)error userInfo:@{NSLocalizedDescriptionKey : message}]);
        }
}
@end
