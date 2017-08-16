//
//  MZJDFUViewController.m
//  TenCount
//
//  Created by 刘爽 on 16/8/22.
//  Copyright © 2016年 redbear. All rights reserved.
//
#import "MBProgressHUD+HM.h"
#import "MZJDFUViewController.h"
#import "ScannerViewController.h"
#import "MZJAPPFilesViewController.h"
#import "MZJUserFilesViewController.h"
#import "MZJFileTypeController.h"
#import "DFUHelper.h"
#import "DFUOperations.h"
#import "UnzipFirmware.h"
//#import "NSObject+WHC_Model.h"
#import "BLEController.h"
//#import "MZJCurrentPlayer.h"
#import "LSAlertVierw.h"
@interface MZJDFUViewController ()<UITableViewDataSource,UITableViewDelegate,ScannerDelegate,MZJFileSelectedDelegate,MZJFileTypeSelectionDelegate,DFUOperationsDelegate,FileOperationsDelegate,BLEDelegate,MBProgressHUDDelegate,LSAlertViewProtocol>
{
    MBProgressHUD *HUD;
    NSInteger numberOfDFUTriedTimes;
}


@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) CBPeripheral *selectedPeripheral;
@property (nonatomic, strong) DFUOperations *dfuOperations;
@property (nonatomic, strong) DFUHelper *dfuHelper;
@property (nonatomic, strong) BLEController *blec;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, copy) NSString *selectedFileType;
@property (nonatomic, copy) NSString *selectedFileURL;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;
@property BOOL isUploadCanPush;

@end

@implementation MZJDFUViewController

//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        PACKETS_NOTIFICATION_INTERVAL = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
//        NSLog(@"PACKETS_NOTIFICATION_INTERVAL %d",PACKETS_NOTIFICATION_INTERVAL);
//        self.dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
//        self.dfuHelper = [[DFUHelper alloc] initWithData:self.dfuOperations];
//    }
//    return self;
//}

- (UITableView *)mainTableView{
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height) style:UITableViewStylePlain];
        [self.view addSubview:_mainTableView];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.tableFooterView = [[UIView alloc]init];
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
 
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_ios7"] forBarMetrics:UIBarMetricsDefault];
//    UIImageView *imageView_bg = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    imageView_bg.image = [UIImage imageNamed:@"BG"];
//    [self.view addSubview:imageView_bg];
    self.view.backgroundColor = [UIColor whiteColor];
    [self mainTableView];
    
    [self enableOtherButtons];
    
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"正在初始化...";
    HUD.removeFromSuperViewOnHide = YES;
    [HUD show:YES];
    numberOfDFUTriedTimes = 0;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
    
    UIButton *button_Exit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button_Exit];
    button_Exit.frame = CGRectMake(0, 520, 120, 44);
    CGPoint center = self.view.center;
    center.y = 400;
    button_Exit.center = center;
    [button_Exit setTitle:@"Exit" forState:UIControlStateNormal];
    [button_Exit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
}

- (void)exit{
    [self.centralManager cancelPeripheralConnection:_peripheral];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)timerAction{
    
    [self centralManager:self.centralManager didPeripheralSelected:self.peripheral];
    
    [self onFileTypeSelected:[Utility getFirmwareTypes][2]];
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"%s",__func__);
    
//    HUD.labelText = @"Searching Bluetooth...";
    
//    sleep(1);
//    [self setSelectedPeripheraWithCentralManager:self.centralManager peripheral:self.peripheral];
//    HUD.labelText = @"Connect to DEvice...";
//    sleep(2);
//    [self setSelectedZipFileWithURL:self.downloadFilePath];
//    HUD.labelText = @"Unzip Files...";
//    sleep(2);
//    [self setSelectedFileType:[Utility getFirmwareTypes][2]];
//    HUD.labelText = @"Checking Selected File Type...";
//    sleep(1);
//    HUD.labelText = @"StartDFU...";
//    [self startDFU];
//    [self centralManager:self.centralManager didPeripheralSelected:self.peripheral];
    
