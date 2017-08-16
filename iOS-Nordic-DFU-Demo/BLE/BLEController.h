//
//  BLEController.h
//  TenCount
//
//  Created by Shaun Robinson on 01/06/2016.
//  Copyright © 2016 redbear. All rights reserved.
//

#ifndef BLEController_h
#define BLEController_h

#import "BLE.h"

@interface BLEController : NSObject<BLEDelegate>
{
    BLE *device;
}

@property(nonatomic, retain) BLE *device;

+ (id)sharedManager;
- (void)connect;
- (void)discover;

@end

#endif /* BLEController_h */
