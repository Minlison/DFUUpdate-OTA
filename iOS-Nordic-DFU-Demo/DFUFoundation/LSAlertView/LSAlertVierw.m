//
//  LSAlertVierw.m
//  LSAlertViewDemo
//
//  Created by 刘爽 on 17/1/11.
//  Copyright © 2017年 MZJ. All rights reserved.
//

#import "LSAlertVierw.h"

static CGFloat kTextField_Height = 35;
static CGFloat kLabel_Title_Height = 30;
static CGFloat kButton_Height = 40;
static NSInteger kTagOfPlainInputViewTextField = 1000;
static NSInteger kTagOfSecurityInputViewTextField = 1001;
static NSInteger kTagOfLoginPasswordViewNameTextField = 1002;
static NSInteger kTagOfLoginPasswordViewPasswdTextField = 1003;
static NSInteger kTagOfButtonCancel = 100;
static CGFloat kTextViewMaximumHeight = 150;
static CGFloat kButtonTotalHeight = 200;

@implementation LSAlertVierw
{
    LSAlertVierwStyle alertViewStyleType;
    NSString *alertViewTitle;
    NSString *alertViewMessage;
    NSString *alertViewCancelButtonTitle;
    NSMutableArray *otherButtonTitleList;
    UIImageView *alertViewBackGroundImageView;
    UIViewController *currentVisibleController;
    UIColor *alertViewTitleTextColor;
    UIColor *alertViewMessageTextColor;
    UIColor *alertViewButtonTextColor;
    UIColor *alertViewBackGroundColor;
    UIColor *alertViewButtonBackGroundColor;
    
    UILabel *label_Title;
    UITextView *textView_Message;
    CGFloat frame_Width;
    CGFloat frame_Height;
    NSMutableArray *array_ButtonTag;
}
- (instancetype)init{
    NSAssert(0, @"不要用这个方法创建对象，用别的");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    NSAssert(0, @"不要用这个方法创建对象，用别的");
    return nil;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    otherButtonTitleList = [NSMutableArray array];
    va_list parameters;
    va_start(parameters, otherButtonTitles);
    for (id item = otherButtonTitles; item != nil; item = va_arg(parameters, id)) {
        [otherButtonTitleList addObject:item];
    }
    va_end(parameters);
    
    alertViewTitle = title;
    alertViewMessage = message;
    self.delegate = delegate;
    alertViewCancelButtonTitle = cancelButtonTitle;
    alertViewStyleType = LSAlertVierwStyleNormal;
    currentVisibleController = delegate;
    if (currentVisibleController == nil) {
        currentVisibleController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    alertViewTitleTextColor = [UIColor blackColor];
    alertViewMessageTextColor = [UIColor grayColor];
    alertViewBackGroundColor = [UIColor whiteColor];
    alertViewButtonTextColor = [UIColor whiteColor];
    alertViewButtonBackGroundColor = [UIColor colorWithRed:0x00 green:0x00 blue:0xfe alpha:0.5];
    
    
    self = [super initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [self viewInit];
    return self;
}

- (void)setTitle:(NSString *)title{
    alertViewTitle = title;
    label_Title.text = title;
}
- (void)setTitleTextColor:(UIColor *)titleTextColor{
    alertViewTitleTextColor = titleTextColor;
    label_Title.textColor = titleTextColor;
}
- (void)setMessage:(NSString *)message{
    alertViewMessage = message;
}
- (void)setMessageTextColor:(UIColor *)messageTextColor{
    alertViewMessageTextColor = messageTextColor;
}
- (void)setAlertViewStyle:(LSAlertVierwStyle)alertViewStyle{
    alertViewStyleType = alertViewStyle;
}
- (void)setBackGroundColor:(UIColor *)backGroundColor{
    alertViewBackGroundColor = backGroundColor;
}
- (void)setButtonTextColor:(UIColor *)buttonTextColor{
    alertViewButtonTextColor = buttonTextColor;
}
- (void)setButtonBackGroundColor:(UIColor *)buttonBackGroundColor{
    alertViewButtonBackGroundColor = buttonBackGroundColor;
}

- (void)viewInit{
    CGFloat width_Screen = [UIScreen mainScreen].bounds.size.width;
    CGFloat height_Screen = [UIScreen mainScreen].bounds.size.height;
    frame_Width = width_Screen / 3 * 2;
    self.frame = CGRectMake(0, 0, frame_Width, 100);
    self.layer.cornerRadius = 20;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowOffset = CGSizeMake(2.5, 2.5);
    self.layer.shadowColor = [UIColor greenColor].CGColor;
    self.layer.shadowRadius = 2;
    
    self.center = CGPointMake(width_Screen / 2, height_Screen / 2);
    
    label_Title = [UILabel new];
    [self addSubview:label_Title];
    label_Title.frame = CGRectMake(20, 10, frame_Width - 40, kLabel_Title_Height);
    label_Title.textAlignment = NSTextAlignmentCenter;
    label_Title.textColor = alertViewTitleTextColor;
    label_Title.font = [UIFont systemFontOfSize:23];
    label_Title.numberOfLines = 0;
    label_Title.text = alertViewTitle;
    CGSize size = [label_Title sizeThatFits:CGSizeMake(frame_Width - 40, MAXFLOAT)];
    CGRect frame = label_Title.frame;
    frame.size.height = size.height;
    label_Title.frame = frame;
}

- (void)viewAddComponents{
    if (alertViewStyleType == LSAlertVierwStyleNormal) {
        [self addComponents_ViewStyleNormal];
    }else if (alertViewStyleType == LSAlertVierwStylePlainTextInput){
        [self addComponents_ViewStylePlainInput];
    }else if (alertViewStyleType == LSAlertVierwStyleSecurityTextInput){
        [self addComponents_ViewSecurityInput];
    }else if (alertViewStyleType == LSAlertVierwStyleLoginAndPasswordInput){
        [self addComponents_ViewLoginPasswdInput];
    }
    
    [self addComponents_BottomButtons];
    CGPoint center = self.center;
    center.y = [UIScreen mainScreen].bounds.size.height / 2;
    self.center = center;
}

- (void)addComponents_ViewStyleNormal{
    textView_Message = [UITextView new];
    [self addSubview:textView_Message];
    textView_Message.frame = CGRectMake(10, CGRectGetMaxY(label_Title.frame) + 10, frame_Width - 20, 40);
    textView_Message.textAlignment = NSTextAlignmentCenter;
    textView_Message.textColor = alertViewMessageTextColor;
    textView_Message.font = [UIFont systemFontOfSize:15];
    textView_Message.text = alertViewMessage;
    textView_Message.editable = NO;
    textView_Message.scrollEnabled = YES;
    CGSize size = [textView_Message sizeThatFits:CGSizeMake(frame_Width - 20, kTextViewMaximumHeight)];
    if (size.height > kTextViewMaximumHeight) {
        size.height = kTextViewMaximumHeight;
    }
    CGRect frame = textView_Message.frame;
    frame.size.height = size.height;
    textView_Message.frame = frame;
    frame_Height = CGRectGetMaxY(textView_Message.frame);
}

- (void)addComponents_ViewStylePlainInput{
    
    UITextField *textField = [UITextField new];
    [self addSubview:textField];
    textField.tag = kTagOfPlainInputViewTextField;
    textField.frame = CGRectMake(20, CGRectGetMaxY(label_Title.frame) + 25, frame_Width - 40, kTextField_Height);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    frame_Height = CGRectGetMaxY(textField.frame);
    
}

- (void)addComponents_ViewSecurityInput{
    
    UITextField *textField = [UITextField new];
    [self addSubview:textField];
    textField.tag = kTagOfSecurityInputViewTextField;
    textField.frame = CGRectMake(20, CGRectGetMaxY(label_Title.frame) + 20, frame_Width - 40, kTextField_Height);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.secureTextEntry = YES;
    frame_Height = CGRectGetMaxY(textField.frame);
}

- (void)addComponents_ViewLoginPasswdInput{
    
    UITextField *textField_UserName = [UITextField new];
    [self addSubview:textField_UserName];
    textField_UserName.tag = kTagOfLoginPasswordViewNameTextField;
    textField_UserName.frame = CGRectMake(20, CGRectGetMaxY(label_Title.frame) + 20, frame_Width - 40, kTextField_Height);
    textField_UserName.borderStyle = UITextBorderStyleRoundedRect;
    textField_UserName.placeholder = @"Username";
    
    UITextField *textField_Password = [UITextField new];
    [self addSubview:textField_Password];
    textField_Password.tag = kTagOfLoginPasswordViewPasswdTextField;
    textField_Password.frame = CGRectMake(20, CGRectGetMaxY(textField_UserName.frame) + 5, frame_Width - 40, kTextField_Height);
    textField_Password.borderStyle = UITextBorderStyleRoundedRect;
    textField_Password.secureTextEntry = YES;
    textField_Password.placeholder = @"Password";
    frame_Height = CGRectGetMaxY(textField_Password.frame);
}

- (void)addComponents_BottomButtons{
    
    UIButton *button_ButtonCancel = [UIButton new];
    [self addSubview:button_ButtonCancel];
    button_ButtonCancel.frame = CGRectMake(0, frame_Height + 10, frame_Width, kButton_Height);
    [button_ButtonCancel setBackgroundColor:alertViewButtonBackGroundColor];
    [button_ButtonCancel setTitle:alertViewCancelButtonTitle forState:UIControlStateNormal];
    [button_ButtonCancel setTitleColor:alertViewButtonTextColor forState:UIControlStateNormal];
    [button_ButtonCancel setTitleColor:alertViewTitleTextColor forState:UIControlStateHighlighted];
    button_ButtonCancel.tag = kTagOfButtonCancel;
    [button_ButtonCancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    frame_Height = CGRectGetMaxY(button_ButtonCancel.frame);
    if (otherButtonTitleList.count == 1) {
        CGRect buttoncancleFrame = button_ButtonCancel.frame;
        button_ButtonCancel.frame = CGRectMake(0, buttoncancleFrame.origin.y, frame_Width / 2, kButton_Height);
        
        UIButton *button_OtherButton1 = [UIButton new];
        [self addSubview:button_OtherButton1];
        button_OtherButton1.tag = kTagOfButtonCancel + 1;
        button_OtherButton1.frame = CGRectMake(frame_Width / 2 + 1, buttoncancleFrame.origin.y, frame_Width / 2, kButton_Height);
        [button_OtherButton1 setTitle:otherButtonTitleList[0] forState:UIControlStateNormal];
        [button_OtherButton1 setTitleColor:alertViewButtonTextColor forState:UIControlStateNormal];
        [button_OtherButton1 setBackgroundColor:alertViewButtonBackGroundColor];
        [button_OtherButton1 setTitleColor:alertViewTitleTextColor forState:UIControlStateHighlighted];
        [button_OtherButton1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//        frame_Height = CGRectGetMaxY(button_OtherButton1.frame);
        
    }else if (otherButtonTitleList.count > 1){
        CGFloat buttonHeight = kButton_Height;
        if ((otherButtonTitleList.count + 1) * kButton_Height > kButtonTotalHeight){
            buttonHeight = kButtonTotalHeight / (otherButtonTitleList.count + 1);
        }
        array_ButtonTag = [NSMutableArray array];
        [array_ButtonTag addObject:[NSNumber numberWithInteger:kTagOfButtonCancel]];
        CGFloat spacingVertical_Button = 2.5;
        for (int i = 0; i < otherButtonTitleList.count; i++) {
            UIButton *button = [UIButton new];
            [self addSubview:button];
            button.tag = kTagOfButtonCancel + i + 1;
            [array_ButtonTag addObject:[NSNumber numberWithInteger:button.tag]];
            button.frame = CGRectMake(0, CGRectGetMaxY(button_ButtonCancel.frame) + spacingVertical_Button  + i * (buttonHeight + spacingVertical_Button), frame_Width, buttonHeight);
            [button setBackgroundColor:alertViewButtonBackGroundColor];
            [button setTitle:otherButtonTitleList[i] forState:UIControlStateNormal];
            [button setTitleColor:alertViewButtonTextColor forState:UIControlStateNormal];
            [button setTitleColor:alertViewTitleTextColor forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            frame_Height = CGRectGetMaxY(button.frame);
        }
    }
    CGRect frame = self.frame;
    frame.size.height = frame_Height;
    self.frame = frame;
}

- (void)show{
    NSLog(@"%@",self);
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(LSAlertViewWillPresent:)]) {
        [self.delegate LSAlertViewWillPresent:self];
    }
    
//    currentVisibleController = [self obtainWidowsTopViewController];
    NSLog(@"%@",currentVisibleController);
    UIView *view_BG = [UIView new];
    view_BG.tag = 21;
    CGRect frame = [UIScreen mainScreen].bounds;
    view_BG.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    view_BG.userInteractionEnabled = YES;
    view_BG.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [view_BG addGestureRecognizer:tap];
    
    [currentVisibleController.view addSubview:view_BG];
    
    [self viewAddComponents];
    
    [currentVisibleController.view addSubview:self];
    
    if ([self.delegate respondsToSelector:@selector(LSAlertViewDidPresented:)]) {
        [self.delegate LSAlertViewDidPresented:self];
    }
}

- (void)tapAction{
    ;
}

- (UITextField *)textFieldWithIndex:(NSInteger)index{
    
    if (alertViewStyleType == LSAlertVierwStylePlainTextInput && index == 0) {
        UITextField *textField = [self viewWithTag:kTagOfPlainInputViewTextField];
        return textField;
    }
    if (alertViewStyleType == LSAlertVierwStyleSecurityTextInput && index == 0) {
        UITextField *textField = [self viewWithTag:kTagOfSecurityInputViewTextField];
        return textField;
    }
    if (alertViewStyleType == LSAlertVierwStyleLoginAndPasswordInput && index == 0) {
        UITextField *textField = [self viewWithTag:kTagOfLoginPasswordViewNameTextField];
        return textField;
    }
    if (alertViewStyleType == LSAlertVierwStyleLoginAndPasswordInput && index == 1) {
        UITextField *textField = [self viewWithTag:kTagOfLoginPasswordViewPasswdTextField];
        return textField;
    }
    return nil;
}

- (UIViewController *)obtainWidowsTopViewController{
    NSLog(@"%s",__func__);
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] windows].lastObject;
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    
    id  nextResponder = nil;
    UIViewController *appRootVC = window.rootViewController;
    result = appRootVC;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [window subviews].lastObject;
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result = nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }

    return result;
}

