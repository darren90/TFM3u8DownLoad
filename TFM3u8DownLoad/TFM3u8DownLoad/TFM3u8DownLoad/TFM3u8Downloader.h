//
//  TFM3u8Downloader.h
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFM3u8FileModel.h"

#pragma mark - m3u8文件下载的代理 M3u8DownloaderDelegate

@class ASIHTTPRequest;
@protocol TFM3u8DownloaderDelegate <NSObject>
@optional
-(void)partDownloadFinished:(ASIHTTPRequest *)request;
-(void)partDownloadFailed:(ASIHTTPRequest *)request;
-(void)partDownloadProgress:(ASIHTTPRequest *)request;
@end


#pragma mark - 正文的开始 M3u8Downloader


@class FileModel;
@interface TFM3u8Downloader : NSObject

//接收的参数
@property(nonatomic,strong)TFM3u8FileModel *filefileInfo;

@property(nonatomic,strong)FileModel *fileInfo;

@property (nonatomic,copy)NSString * uniquenName;

///仅仅用于在更新进度时，传递外部参数，无实际意义，
@property (nonatomic,strong)ASIHTTPRequest *tranferReques;

+(TFM3u8Downloader *) sharedM3u8Downloader;

//开始下载
-(void)startDownLoad;
//重新下载
-(void)resumeRequest;
//停止下载
-(void)stopDownLoad;
//删除下载
-(void)deleteDownLoad;
//
-(void)cleanDownLoad;
//无用的一些逻辑
@property(nonatomic,weak)id<TFM3u8DownloaderDelegate> partDownloadDelegate;//下载部分的delegate

@end