//    [self centralManager:self.centralManager didPeripheralSelected:self.peripheral];
    
//    [self onFileTypeSelected:[Utility getFirmwareTypes][2]];
    
    
}

- (void)enableUploadButton{
    NSLog(@"%s",__func__);
    NSLog(@"%@",self.selectedPeripheral);
//    NSLog(@"%@",self.selectedFileType);
    NSLog(@"%ld",self.dfuHelper.selectedFileSize);
    NSLog(@"%d",self.isConnected);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.selectedFileType && self.dfuHelper.selectedFileSize > 0) {
            if ([self.dfuHelper isValidFileSelected]) {
                NSLog(@" valid file selected");
            }
            else {
                NSLog(@"Valid file not available in zip file");
                [Utility showAlert:[self.dfuHelper getFileValidationMessage]];
                return;
            }
        }
        if (!self.dfuHelper.isDfuVersionExist) {
            NSLog(@"3453453534");
            if (self.selectedPeripheral && self.selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion >= 1) {
                if ([self.dfuHelper isInitPacketFileExist]) {
                    self.isUploadCanPush = YES;
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
                    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
                    cell.textLabel.textColor = [UIColor blueColor];
                    
                }
                else {
                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else {
                NSLog(@"cant enable Upload button");
            }
        }
        else {
            NSLog(@"333333");
            
            if (self.selectedPeripheral && self.dfuHelper.enumFirmwareType && self.dfuHelper.selectedFileSize > 0 && self.isConnected) {
                self.isUploadCanPush = YES;
                NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
                UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
                cell.textLabel.textColor = [UIColor blueColor];
            }
            else {
                NSLog(@"cannot enable Upload button");
            }
        }
        
    });
}

- (void)disableOtherButtons{
    NSLog(@"%s",__func__);
    self.isUploadCanPush = YES;
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
    cell.textLabel.textColor = [UIColor colorWithRed:0.035 green:0.430 blue:0.906 alpha:1.000];
}

- (void)enableOtherButtons{
    NSLog(@"%s",__func__);
    self.isUploadCanPush = NO;
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
    cell.textLabel.textColor = [UIColor grayColor];
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterBackground");
    if (self.isConnected && self.isTransferring) {
        [Utility showBackgroundNotification:[self.dfuHelper getUploadStatusMessage]];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterForeground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRow = 0;
    if (section == 0) {
        numberOfRow = 1;
    }
    if (section == 1) {
        numberOfRow = 4;
    }
    if (section == 2) {
        numberOfRow = 1;
    }
    return numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
//        cell.backgroundColor = [UIColor clearColor];
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section == 0 && indexPath.row == 0) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 35)];
            [cell addSubview:label];
            label.tag = 100;
//            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:25];
            label.text = @"DEFAULT DFU";