- (void)dismiss{
    UIView *view = [currentVisibleController.view viewWithTag:21];
    [view removeFromSuperview];
    view = nil;
    [currentVisibleController setEditing:NO animated:YES];
    [self removeFromSuperview];
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark --TouchAction
- (void)buttonAction:(UIButton *)button{
    NSLog(@"%@ %ld",button.titleLabel.text,button.tag);
    NSInteger buttonIndex = button.tag - kTagOfButtonCancel;
    if ([self.delegate respondsToSelector:@selector(LSAlertView:clickedButtonAtIndex:)]) {
        [self.delegate LSAlertView:self clickedButtonAtIndex:buttonIndex];
    }
    if ([self.delegate respondsToSelector:@selector(LSAlertView:willDismissWithButtonIndex:)]) {
        [self.delegate LSAlertView:self willDismissWithButtonIndex:buttonIndex];
    }
    
    [self dismiss];
    
    if ([self.delegate respondsToSelector:@selector(LSAlertView:didDismissWithButtonIndex:)]) {
        [self.delegate LSAlertView:self didDismissWithButtonIndex:buttonIndex];
    }
}

#pragma mark --UIkeyboardNotification
- (void)keyboardFrameDidChange:(NSNotification *)notification{
    
    NSDictionary *noti = [notification userInfo];
    CGRect frame = [[noti objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    
    CGFloat y = self.center.y + self.frame.size.height / 2;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (y > (height - frame.size.height)) {
        CGFloat bottom = height - frame.size.height - 20;
        CGFloat centerY = bottom - self.frame.size.height / 2;
        CGPoint center = self.center;
        center.y = centerY;
        [UIView animateWithDuration:0.3 animations:^{
            self.center = center;
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ;
}

@end
