//
//  M3u8FileModel.h
//  MovieBinge
//
//  Created by Fengtf on 16/3/1.
//  Copyright © 2016年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>
@class M3u8PartInfo;
@interface M3u8FileModel : NSObject

/** 唯一 */
@property (nonatomic, copy) NSString * uniquenName;//唯一, movieId+episode
@property (nonatomic, copy) NSString * movieId;//剧集id
@property (nonatomic,assign)int episode;//第几集
@property (nonatomic, copy) NSString * title;
@property (nonatomic,copy)NSString * iconUrl;//剧照
@property (nonatomic,assign)BOOL isHadDown;//是否已经下载完毕 - 下载完毕要更新为YES
@property (nonatomic,assign)int urlType;//存储FileUrlType
//@property (nonatomic,assign)float progress;//进度
#pragma mark - m3u8下载专有的片段
@property (nonatomic,assign)float progress;//进度
@property (nonatomic,assign)int segmentHadDown;//已经下载的片段
#pragma mark - m3u8下载专有的片段
@property (nonatomic,copy)NSString * webPlayUrl;/** WebPlayUrl地址 */
@property (nonatomic,copy)NSString * quality;/**  *  视频质量,eg：height ;  */
@property (nonatomic,copy)NSString * episodeSid;//对应episode的sid

@property(nonatomic,copy)NSString *fileName;//下载文件存储的的名字//XXX.mp4
@property(nonatomic,copy)NSString *fileSize;//总大小
@property(nonatomic,copy)NSString *fileReceivedSize;
@property(nonatomic,assign)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,copy)NSString *fileURL;//下载地址
@property(nonatomic,copy)NSString *time;
@property(nonatomic,assign)BOOL isDownloading;//是否正在下载
@property(nonatomic,assign)BOOL willDownloading;
@property(nonatomic,assign)BOOL error;

@property(nonatomic,copy)NSString *targetPath;
@property(nonatomic,copy)NSString *tempPath;

//新加字段
@property (nonatomic,strong)M3u8PartInfo *m3u8Info;

@end