//            label.backgroundColor = [UIColor clearColor];
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
        
            cell.textLabel.text = @"Name :";
        }
        if (indexPath.section == 1 && indexPath.row == 1) {
            cell.textLabel.text = @"Size :";
        }
        if (indexPath.section == 1 && indexPath.row == 2) {
            cell.textLabel.text = @"Type :";
            cell.detailTextLabel.textColor = [UIColor darkTextColor];
            cell.detailTextLabel.text = @"Required";
        }
        if (indexPath.section == 1 && indexPath.row == 3) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.035 green:0.430 blue:0.906 alpha:1.000];
            cell.textLabel.text = @"Select File ";
        }
        if (indexPath.section == 1 && indexPath.row == 4) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.035 green:0.430 blue:0.906 alpha:1.000];
            cell.textLabel.text = @"Select File Type";
        }
        if (indexPath.section == 2 && indexPath.row == 0) {
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"Upload";
        }
        
        
    }
    [cell layoutSubviews];
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
        if (indexPath.section == 0 && indexPath.row == 0) {
            ScannerViewController *scanController = [[ScannerViewController alloc]init];
            scanController.delegate = self;
            
            [self presentViewController:scanController animated:YES completion:nil];
        }
        if (indexPath.section == 1 && indexPath.row == 3) {
            
            MZJAPPFilesViewController *appFileController = [[MZJAPPFilesViewController alloc]init];
            appFileController.delegate = self;

            MZJUserFilesViewController *userFileController = [[MZJUserFilesViewController alloc]init];
            userFileController.delegate = self;
            
            appFileController.tabBarItem.image = [UIImage imageNamed:@"storage"];
            appFileController.tabBarItem.title = @"APP Files";
            userFileController.tabBarItem.image = [UIImage imageNamed:@"smiley-smile"];
            userFileController.tabBarItem.title = @"User Files";
            UITabBarController *tabController = [[UITabBarController alloc]init];
            tabController.viewControllers = @[appFileController,userFileController];
            
            [self presentViewController:tabController animated:YES completion:nil];
        }
        if (indexPath.section == 1 && indexPath.row == 4) {
            
            MZJFileTypeController *filetypeController = [[MZJFileTypeController alloc]init];
            filetypeController.delegate = self;
            [self presentViewController:filetypeController animated:YES completion:nil];
        }
    if (self.isUploadCanPush) {

        if (indexPath.section == 2 && indexPath.row == 0) {
            
            HUD = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.labelText = @"开始 DFU...";
            HUD.removeFromSuperViewOnHide = YES;
            [HUD show:YES];
            
            NSLog(@"%@",@" Upload Button Clicked ");
//            if ([self getAppJsonVersionNumber] <= [MZJCurrentPlayer shared].currentFirmwareVersion.intValue) {
            if (1) {
                if (self.isTransferring) {
                    [self.dfuOperations cancelDFU];
                }else{
                    self.dfuHelper.selectedFileURL = self.selectedFileURL;
                    self.dfuHelper.isSelectedFileZipped = YES;
                    [self.dfuHelper checkAndPerformDFU];
                }
            }else{
                [self showTheWebFirmwareVersionIsNotHigherThenLocalFirmware];
            }
        }
    }
}

- (void)showTheWebFirmwareVersionIsNotHigherThenLocalFirmware{
    
    LSAlertVierw *alertView = [[LSAlertVierw alloc]initWithTitle:@"Cannot Update"
                                                         message:@"Your selected firmware version is old"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
    [alertView show];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, 35)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightTextColor];
    
    if (section == 0) {
        label.text = @"Select Device";
    }
    if (section == 1) {
        label.text = @"Firmware";
    }
    if (section == 2) {
        label.text = @"Device firmware Update";
    }
    return  label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

#pragma mark Device Selection Delegate
-(void)centralManager:(CBCentralManager *)manager didPeripheralSelected:(CBPeripheral *)peripheral
{
    NSLog(@"%s",__func__);
//    self.selectedPeripheral = [CBPeripheral init];
    self.selectedPeripheral = peripheral;
    
    self.dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    self.dfuHelper = [[DFUHelper alloc] initWithData:self.dfuOperations];
    self.isConnected = YES;
    
    [self.dfuOperations setCentralManager:manager];
//    deviceName.text = peripheral.name;
    [self.dfuOperations connectDevice:peripheral];
    
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag:100];
    label.text = peripheral.name;
    
    
}

