//
//  DowningCell.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/14.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "DowningCell.h"
#import "ASIHTTPRequest.h"
#import "FileModel.h"
#import "CommonHelper.h"
#import "WdCleanCaches.h"
#import "FilesDownManage.h"
#import "NSString+TF.h"
#import "DowningController.h"

@interface DowningCell()
@property (nonatomic,weak)IBOutlet UIImageView * iconView;
@property (nonatomic,weak)IBOutlet UIProgressView * progressView;
@property (nonatomic,weak)IBOutlet UILabel * currentSizeLabel;
@property (nonatomic,weak)IBOutlet UILabel * nameLabel;
@property (nonatomic,weak)IBOutlet UIButton * downBtn;
@property (nonatomic,weak)IBOutlet UILabel * speedLabel;/** 速度值/暂停/等待 */

@end

@implementation DowningCell

- (void)awakeFromNib {
    // Initialization code
}


-(IBAction)downBtnClick:(UIButton *)btn
{
    [self operateTask];
}


#pragma mark - 新下载逻辑
-(void)setRequest:(ASIHTTPRequest *)request
{
    _request = request;
    
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    self.fileInfo=fileInfo;
    
    [self updateContentCPS:fileInfo];
}

/**
 *  根据模型，每秒都进行界面的刷新
 *
 *  @param fileInfo 模型
 */
-(void)updateContentCPS:(FileModel *)fileInfo
{
    double downedSize = [WdCleanCaches biteSizeWithPaht:[NSString getHttpDowningSize:fileInfo.fileName]];
    if (downedSize > [fileInfo.fileSize longLongValue]) {
        downedSize = [fileInfo.fileSize longLongValue];
    }
    
    NSString *currentsize = [CommonHelper getFileSizeString:[NSString stringWithFormat:@"%f",downedSize]];
    NSString *totalsize = [CommonHelper getFileSizeString:fileInfo.fileSize];
    self.nameLabel.text = fileInfo.title;
    self.iconView.image = [UIImage imageNamed:fileInfo.iconUrl];
 
    NSMutableString *sizeStr = [NSMutableString stringWithFormat:@"已下载 : %@ / ",currentsize];
    if ([totalsize longLongValue] <= 0) {
        [sizeStr appendString:@"未知"];
    }else
        [sizeStr appendString:totalsize];
    self.currentSizeLabel.text = sizeStr;
    
    __block float progress = 0.0;
    if ([fileInfo.fileSize longLongValue] == 0) {
        [self.progressView setProgress:progress animated:YES];
    }else
        progress = [CommonHelper getProgress:[fileInfo.fileSize longLongValue] currentSize:downedSize];
    [self.progressView setProgress:progress animated:YES];
   
    NSString *speed = [NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]];
    self.speedLabel.text = [speed getDownSpeed];//[NSString stringWithFormat:@"%0.0f%@",100*(progress),@"%"];
    
    if(fileInfo.isDownloading){//文件正在下载
        [self.downBtn setImage:[UIImage imageNamed:@"btn_downlaod_n"] forState:UIControlStateNormal];
    }else if(!fileInfo.isDownloading && !fileInfo.willDownloading&&!fileInfo.error)  {
        [self.downBtn setImage:[UIImage imageNamed:@"btn_timeout_n"] forState:UIControlStateNormal];
        self.speedLabel.text = @"暂停";
    }else if(!fileInfo.isDownloading && fileInfo.willDownloading&&!fileInfo.error)  {
        [self.downBtn setImage:[UIImage imageNamed:@"btn_wating_n"] forState:UIControlStateNormal];
        self.speedLabel.text = @"等待";
    }else if (fileInfo.error) {
        [self.downBtn setImage:[UIImage imageNamed:@"btn_downlaod_no"] forState:UIControlStateNormal];
        self.speedLabel.text = @"错误";
    }
}

-(void)setFileInfo:(FileModel *)fileInfo
{
    _fileInfo = fileInfo;
}

#pragma mark - 操作（暂停、继续）正在下载的文件
-(void)operateTask
{
    FileModel *downFile = self.fileInfo;
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    if(downFile.error){
        
    }else{
        if(downFile.isDownloading){//文件正在下载，点击之后暂停下载 有可能进入等待状态
            [self.downBtn setImage:[UIImage imageNamed:@"btn_downlaod_n"] forState:UIControlStateNormal];
            [filedownmanage stopRequest:self.request];
        } else {
            [self.downBtn setImage:[UIImage imageNamed:@"btn_timeout_n"] forState:UIControlStateNormal];
            [filedownmanage resumeRequest:self.request];
        }
    }
    //暂停意味着这个Cell里的ASIHttprequest已被释放，要及时更新table的数据，使最新的ASIHttpreqst控制Cell
    if ([self.cDelegate respondsToSelector:@selector(ReloadDownLoadingTable)]) {
        [((DowningController *)self.cDelegate) ReloadDownLoadingTable];
    }
}

 #pragma mark - 删除下载
- (void)deleteRquest{
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    [filedownmanage deleteRequest:self.request];
    if ([self.cDelegate respondsToSelector:@selector(ReloadDownLoadingTable)])
        [((DowningController*)self.cDelegate) ReloadDownLoadingTable];
}


- (void)drawRect:(CGRect)rect 
{
    CGFloat lineHeight = 0.4;
    CGFloat cellHetht = self.frame.size.height;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 0, cellHetht - lineHeight);
    CGContextAddLineToPoint(ctx, self.contentView.frame.size.width, cellHetht - lineHeight);
    CGContextSetRGBStrokeColor(ctx, 0.88, 0.88, 0.88, 1.0);
    CGContextStrokePath(ctx);
}
@end
