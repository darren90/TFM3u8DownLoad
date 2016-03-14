//
//  M3u8DownloadDelegate.h
//  MovieBinge
//
//  Created by Fengtf on 16/2/29.
//  Copyright © 2016年 ftf. All rights reserved.
//

#ifndef M3u8DownloadDelegate_h
#define M3u8DownloadDelegate_h

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol M3u8DownloadDelegate <NSObject>

-(void)startDownloadM3u8:(ASIHTTPRequest *)request;
-(void)updateM3u8Progress:(ASIHTTPRequest *)request;
-(void)finishedDownloadM3u8:(ASIHTTPRequest *)request;
-(void)downloadM3u8Failed:(ASIHTTPRequest *)request;

//没有用到
-(void)allowNextRequestM3u8;//处理一个窗口内连续下载多个文件且重复下载的情况
@end



#pragma mark - 针对片段的下载

@protocol SegmentDownloadDelegate <NSObject>
@optional
-(void)partDownloadFinished:(ASIHTTPRequest *)request;
-(void)partDownloadFailed:(ASIHTTPRequest *)request;
-(void)partDownloadProgress:(ASIHTTPRequest *)request;
@end


#endif /* M3u8DownloadDelegate_h */
