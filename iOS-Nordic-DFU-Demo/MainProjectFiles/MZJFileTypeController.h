//
//  MZJFileTypeController.h
//  TenCount
//
//  Created by 刘爽 on 16/8/24.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZJFileSelectedDelegate.h"
@interface MZJFileTypeController : UIViewController

@property (nonatomic, weak) id <MZJFileTypeSelectionDelegate> delegate;

@end
