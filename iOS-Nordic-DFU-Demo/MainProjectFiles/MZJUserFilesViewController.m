//
//  MZJUserFilesViewController.m
//  TenCount
//
//  Created by 刘爽 on 16/8/23.
//  Copyright © 2016年 redbear. All rights reserved.
//

#import "MZJUserFilesViewController.h"
#import "AccessFileSystem.h"




@interface MZJUserFilesViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger numberOfRow;
}
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, copy) NSString *documentsDirectoryPath;
@property (nonatomic, strong) AccessFileSystem *fileSystem;
@end

@implementation MZJUserFilesViewController

- (UITableView *)mainTableView{
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
        [self.view addSubview:_mainTableView];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        imageView.image = [UIImage imageNamed:@"BG"];
        _mainTableView.backgroundView =  imageView;
        _mainTableView.tableFooterView = [[UIView alloc]init];
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];

//    UIImageView *imageView_bg = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    imageView_bg.image = [UIImage imageNamed:@"BG"];
//    [self.view addSubview:imageView_bg];
//
//    numberOfRow = 3;
//    
    self.fileSystem = [[AccessFileSystem alloc]init];
    self.documentsDirectoryPath = [self.fileSystem getDocumentsDirectoryPath];
    self.files = [[self.fileSystem getDirectoriesAndRequiredFilesFromDocumentsDirectory] mutableCopy];
    
    numberOfRow = self.files.count;
    [self mainTableView];
    
    
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
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.text = [self.files objectAtIndex:indexPath.row];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__func__);
    NSString *fileName = [self.files objectAtIndex:indexPath.row];
    NSLog(@"%@",fileName);
    NSString *filePath = [self.documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    NSLog(@"%@",filePath);
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSLog(@"%@",fileURL);
    [self.delegate onFileSelected:fileURL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
