//
//  DFUTools.h
//  DFU
//
//  Created by MinLison on 2017/8/24.
//  Copyright © 2017年 minlison. All rights reserved.
//

/**
 使用时请使用 pod 的方式导入
 use_frameworks!
 target '项目名' do
 platform :ios, '8.0'
 pod 'iOSDFULibrary'
 end
 
 */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

/**
 状态改变

 - DFUToolsStateConnecting: 连接中
 - DFUToolsStateStarting: 开始
 - DFUToolsStateEnablingDfuMode: 激活升级
 - DFUToolsStateeUploading: 上传文件
 - DFUToolsStateValidating: 校验文件
 - DFUToolsStateDisconnecting: 断开蓝牙
 - DFUToolsStateCompleted: 完成升级
 - DFUToolsStateAborted: 取消升级
 */
typedef NS_ENUM(NSInteger, DFUToolsState) {
        DFUToolsStateConnecting = 0,
        DFUToolsStateStarting = 1,
        DFUToolsStateEnablingDfuMode = 2,
        DFUToolsStateeUploading = 3,
        DFUToolsStateValidating = 4,
        DFUToolsStateDisconnecting = 5,
        DFUToolsStateCompleted = 6,
        DFUToolsStateAborted = 7,
};


typedef NS_ENUM(NSInteger, DFUToolsError) {
        /// 标准升级 成功
        DFUToolsErrorRemoteLegacyDFUSuccess = 1,
        /// 标准升级 无效状态
        DFUToolsErrorRemoteLegacyDFUInvalidState = 2,
        /// 标准升级 不支持升级
        DFUToolsErrorRemoteLegacyDFUNotSupported = 3,
        /// 标准升级 升级包过大
        DFUToolsErrorRemoteLegacyDFUDataExceedsLimit = 4,
        /// 标准升级 循环冗余校验 失败
        DFUToolsErrorRemoteLegacyDFUCrcError = 5,
        /// 标准升级 升级失败
        DFUToolsErrorRemoteLegacyDFUOperationFailed = 6,
        /// 安全升级 成功
        DFUToolsErrorRemoteSecureDFUSuccess = 11,
        /// 安全升级 不支持
        DFUToolsErrorRemoteSecureDFUOpCodeNotSupported = 12,
        /// 安全升级 参数不支持
        DFUToolsErrorRemoteSecureDFUInvalidParameter = 13,
        /// 安全升级 升级源文件不正确
        DFUToolsErrorRemoteSecureDFUInsufficientResources = 14,
        /// 安全升级 校验不成功
        DFUToolsErrorRemoteSecureDFUInvalidObject = 15,
        /// 安全升级 信号不匹配
        DFUToolsErrorRemoteSecureDFUSignatureMismatch = 16,
        /// 安全升级 类型不支持
        DFUToolsErrorRemoteSecureDFUUnsupportedType = 17,
        /// 安全升级 未经许可
        DFUToolsErrorRemoteSecureDFUOperationNotpermitted = 18,
        /// 安全升级 升级失败
        DFUToolsErrorRemoteSecureDFUOperationFailed = 20,
        /// 安全升级 扩展失败
        DFUToolsErrorRemoteSecureDFUExtendedError = 21,
        /// 实验升级 成功 (忽略即可)
        DFUToolsErrorRemoteExperimentalBootlonlessDFUSuccess = 9001,
        /// 实验升级 不支持 (忽略即可)
        DFUToolsErrorRemoteExperimentalBootlonlessDFUOpCodeNotSupported = 9002,
        /// 实验升级 失败 (忽略即可)
        DFUToolsErrorRemoteExperimentalBootlonlessDFUOperationFailed = 9004,
        /// 升级成功
        DFUToolsErrorRemoteBootlonlessDFUSuccess = 31,
        /// 不支持
        DFUToolsErrorRemoteBootlonlessDFUOpCodeNotSupported = 32,
        /// 升级失败
        DFUToolsErrorRemoteBootlonlessDFUOperationFailed = 34,
        /// DFUFirmware 未初始化
        DFUToolsErrorFileNotSpecified = 101,
        /// 升级文件不正确
        DFUToolsErrorFileInvalid = 102,
        /// 升级文件不正确
        /// Since SDK 7.0.0 the DFU Bootloader requires the extended Init Packet. For more details, see:
        /// http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/bledfu_example_init.html?cp=4_0_0_4_2_1_1_3
        DFUToolsErrorExtendedInitPacketRequired = 103,
        /// 升级文件不正确
        /// Before SDK 7.0.0 the init packet could have contained only 2-byte CRC value, and was optional.
        /// Providing an extended one instead would cause CRC error during validation (the bootloader assumes that the 2 first bytes
        /// of the init packet are the firmware CRC).
        DFUToolsErrorInitPacketRequired = 104,
        /// 连接不成功
        DFUToolsErrorFailedToConnect = 201,
        /// 连接异常断开
        DFUToolsErrorDeviceDisconnected = 202,
        /// 蓝牙设备不可用
        DFUToolsErrorBluetoothDisabled = 203,
        /// 外设没有升级通道
        DFUToolsErrorServiceDiscoveryFailed = 301,
        /// 设备不支持升级
        DFUToolsErrorDeviceNotSupported = 302,
        /// 读取版本号失败
        DFUToolsErrorReadingVersionFailed = 303,
        /// 开启升级通道失败
        DFUToolsErrorEnablingControlPointFailed = 304,
        /// 写入数据失败
        DFUToolsErrorWritingCharacteristicFailed = 305,
        /// 无法收到蓝牙设备信号
        DFUToolsErrorReceivingNotificationFailed = 306,
        /// 不支持的响应格式(找硬件部门解决)
        DFUToolsErrorUnsupportedResponse = 307,
        /// 当发送的字节数不等于数据包接收通知中确认的字节数时，上传期间发生错误。
        /// Error raised during upload when the number of bytes sent is not equal to number of bytes confirmed in Packet Receipt Notification.
        DFUToolsErrorBytesLost = 308,
        /// 当远程设备报告的CRC不匹配时发生错误。 服务已经做了3次尝试发送数据。
        /// Error raised when the CRC reported by the remote device does not match. Service has done 3 tries to send the data.
        DFUToolsErrorCrcError = 309,
};

