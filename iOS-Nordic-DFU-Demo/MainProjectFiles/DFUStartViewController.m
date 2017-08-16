//
//  DFUStartViewController.m
//  TenCount
//
//  Created by 刘爽 on 2017/3/19.
//  Copyright © 2017年 redbear. All rights reserved.
//

#import "DFUStartViewController.h"
#import "UIView+WHC_AutoLayout.h"
#import "MZJDFUViewController.h"


@interface DFUStartViewController ()



@end

@implementation DFUStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
//    button.whc_CenterX(0).whc_CenterY(0).whc_Width(200).whc_Height(44);
    button.frame = CGRectMake(0, 0, 200, 44);
    button.center = self.view.center;
    [button setTitle:@"开始 DFU" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)buttonAction {
    
//    [RappleActivityIndicatorView startAnimatingWithLabel:@"搜索蓝牙..."];
//    [MainViewController shared].block_DDDD = ^(CBCentralManager *manager, CBPeripheral *peri) {
//        MZJDFUViewController *dfuvc = [[MZJDFUViewController alloc] init];
//        dfuvc.centralManager = manager;
//        dfuvc.peripheral = peri;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:dfuvc animated:YES completion:nil];
//        });
//    };
//    
//    
//    [self presentViewController:[MainViewController shared] animated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
