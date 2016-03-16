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

@interface ViewController ()<TFM3u8DownloaderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)startDown:(UIButton *)sender;
- (IBAction)stopDown:(UIButton *)sender;
 
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.progressView.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma makr - 开始下载
- (IBAction)startDown:(UIButton *)sender{
    self.urlLabel.text = @"http://115.28.43.55/lol/index.php/YoukuM3u8/getplaylist/type/hd2/youkuid/XNzA5MDM3ODE2/movieid/8665/code/1d69c4fb5cc56e7b948edcc204d0e232";
    if (self.urlLabel.text == nil || self.urlLabel.text.length == 0) return;
    
    TFM3u8FileModel *model = [[TFM3u8FileModel alloc] init];
    model.fileURL = self.urlLabel.text;
    model.fileName = @"20160316";
    model.uniquenName = @"20160316";
    [TFM3u8Downloader sharedM3u8Downloader].fileInfo = model;
    [TFM3u8Downloader sharedM3u8Downloader].m3u8DownloadDelegate = self;
    [[TFM3u8Downloader sharedM3u8Downloader] startDownLoad];
}

#pragma mark - 暂定下载
- (IBAction)stopDown:(UIButton *)sender {
    [[TFM3u8Downloader sharedM3u8Downloader] stopDownLoad];
}

#pragma mark - TFM3u8Downloader 的代理

-(void)m3u8DownloaderProgress:(ASIHTTPRequest *)request{
    TFM3u8FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    NSLog(@"name:,%@--progress:%f",fileInfo.uniquenName,fileInfo.progress);
    
    self.progressView.progress = fileInfo.progress;
}

-(void)m3u8DownloaderFinished:(ASIHTTPRequest *)request{
    NSLog(@"---m3u8的文件下载完成----");
}


-(void)m3u8DownloaderFailed:(ASIHTTPRequest *)request{
    NSLog(@"---m3u8的文件下载失败----");
     NSError *error=[request error];
    NSLog(@"--m3u8--ASIHttpRequest出错了!%@",error);
 
    
}

@end
