//
//  M3u8FileModel.h
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class M3u8PartInfo;
@interface TFM3u8FileModel : NSObject

/**
    1：下载时，需要传递的参数
 */

/** 唯一 */
@property (nonatomic, copy) NSString * uniquenName;//唯一主键
@property(nonatomic,copy)NSString *fileName;//下载文件存储的的名字//XXX.mp4
@property(nonatomic,copy)NSString *fileURL;//下载地址


/**
    2：下载时，不需要传递的参数
 */
@property(nonatomic,copy)NSString *fileSize;//总大小
@property (nonatomic,assign)float progress;//进度
@property (nonatomic,assign)int segmentHadDown;//已经下载的片段



/**
    3：下载过程中会用到的参数
 */
@property(nonatomic,assign)BOOL isDownloading;//是否正在下载
@property(nonatomic,assign)BOOL willDownloading;
@property(nonatomic,assign)BOOL error;

//@property (nonatomic, copy) NSString * title;
@property (nonatomic,copy)NSString * iconUrl;//剧照
@property (nonatomic,assign)BOOL isHadDown;//是否已经下载完毕 - 下载完毕要更新为YES

@property(nonatomic,copy)NSString *targetPath;
@property(nonatomic,copy)NSString *tempPath;

//新加字段
@property (nonatomic,strong)M3u8PartInfo *m3u8Info;

@end



#pragma mark - m3u8片段模型-M3u8PartInfo

@interface M3u8PartInfo : NSObject
///片段时间
@property (nonatomic,assign) CGFloat duration;

//片段的地址
@property (nonatomic,copy) NSString *locationUrl;
@end
