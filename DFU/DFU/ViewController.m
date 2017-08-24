//
//  ViewController.m
//  DFU
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "ViewController.h"
#import "DFUTool.h"
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"
#import "UpdateViewController.h"
@interface ViewController ()
{
        NSMutableArray *peripheralDataArray;
        BabyBluetooth *baby;
}
@property(nonatomic, strong) DFUTool *updateTool;
@end

@implementation ViewController


- (void)viewDidLoad {
        [super viewDidLoad];
        
        [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
        peripheralDataArray = [[NSMutableArray alloc]init];
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        
}

-(void)viewDidAppear:(BOOL)animated{
        //停止之前的连接
        [baby cancelAllPeripheralsConnection];
        baby.scanForPeripherals().begin();
}

#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
        
        __weak typeof(self) weakSelf = self;
        [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
                if (central.state == CBCentralManagerStatePoweredOn) {
                        [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
                }
        }];
        
        //设置扫描到设备的委托
        [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                NSLog(@"搜索到了设备:%@",peripheral.name);
                [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
        }];
        
        
        //设置发现设service的Characteristics的委托
        [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
                NSLog(@"===service name:%@",service.UUID);
                for (CBCharacteristic *c in service.characteristics) {
                        NSLog(@"charateristic name is :%@",c.UUID);
                }
        }];
        
        //设置读取characteristics的委托
        [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        }];
        
        //设置发现characteristics的descriptors的委托
        [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
                NSLog(@"===characteristic name:%@",characteristic.service.UUID);
                for (CBDescriptor *d in characteristic.descriptors) {
                        NSLog(@"CBDescriptor name is :%@",d.UUID);
                }
        }];
        //设置读取Descriptor的委托
        [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
                NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
        }];
        
        
        //设置查找设备的过滤器
        [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
                
                //最常用的场景是查找某一个前缀开头的设备
                //        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
                //            return YES;
                //        }
                //        return NO;
                
                //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
                if (peripheralName.length >0) {
                        return YES;
                }
                return NO;
        }];
        
        
        [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
                NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
        }];
        
        [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
                NSLog(@"setBlockOnCancelScanBlock");
        }];
        
        
        /*设置babyOptions
         
         参数分别使用在下面这几个地方，若不使用参数则传nil
         - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
         - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
         - [peripheral discoverServices:discoverWithServices];
         - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
         
         该方法支持channel版本:
         [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
         */
        
        //示例:
        //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
        NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
        //连接设备->
        NSArray *scanForService = @[[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"]]; // 蓝牙设备连接服务
        [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:scanForService discoverWithServices:nil discoverWithCharacteristics:nil];
}

#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
        
        NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
        if(![peripherals containsObject:peripheral]) {
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
                [indexPaths addObject:indexPath];
                
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                [item setValue:peripheral forKey:@"peripheral"];
                [item setValue:RSSI forKey:@"RSSI"];
                [item setValue:advertisementData forKey:@"advertisementData"];
                [peripheralDataArray addObject:item];
                
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
}

#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return peripheralDataArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
        NSNumber *RSSI = [item objectForKey:@"RSSI"];
        
        if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
        NSString *peripheralName;
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
                peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
                peripheralName = peripheral.name;
        }else{
                peripheralName = [peripheral.identifier UUIDString];
        }
        
        cell.textLabel.text = peripheralName;
        //信号和服务
        cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];
        
        
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        //停止扫描
        [baby cancelScan];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        UpdateViewController *vc = [[UpdateViewController alloc] init];
        vc.updatePeripheral = peripheral;
        vc.manager = baby.centralManager;
        [self.navigationController pushViewController:vc animated:YES];
        
}

@end
