//
//  LSAlertVierw.h
//  LSAlertViewDemo
//
//  Created by 刘爽 on 17/1/11.
//  Copyright © 2017年 MZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSAlertVierw;
///LSAlertView Style
typedef enum : NSUInteger {
    LSAlertVierwStyleNormal = 0,
    LSAlertVierwStyleSecurityTextInput,
    LSAlertVierwStylePlainTextInput,
    LSAlertVierwStyleLoginAndPasswordInput,
} LSAlertVierwStyle;

@protocol LSAlertViewProtocol <NSObject>
@optional
- (void)LSAlertView:(LSAlertVierw *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

-(void)LSAlertView:(LSAlertVierw *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)LSAlertView:(LSAlertVierw *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)LSAlertViewWillPresent:(LSAlertVierw *)alertView;

- (void)LSAlertViewDidPresented:(LSAlertVierw *)alertView;
@end

@interface LSAlertVierw : UIView
///标题
@property (nonatomic, assign) NSString *title;
///
@property (nonatomic, strong) UIColor *titleTextColor;
///内容
@property (nonatomic, assign) NSString *message;
///
@property (nonatomic, strong) UIColor *messageTextColor;
///
@property (nonatomic, strong) UIColor *buttonBackGroundColor;
///
@property (nonatomic, strong) UIColor *buttonTextColor;
///代理
@property (nonatomic, weak) id <LSAlertViewProtocol> delegate;
///
@property (nonatomic, strong) UIColor *backGroundColor;
///
@property (nonatomic, assign) LSAlertVierwStyle alertViewStyle;


///init LSAlertView,must use this method to allocate;必须用这个方法初始化；
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

- (UITextField *)textFieldWithIndex:(NSInteger)index;
@end
