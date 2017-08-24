//
//  UpdateViewController.m
//  DFU
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "UpdateViewController.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface UpdateViewController () <DFUServiceDelegate,DFUProgressDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic, strong) DFUTool *updateTool;
@property (weak, nonatomic) IBOutlet UIButton *swiftControlBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *swiftProgressView;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;

@property(nonatomic, strong) DFUServiceController *controller;
@property(nonatomic, strong) DFUServiceInitiator *initiator;
@property(nonatomic, strong) DFUFirmware *selectedFirmware;
@end

@implementation UpdateViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        
        NSString *updateFile = @"设置升级文件路径";
        
        [self _InitOC:updateFile];
        
        [self _InitSwift:updateFile];
        
}
- (void)_InitOC:(NSString *)updateFilePath
{
        
        self.updateTool = [DFUTool dfuToolWithCenterManager:self.manager peripheral:self.updatePeripheral updateFile:updateFilePath];
        
        __weak __typeof(self)weakSelf = self;
        [self.updateTool setBlockStart:^BOOL{
                return YES;// 如果设置成 NO, 不会升级
        } success:^(NSString *msg) {
                NSLog(@"升级成功   %@",msg);
        } progress:^(CGFloat progress) {
                NSLog(@"传送百分比  %f",progress);
                weakSelf.progressView.progress = progress;
        } failed:^(NSError *error) {
                if (error.code == DFUErrorCodeCanceled)
                {
                        NSLog(@"取消 %@",error);
                }
                else
                {
                        NSLog(@"升级失败  %@",error);
                }
        }];
}
- (IBAction)start:(UIButton *)sender
{
        if (sender.isSelected) {
                // 取消
                [self.updateTool cancel];
        }
        else {
                // 开始
                [self.updateTool start];
        }
        
        sender.selected = !sender.isSelected;
        
}

- (void)_InitSwift:(NSString *)updateFilePath
{
        DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:updateFilePath]];
        self.selectedFirmware = selectedFirmware;
        
}

- (BOOL)_InitInitator
{
        if (!self.selectedFirmware)
        {
                return NO;
        }
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:self.manager target:self.updatePeripheral];
        self.initiator = [initiator withFirmware:self.selectedFirmware];
        self.initiator.forceDfu = YES; // 这个是强制升级, 如果是YES无论硬件是不是最新版本, 都重新写入程序.  如果是NO, 硬件如果是最新版本,就不升级.
        self.initiator.delegate = self; // - to be informed about current state and errors
        self.initiator.progressDelegate = self; // - to show progress bar
        
        return (self.initiator != nil);
}

- (IBAction)swiftStart:(UIButton *)sender
{
        if (sender.isSelected) {
                // 取消
                BOOL stoped = [self.controller abort];
        }
        else {
                // 开始
                if ( !self.controller )
                {
                        if ([self _InitInitator])
                        {
                                self.controller = [self.initiator start];
                        }
                        else
                        {
                                NSLog(@"初始化失败");
                        }
                }
                else
                {
                        [self.controller restart];
                }
        }
        
        sender.selected = !sender.isSelected;
}
/// 进度
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
        self.swiftProgressView.progress = progress;
}
- (void)dfuStateDidChangeTo:(enum DFUState)state;
{
        NSLog(@"dfuStateDidChangeTo %d",(int)state);
}
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message
{
        NSLog(@"dfuError -- didOccurWithMessage %@",message);
}
@end
