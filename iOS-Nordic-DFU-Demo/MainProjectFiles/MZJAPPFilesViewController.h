//
//  MZJAPPFilesViewController.h
//  TenCount
//
//  Created by 刘爽 on 16/8/23.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZJFileSelectedDelegate.h"
@interface MZJAPPFilesViewController : UIViewController



@property (nonatomic, weak)  id <MZJFileSelectedDelegate> delegate;

@end
