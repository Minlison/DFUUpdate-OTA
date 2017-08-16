//
//  BLEController.m
//  TenCount
//
//  Created by Shaun Robinson on 01/06/2016.
//  Copyright © 2016 redbear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEController.h"
#import "LSAlertVierw.h"
@implementation BLEController

@synthesize device;

-(void) connectionTimer:(NSTimer *)timer
{
    NSLog(@"timer callback: %lu", (unsigned long)device.peripherals.count);
    if (device.peripherals.count > 0)
    {
        [device connectPeripheral:[device.peripherals objectAtIndex:0]];
    }
    else
    {
        //[indConnect stopAnimation:self];
    }
}

- (IBAction)BLEShieldScan:(id)sender
{
    if (device.activePeripheral)
        if(device.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[device CM] cancelPeripheralConnection:[device activePeripheral]];
            return;
        }
    
    if (device.peripherals)
        device.peripherals = nil;
    
    [device findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    //[activityIndicator startAnimating];
    //self.navigationItem.leftBarButtonItem.enabled = NO;
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [device readRSSI];
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    
}

-(void) bleDidConnect
{
    LSAlertVierw *alert = [[LSAlertVierw alloc] initWithTitle:@"Connected"
                                                    message:@"Connected to BLE device"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}




#pragma mark Singleton Methods

- (void)connect
{
    NSLog(@"BLEController connect");
}

- (void)discover
{
    NSLog(@"BLEController discover");
    [device findBLEPeripherals:5];
}

+ (id)sharedManager
{
    static BLEController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init])
    {
        device = [[BLE alloc] init];
        [device controlSetup];
        device.delegate = self;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


@end
