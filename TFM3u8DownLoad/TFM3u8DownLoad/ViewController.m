//
//  ViewController.m
//  TFM3u8DownLoad
//
//  Created by Tengfei on 15/11/15.
//  Copyright © 2015年 tengfei. All rights reserved.
//

#import "ViewController.h"
#import "TFM3u8FileModel.h"
#import "TFM3u8Downloader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)startDown:(UIButton *)sender;
- (IBAction)stopDown:(UIButton *)sender;
 
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma makr - 开始下载
- (IBAction)startDown:(UIButton *)sender {
    TFM3u8FileModel *model = [[TFM3u8FileModel alloc] init];
    [TFM3u8Downloader sharedM3u8Downloader].fileInfo = model;
}

#pragma mark - 暂定下载
- (IBAction)stopDown:(UIButton *)sender {
    
}
@end
