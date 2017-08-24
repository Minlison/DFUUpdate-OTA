//
//  DFUTool.m
//  DFU
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "DFUTool.h"
#import "DFUWZProtocolInterceptor.h"
#import "DFUCommonDefine.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "Utility.h"
#import "DFUHelper.h"

@interface DFUTool () <DFUOperationsDelegate>
@property(nonatomic, strong, readwrite) CBPeripheral *updatePeripheral;
@property(nonatomic, weak) CBCentralManager *cbManager;
@property(nonatomic, copy) NSString *updateFilePath;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;
@end

@implementation DFUTool

- (instancetype)init
{
        self = [super init];
        if (self) {
                PACKETS_NOTIFICATION_INTERVAL = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
                self.dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
                self.dfuHelper = [[DFUHelper alloc] initWithData:self.dfuOperations];
        }
        return self;
}

+ (instancetype)dfuToolWithCenterManager:(CBCentralManager *)manager peripheral:(CBPeripheral *)peripheral updateFile:(NSString *)filePath
{
        DFUTool *tool = [[DFUTool alloc] init];
        tool.cbManager = manager;
        tool.updatePeripheral = peripheral;
        tool.updateFilePath = filePath;
        return tool;
}

- (void)setBlockStart:(DFUStartBlock)start success:(DFUSuccessBlock)success progress:(DFUProgressBlock)progress failed:(DFUFailedBlock)failed
{
        self.startCallBack = start;
        self.successCallBack = success;
        self.progressCallBack = progress;
        self.failedCallBack = failed;
}
- (void)start
{
        /// 升级文件不存在
        if (DFUTOOL_IS_NULLString(self.updateFilePath))
        {
                DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:@"升级文件不存在" code:0]);
                return;
        }
        
        NSString *extension = self.updateFilePath.pathExtension;
        /// 当前文件是 zip 文件, 但是设置的属性不是 zip 文件
        if ( ![extension isEqualToString:@"zip"] )
        {
                DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:@"升级文件不是 zip 文件" code:0]);
                return;
        }
        
        NSURL *updateFileUrl = [NSURL fileURLWithPath:self.updateFilePath];
        self.dfuHelper.selectedFileURL = updateFileUrl;
        NSUInteger fileSize = (NSUInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:self.updateFilePath error:nil] fileSize];
        self.dfuHelper.selectedFileSize = fileSize;
        
        // 配置
        self.dfuHelper.isSelectedFileZipped = YES;
        self.dfuHelper.isManifestExist = NO;
        [self.dfuHelper unzipFiles:updateFileUrl];
        
        
        [self.dfuOperations setCentralManager:self.cbManager];
        [self.dfuOperations connectDevice:self.updatePeripheral];
        
        
}
- (void)cancel
{
        if (!self.isTransferCancelled && self.isTransferring )
        {
                [self.dfuOperations cancelDFU];
        }
}
- (void)_startUploadFile
{
        if ( [self.dfuHelper isValidFileSelected] )
        {
                DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:[self.dfuHelper getFileValidationMessage] code:0]);
                return;
        }
        
        if (self.dfuHelper.isDfuVersionExist)
        {
                if ( self.updatePeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion > 1 )
                {
                        if ([self.dfuHelper isInitPacketFileExist])
                        {
                                [self performDFU];
                        }
                        else
                        {
                                [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                        }
                }
                else
                {
                        NSLog(@"can't _startUploadFile");
                }
        }
        else
        {
                if (self.updatePeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected)
                {
                        [self performDFU];
                }
                else
                {
                        NSLog(@"can't _startUploadFile");
                }
        }
}

-(void)performDFU
{
        [self.dfuHelper checkAndPerformDFU];
}
/// MARK: - DFUOperations delegate methods
-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
        NSLog(@"onDeviceConnected %@",peripheral.name);
        self.isConnected = YES;
        self.dfuHelper.isDfuVersionExist = NO;
        
        [self _startUploadFile];
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
        NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
        self.isConnected = YES;
        self.dfuHelper.isDfuVersionExist = YES;
        [self _startUploadFile];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
        NSLog(@"device disconnected %@",peripheral.name);
        self.isTransferring = NO;
        self.isConnected = NO;
        
        // Scanner uses other queue to send events. We must edit UI in the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.dfuHelper.dfuVersion != 1)
                {
                        
                        if (!self.isTransfered && !self.isTransferCancelled && !self.isErrorKnown) {
                                
                                
                                if ([Utility isApplicationStateInactiveORBackground]) {
                                        [Utility showBackgroundNotification:[NSString stringWithFormat:@"%@ 断开连接",peripheral.name]];
                                }
                                else
                                {
                                        DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:[NSString stringWithFormat:@"%@ 断开连接",peripheral.name] code:0]);
                                }
                        }
                        self.isTransferCancelled = NO;
                        self.isTransfered = NO;
                        self.isErrorKnown = NO;
                }
                else
                {
                        double delayInSeconds = 3.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [self.dfuOperations connectDevice:peripheral];
                        });
                }
        });
}

-(void)onReadDFUVersion:(int)version
{
        NSLog(@"onReadDFUVersion %d",version);
        self.dfuHelper.dfuVersion = version;
        NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
        
        if (self.dfuHelper.dfuVersion == 1)
        {
                [self.dfuOperations setAppToBootloaderMode];
        }
        [self _startUploadFile];
}

-(void)onDFUStarted
{
        NSLog(@"onDFUStarted");
        self.isTransferring = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( self.startCallBack )
                {
                        if ( !self.startCallBack() )
                        {
                                [self cancel];
                        }
                }
        });
}

-(void)onDFUCancelled
{
        NSLog(@"onDFUCancelled");
        self.isTransferring = NO;
        self.isTransferCancelled = YES;
        DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:@"取消" code:DFUErrorCodeCanceled]);
}

-(void)onSoftDeviceUploadStarted
{
        NSLog(@"onSoftDeviceUploadStarted");
}

-(void)onSoftDeviceUploadCompleted
{
        NSLog(@"onSoftDeviceUploadCompleted");
}

-(void)onBootloaderUploadStarted
{
        NSLog(@"onBootloaderUploadStarted");
}

-(void)onBootloaderUploadCompleted
{
        NSLog(@"onBootloaderUploadCompleted");
}

-(void)onTransferPercentage:(int)percentage
{
        NSLog(@"onTransferPercentage %d",percentage);
        // Scanner uses other queue to send events. We must edit UI in the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
                DFUTOOL_BLOCK_CALL(self,progressCallBack)((CGFloat)percentage/100.0);
        });
}

-(void)onSuccessfulFileTranferred
{
        NSLog(@"OnSuccessfulFileTransferred");
        // Scanner uses other queue to send events. We must edit UI in the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
                self.isTransferring = NO;
                self.isTransfered = YES;
                NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)self.dfuOperations.binFileSize, (unsigned long)self.dfuOperations.uploadTimeInSeconds];
                DFUTOOL_BLOCK_CALL(self,successCallBack)(message);
        });
}

-(void)onError:(NSString *)errorMessage
{
        NSLog(@"OnError %@",errorMessage);
        self.isErrorKnown = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
                DFUTOOL_BLOCK_CALL(self,failedCallBack)([Utility errorWithMessage:errorMessage code:DFUErrorCodeNormal]);
        });
}

- (void)dealloc
{
        [self cancel];
}
@end
