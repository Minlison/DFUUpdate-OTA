//
//  MZJAPPFilesViewController.m
//  TenCount
//
//  Created by 刘爽 on 16/8/23.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import "MZJAPPFilesViewController.h"
#import "AccessFileSystem.h"

@interface MZJAPPFilesViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger numberOfRow;
}

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSArray *array_Files;

@property (nonatomic, copy) NSString *appDirectoryPath;

@property (nonatomic, strong) AccessFileSystem *fileSystem;
@end

@implementation MZJAPPFilesViewController
- (UITableView *)mainTableView{
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
        [self.view addSubview:_mainTableView];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]init];
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIImageView *imageView_bg = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    imageView_bg.image = [UIImage imageNamed:@"BG"];
//    [self.view addSubview:imageView_bg];
    self.view.backgroundColor = [UIColor whiteColor];
    numberOfRow = 3;
    
    self.fileSystem = [[AccessFileSystem alloc]init];
    self.appDirectoryPath = [self.fileSystem getAppDirectoryPath:@"firmwares"];
    self.array_Files = [self.fileSystem getFilesFromAppDirectory:@"firmwares"];
    
    numberOfRow = self.array_Files.count;
    
    
    [self mainTableView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
    button.frame = CGRectMake(10, 20, 60, 44);
    [button setTitle:@"返回" forState: UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = [self.array_Files objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *fileName = [self.array_Files objectAtIndex:indexPath.row];
    NSString *filePath = [self.appDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self.delegate onFileSelected:fileURL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
