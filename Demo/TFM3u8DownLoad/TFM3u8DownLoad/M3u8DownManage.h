//
//  M3u8DownManage.h
//  MovieBinge
//
//  Created by Fengtf on 16/2/29.
//  Copyright © 2016年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3u8DownloadDelegate.h"

@class ASIHTTPRequest,DownLoadModel;
@interface M3u8DownManage : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>

@property(nonatomic,strong)FileModel *fileInfo;
+(M3u8DownManage *) sharedFilesDownManage;


-(void)downFileUrl:(DownLoadModel *)downLoadModel;

//无用的一些逻辑
@property(nonatomic,weak)id<M3u8DownloadDelegate> m3u8DownloadDelegate;//下载列表delegate


@property (nonatomic,copy)NSString * uniquenName;

@property(nonatomic,strong)NSMutableArray *downinglist;//正在下载的文件列表(储存:ASIHttpRequest)
@property(nonatomic,strong)NSMutableArray *finishedlist;//已下载完成的文件列表（存储:FileModel）
@property(nonatomic,strong)NSMutableArray *filelist;//待下载的文件列表（存储:FileModel）


#pragma mark - 2016-03-01 最新的逻辑

//重新下载
-(void)resumeDownload:(ASIHTTPRequest *)request;
//删除下载
-(void)deleteDownload:(ASIHTTPRequest *)request;
//停止下载
-(void)stopDownload:(ASIHTTPRequest *)request;
@end
