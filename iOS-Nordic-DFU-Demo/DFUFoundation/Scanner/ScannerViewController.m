/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ScannerViewController.h"
#import "ScannedPeripheral.h"

@interface ScannerViewController ()

/*!
 * List of the peripherals shown on the table view. Peripheral are added to this list when it's discovered.
 * Only peripherals with bridgeServiceUUID in the advertisement packets are being displayed.
 */
@property (strong, nonatomic) NSMutableArray *peripherals;
/*!
 * The timer is used to periodically reload table
 */
@property (strong, nonatomic) NSTimer *timer;

- (void)timerFireMethod:(NSTimer *)timer;

@end

@implementation ScannerViewController
@synthesize bluetoothManager;
//@synthesize devicesTable;
@synthesize filterUUID;
@synthesize peripherals;
@synthesize timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableView *)devicesTable{
    if (_devicesTable == nil) {
        _devicesTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 120) style:UITableViewStylePlain];
        _devicesTable.delegate = self;
        _devicesTable.dataSource = self;
        [self.view addSubview:_devicesTable];
        _devicesTable.tableFooterView = [[UIView alloc]init];
        _devicesTable.backgroundColor = [UIColor clearColor];
    }
    return _devicesTable;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    peripherals = [NSMutableArray arrayWithCapacity:8];
//    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView_bg = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView_bg.image = [UIImage imageNamed:@"BG"];
    [self.view addSubview:imageView_bg];
    
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
    label.textColor = [UIColor colorWithRed:0.090 green:0.597 blue:0.852 alpha:1.000];
    label.font = [UIFont systemFontOfSize:28];
    label.text = @"Select Devices :";
    [self.view addSubview:label];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, self.view.bounds.size.height - 64, self.view.bounds.size.width - 40, 44)];
    [self.view addSubview:button];
    
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"CANCEL" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
    dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
    
    [self devicesTable];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self scanForPeripherals:NO];
}

- (void)didCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Central Manager delegate methods

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self scanForPeripherals:YES];
    }
}

/*!
 * @brief Starts scanning for peripherals with rscServiceUUID
 * @param enable If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
 * @return 0 if success, -1 if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
 */
- (int) scanForPeripherals:(BOOL)enable
{
    if (bluetoothManager.state != CBCentralManagerStatePoweredOn)
    {
        return -1;
    }
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enable)
        {
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            if (filterUUID != nil)
            {
                [bluetoothManager scanForPeripheralsWithServices:@[ filterUUID ] options:options];
            }
            else
            {
                [bluetoothManager scanForPeripheralsWithServices:nil options:options];
            }
            
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        }
        else
        {
            [timer invalidate];
            timer = nil;
            
            [bluetoothManager stopScan];
        }
    });
    return 0;
}

/*!
 * @brief This method is called periodically by the timer. It refreshes the devices list. Updates from Central Manager comes to fast and it's hard to select a device if refreshed from there.
 * @param timer the timer that has called the method
 */
- (void)timerFireMethod:(NSTimer *)timer
{
    [_devicesTable reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    //NSLog(@"scanned peripheral : %@",peripheral.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        // Add the sensor to the list and reload deta set
        ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue];
        if (![peripherals containsObject:sensor])
        {
            [peripherals addObject:sensor];
        }
        else
        {
            sensor = [peripherals objectAtIndex:[peripherals indexOfObject:sensor]];
            sensor.RSSI = RSSI.intValue;
        }
    });
}

#pragma mark Table View delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [bluetoothManager stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Call delegate method
    [self.delegate centralManager:bluetoothManager didPeripheralSelected:[[peripherals objectAtIndex:indexPath.row] peripheral]];
}

#pragma mark Table View Data Source delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        ScannedPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
        cell.textLabel.text = [peripheral name];
    }
    
    // Update sensor name
    
    
    // Update RSSI indicator
//    int RSSI = peripheral.RSSI;
//    UIImage* image;
//    if (RSSI < -90) {
//        image = [UIImage imageNamed: @"Signal_0"];
//    }
//    else if (RSSI < -70)
//    {
//        image = [UIImage imageNamed: @"Signal_1"];
//    }
//    else if (RSSI < -50)
//    {
//        image = [UIImage imageNamed: @"Signal_2"];
//    }
//    else
//    {
//        image = [UIImage imageNamed: @"Signal_3"];
//    }
//    cell.imageView.image = image;
    return cell;
}

@end