- (void)showChooseBluetoothDeviceAlertView{
    
    LSAlertVierw *alertView = [[LSAlertVierw alloc]initWithTitle:@"Connect to BLE first"
                                                         message:@"You must be connected to a BLE "
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
    [alertView show];
}

- (int)getAppJsonVersionNumber{
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:self.dfuHelper.appJsonFileURL];
    int verNumber = (int)[dict objectForKey:@"fw_version"];
    
    NSData *data = [NSData dataWithContentsOfURL:self.dfuHelper.appJsonFileURL];
    NSLog(@"version Number:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    return verNumber;
}


#pragma mark file Selection delegate
- (void)onFileSelected:(NSURL *)fileURL{
    NSLog(@"%s",__func__);
    
    self.dfuHelper.selectedFileURL = fileURL;
    self.selectedFileURL = fileURL;
    if (self.dfuHelper.selectedFileURL == nil) {
        [self showChooseBluetoothDeviceAlertView];
    }
    
    if (self.dfuHelper.selectedFileURL != nil) {
        NSLog(@"%@",self.dfuHelper.selectedFileURL);
        NSString *selectedFileName = [[fileURL path] lastPathComponent];
        NSLog(@"filename  %@",selectedFileName);
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        self.dfuHelper.selectedFileSize = fileData.length;
        
        NSString *extension = [selectedFileName substringFromIndex:selectedFileName.length -3];
        NSLog(@"selected files extension is  %@",extension);
        if ([extension isEqualToString:@"zip"]) {
            NSLog(@"%@",@"this is zip file");
            self.dfuHelper.isSelectedFileZipped = YES;
            self.dfuHelper.isManifestExist = NO;
            [self.dfuHelper unzipFiles:self.dfuHelper.selectedFileURL];
//            [self getAppJsonVersionNumber];
        }
        else{
            self.dfuHelper.isSelectedFileZipped = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *pathOfName = [NSIndexPath indexPathForRow:0 inSection:1];
            UITableViewCell *nameCell = [self.mainTableView cellForRowAtIndexPath:pathOfName];
//            nameCell.detailTextLabel.textColor = [UIColor whiteColor];
            nameCell.detailTextLabel.text = selectedFileName;
            NSIndexPath *pathOfSize = [NSIndexPath indexPathForRow:1 inSection:1];
            UITableViewCell *sizeCell = [self.mainTableView cellForRowAtIndexPath:pathOfSize];
//            sizeCell.detailTextLabel.textColor = [UIColor whiteColor];
            sizeCell.detailTextLabel.text = [NSString stringWithFormat:@"%lu bytes",(unsigned long)self.dfuHelper.selectedFileSize];
            
        });
        [self enableUploadButton];
    }
    else{
        [Utility showAlert:@"Selected file not exist"];
    }
}

- (void)onFileTypeSelected:(NSString *)selectedFileTypeddd{
    NSLog(@"%s",__func__);
    NSLog(@"%@",selectedFileTypeddd);
    [HUD hide:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
//        UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
//        if (cell) {
//            NSLog(@"%@",selectedFileTypeddd);
//            //            cell.detailTextLabel.textColor = [UIColor whiteColor];
//            cell.detailTextLabel.text = selectedFileTypeddd;
//        }
        self.selectedFileType = @"";
        self.selectedFileType = selectedFileTypeddd;
        
        [self.dfuHelper setFirmwareType:selectedFileTypeddd];
        [self enableUploadButton];
    });
    
}



#pragma mark DFUOperations delegate methods

-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnected %@",peripheral.name);
    
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
//    [self enableUploadButton];
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"device disconnected %@",peripheral.name);
    
    self.isTransferring = NO;
    self.isConnected = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion != 1) {
            if (!self.isTransfered && !self.isTransferCancelled && !self.isErrorKnown) {
                if ([Utility isApplicationStateInactiveORBackground]) {
                    [Utility showBackgroundNotification:[NSString stringWithFormat:@"%@ peripheral is disconnected.",peripheral.name]];
                }
                else {
//                    [Utility showAlert:@"The connection has been lost"];
                    
                    numberOfDFUTriedTimes += 1;
                    NSLog(@"NUMBEROFTRIEDTIMES: %ld",numberOfDFUTriedTimes);
                    if (numberOfDFUTriedTimes == 1) {
                        [self viewDidAppear:YES];
                    }
                    if (numberOfDFUTriedTimes == 2) {
                        [HUD hide:YES];
                        [MBProgressHUD showError:@"DFU Failed"];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
            }
            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
        }
        else {
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
    if (self.dfuHelper.dfuVersion == 1) {
        [self.dfuOperations setAppToBootloaderMode];
    }
    [self enableUploadButton];
}

-(void)onDFUStarted
{
    NSLog(@"onDFUStarted");
    
    [HUD hide:YES];
    
    self.isTransferring = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self disableOtherButtons];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
        UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:uploadStatusMessage];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.detailTextLabel.textColor = [UIColor whiteColor];
//                cell.detailTextLabel.text = uploadStatusMessage;
//                
//                self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 45, self.view.bounds.size.width, 5)];
//                [cell addSubview:self.progressView];
//                [self.progressView setTrackTintColor:[UIColor blueColor]];
            });
        }
    });
    self.isUploadCanPush = NO;
}

