//
//  PartDownloader.h
//  MovieBinge
//
//  Created by Fengtf on 16/3/1.
//  Copyright © 2016年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3u8DownloadDelegate.h"
#import "M3u8FileModel.h"

@class FileModel;
@interface PartDownloader : NSObject

//接收的参数
@property(nonatomic,strong)M3u8FileModel *filefileInfo;

@property(nonatomic,strong)FileModel *fileInfo;

@property (nonatomic,copy)NSString * uniquenName;


///仅仅用于在更新进度时，传递外部参数，无实际意义，
@property (nonatomic,strong)ASIHTTPRequest *tranferReques;

+(PartDownloader *) sharedPartDownloader;

//-(void)downFileUrl:(DownLoadModel *)downLoadModel;
//
//-(void)stopRequest:(ASIHTTPRequest *)request;
//
//-(void)resumeRequest:(ASIHTTPRequest *)request;

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
@property(nonatomic,weak)id<SegmentDownloadDelegate> partDownloadDelegate;//下载部分的delegate

@property(nonatomic,strong)NSMutableArray *downinglist;//正在下载的文件列表(储存:ASIHttpRequest)
@property(nonatomic,strong)NSMutableArray *finishedlist;//已下载完成的文件列表（存储:FileModel）

@end
