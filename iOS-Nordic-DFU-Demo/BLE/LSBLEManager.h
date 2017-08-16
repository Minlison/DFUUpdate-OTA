//
//  LSBLEManager.h
//  TenCount
//
//  Created by 刘爽 on 16/10/15.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE.h"
@protocol LSBLEManagerDelegate <NSObject>

- (void)LSBLEManagerDeviceDidConnected;
- (void)LSBLEManagerDeviceDidDisConnected;
- (void)LSBLEManagerDeviceDidReceiveData:(unsigned char *)dat length:(int)length;
@end
@interface LSBLEManager : NSObject

@property (nonatomic, weak) id <LSBLEManagerDelegate> deleagte;
@property (nonatomic, strong) BLE *device;
/**
 *  单利对象，用来获取蓝牙管理器
 *
 *  @return 返回蓝牙管理器
 */
+ (LSBLEManager *)shared;
/**
 *  设置蓝牙搜索超时时间
 *
 *  @param time 时间
 */
- (void)setDiscoverTimeOut:(NSTimeInterval)time;

/**
 *  搜索蓝牙设备
 *  这个方法在需要搜索或者重新搜索蓝牙的时候调用即可；
 */
- (void)discoverPeripherals;
/**
 *  是否已连接
 *
 *  @return
 */
- (BOOL)isLSBLEManagerConnected;
/**
 *  返回已经找到的蓝牙设备，放在数组中；
 *
 *  @return CBPeripherals array；
 */
- (NSArray *)LSBLEManagerFoundPeripheralArray;

@end