/**
 进度回调

 @param currentPart 当前正在升级的部分
 @param totalParts 一共几个需要升级的部分
 @param progress 进度 百分比 0 - 1
 @param currentSpeedBytesPerSecond 当前的速度 单位 Bytes / s  1024Bytes = 1KB 1024KB = 1MB
 @param avgSpeedBytesPerSecond 平均速度 单位 Bytes / s  1024Bytes = 1KB 1024KB = 1MB
 */
typedef void (^DFUToolsProgressBlock)(NSInteger currentPart, NSInteger totalParts, CGFloat progress, CGFloat currentSpeedBytesPerSecond, CGFloat avgSpeedBytesPerSecond);

/**
 成功回调
 */
typedef void (^DFUToolsSuccessBlock)();

/**
 失败回调

 @param failed 失败原因 (DFUToolsError code)
 */
typedef void (^DFUToolsFailedBlock)(NSError *failed);

typedef void (^DFUStateChangedBlock)(DFUToolsState state);

@interface DFUTools : NSObject

/**
 进度回调
 */
@property(nonatomic, copy) DFUToolsProgressBlock progressBlock;

/**
 成功回调
 */
@property(nonatomic, copy) DFUToolsSuccessBlock  successBlock;

/**
 失败回调
 */
@property(nonatomic, copy) DFUToolsFailedBlock   failedBlock;

/**
 状态改变
 */
@property(nonatomic, copy) DFUStateChangedBlock stateBlock;

/**
 升级工具创建
 block 在最后会清空, 不会导致循环引用
 如果 参数为空, 则返回 nil
 @param updateFilePath 升级文件
 @param centerManager 蓝牙管理器
 @param updatePeripheral 外设
 @return instance of DFUTools
 */
+ (nullable instancetype)dfutoolWithUpdateFilePath:(NSString *)updateFilePath
                                     centerManager:(CBCentralManager *)centerManager
                                  updatePeripheral:(CBPeripheral *)updatePeripheral;

/**
 开始升级

 @param progress 进度回调
 @param success 成功回调
 @param failed 失败回调
 @return 是否成功
 */
- (BOOL)startWithStateChanged:(nullable DFUStateChangedBlock)stateChanged progress:(nullable DFUToolsProgressBlock)progress success:(DFUToolsSuccessBlock)success failed:(DFUToolsFailedBlock)failed;

/**
 开始升级
 回调 block 需要自己设置
 @return 是否成功
 */
- (BOOL)start;

/**
 取消升级
 @return 是否成功
 */
- (BOOL)abort;

/**
 重新开始
 在调用 abort 方法后可调用该方法重新升级, 不需要再次初始化
 */
- (void)restart;

/**
 暂停
 */
- (void)paused;

/**
 继续
 */
- (void)resume;
@end
NS_ASSUME_NONNULL_END
