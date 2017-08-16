//
//  MZJFileSelectedDelegate.h
//  TenCount
//
//  Created by 刘爽 on 16/8/24.
//  Copyright © 2016年 redbear. All rights reserved.
//


#import <UIKit/UIKit.h>
@protocol MZJFileSelectedDelegate

- (void)onFileSelected:(NSURL *)fileURL;


@end


@protocol MZJFileTypeSelectionDelegate

- (void)onFileTypeSelected:(NSString *)selectedFileTypeddd;

@end