-(void)onDFUCancelled
{
    NSLog(@"%s",__func__);
    NSLog(@"onDFUCancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableOtherButtons];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:@"uploading bootloader ..."];
        }
        else {
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
            UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
            cell.detailTextLabel.text = @"uploading bootloader ...";
        }
    });
    
    
}

-(void)onBootloaderUploadCompleted
{
    NSLog(@"onBootloaderUploadCompleted");
}

-(void)onTransferPercentage:(int)percentage
{
    NSLog(@"onTransferPercentage %d",percentage);
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:path];
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD.labelText = [NSString stringWithFormat:@"Completed %d%%",percentage];
        [self.progressView setProgress:((float)percentage/100.0) animated:YES];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %%", percentage];
        if (percentage >= 99) {
            self.isUploadCanPush = NO;
            cell.detailTextLabel.text = @"Successful";
        }
        
    });
//    [RappleActivityIndicatorView startAnimatingWithLabel:@"start"];
//    [RappleActivityIndicatorView setProgress:percentage/100 textValue:[NSString stringWithFormat:@"%d",percentage/100]];
}

-(void)onSuccessfulFileTranferred
{
    NSLog(@"OnSuccessfulFileTransferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)self.dfuOperations.binFileSize, (unsigned long)self.dfuOperations.uploadTimeInSeconds];
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:message];
        }
        else {
//            [Utility showAlert:message];
            HUD.delegate = self;
            [HUD hide:YES];
            [MBProgressHUD showSuccess:@"Successful"];
            
        }
        
    });
}


-(void)onError:(NSString *)errorMessage
{
    NSLog(@"OnError %@",errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utility showAlert:errorMessage];
//        [self clearUI];
    });
}

#pragma mark What the Fuck 

- (void)setSelectedPeripheraWithCentralManager:(CBCentralManager *)centralManager peripheral:(CBPeripheral *)peripheral{
    NSLog(@"%s",__func__);
    ScannerViewController  *scannerVC = [[ScannerViewController alloc]init];
    scannerVC.delegate = self;
    [scannerVC.delegate centralManager:centralManager didPeripheralSelected:peripheral];
    
}

- (void)setSelectedZipFileWithURL:(NSURL *)url{
    NSLog(@"%s",__func__);
    MZJUserFilesViewController *vc = [[MZJUserFilesViewController alloc]init];
    vc.delegate = self;
    [vc.delegate onFileSelected:url];
}

- (void)setSelectedFileType:(NSString *)selectedFileType{
    NSLog(@"%s",__func__);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MZJFileTypeController *vc = [[MZJFileTypeController alloc]init];
        vc.delegate = self;
        [vc.delegate onFileTypeSelected:selectedFileType];
        [self enableUploadButton];
    });
    
}

- (void)startDFU{
    NSLog(@"%s",__func__);
    if (!self.isUploadCanPush) {
            NSLog(@"%@",@" Upload Button Clicked ");
        if (self.isTransferring) {
            [self.dfuOperations cancelDFU];
        }else{
            [self.dfuHelper checkAndPerformDFU];
        }
    }else{
        NSLog(@"%@",@"isUpLoadButtonCanPush==NO");
    }
}
@end
