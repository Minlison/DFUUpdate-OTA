//
//  DFUManager.h
//  DFUManager
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DFUManager.
FOUNDATION_EXPORT double DFUManagerVersionNumber;

//! Project version string for DFUManager.
FOUNDATION_EXPORT const unsigned char DFUManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DFUManager/PublicHeader.h>



#if __has_include(<DFUManager/DFUManager.h>)
#import <DFUManager/DFUTool.h>
#else
#import "DFUTool.h"
#endif
