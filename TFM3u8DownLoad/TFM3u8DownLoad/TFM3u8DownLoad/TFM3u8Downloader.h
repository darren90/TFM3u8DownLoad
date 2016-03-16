//
//  TFM3u8Downloader.h
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFM3u8FileModel.h"
#import "ASIHTTPRequest.h"
#pragma mark - m3u8文件下载的代理 M3u8DownloaderDelegate
 
@protocol TFM3u8DownloaderDelegate <NSObject>
@optional
-(void)m3u8DownloaderFinished:(ASIHTTPRequest *)request;
-(void)m3u8DownloaderFailed:(ASIHTTPRequest *)request;
-(void)m3u8DownloaderProgress:(ASIHTTPRequest *)request;
@end


#pragma mark - 正文的开始 M3u8Downloader
@interface TFM3u8Downloader : NSObject
+(TFM3u8Downloader *) sharedM3u8Downloader;


@property(nonatomic,strong)TFM3u8FileModel *fileInfo;

//开始下载
-(void)startDownLoad;

//重新下载
-(void)resumeRequest;
//停止下载
-(void)stopDownLoad;
//删除下载
-(void)deleteDownLoad;


//无用的一些逻辑
@property(nonatomic,weak)id<TFM3u8DownloaderDelegate> m3u8DownloadDelegate;//下载部分的delegate

@end
