//
//  DFUTool.h
//  DFU
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Utility.h"

/**
 成功回调
 */
typedef void (^DFUSuccessBlock)(NSString *msg);

/**
 进度回调

 @param progress 进度百分比
 */
typedef void (^DFUProgressBlock)(CGFloat progress);

/**
 失败回调

 @param error 错误描述
 */
typedef void (^DFUFailedBlock)(NSError *error);

/**
 开始升级回调

 @return 是否允许升级
 */
typedef BOOL (^DFUStartBlock)();

@interface DFUTool : NSObject

/**
 当前升级的蓝牙外设
 */
@property(nonatomic, strong, readonly) CBPeripheral *updatePeripheral;

/**
 成功回调
 */
@property(nonatomic, copy) DFUSuccessBlock successCallBack;

/**
 进度回调
 */
@property(nonatomic, copy) DFUProgressBlock progressCallBack;

/**
 失败回调
 */
@property(nonatomic, copy) DFUFailedBlock failedCallBack;

/**
 开始回调
 */
@property(nonatomic, copy) DFUStartBlock startCallBack;

/**
 是否正在传送
 */
@property (assign, nonatomic) BOOL isTransferring;

/**
 是否传送完毕
 */
@property (assign, nonatomic) BOOL isTransfered;

/**
 是否取消传送
 */
@property (assign, nonatomic) BOOL isTransferCancelled;

/**
 是否连接
 */
@property (assign, nonatomic) BOOL isConnected;

/**
 是否是未知错误
 */
@property (assign, nonatomic) BOOL isErrorKnown;

/**
 创建升级工具(非单例)

 @param peripheral 升级的外设蓝牙
 @param filePath 升级的文件(必须是 zip 压缩文件, 内部包含 manifest.json, .bin, .dat) 三个文件 
 @return 创建好的工具
 */
+ (instancetype)dfuToolWithCenterManager:(CBCentralManager *)manager peripheral:(CBPeripheral *)peripheral updateFile:(NSString *)filePath;


/**
 设置回调
 @param success 成功回调
 @param progress 进度回调
 @param failed 失败回调
 */
- (void)setBlockStart:(DFUStartBlock)start success:(DFUSuccessBlock)success progress:(DFUProgressBlock)progress failed:(DFUFailedBlock)failed;

/**
 开始升级
 */
- (void)start;

/**
 停止升级
 */
- (void)cancel;

@end
