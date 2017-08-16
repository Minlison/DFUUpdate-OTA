//
//  MZJDFUViewController.h
//  TenCount
//
//  Created by 刘爽 on 16/8/22.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface MZJDFUViewController : UIViewController
{
    
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSURL *downloadFilePath;

- (void)setSelectedPeripheraWithCentralManager:(CBCentralManager *)centralManager peripheral:(CBPeripheral *)peripheral;

- (void)setSelectedZipFileWithURL:(NSURL *)url;

- (void)setSelectedFileType:(NSString*)selectedFileType;

- (void)startDFU;
@end
