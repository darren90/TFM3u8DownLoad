//
//  DatabaseTool.h
//  Diancai1
//
//  Created by user on 14+3+11.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DownLoadModel,FileModel;

@interface DatabaseTool : NSObject
 
/*******************************5 -- 新 - 下载2.0****************************************/
+(BOOL)addFileModelWithModel:(FileModel *)model;

/**
 *  根据是否下载完毕取出所有的数据
 *
 *  @param isDowned YES：已经下载，NO：未下载
 *
 *  @return 装有FileModel的模型
 */
+(NSArray *)getFileModeArray:(BOOL)isHadDown;

/**
 *  下载完毕更新数据库
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
//+(BOOL)updateFileModeWhenDownFinish:(FileModel *)model;

+(void)updateFilesModeWhenDownFinish:(NSArray *)array;

/**
 *  下载完毕更新数据库
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeWhenDownFinish:(FileModel *)model;
/**
 *  针对获取到真正的文件总大小的时候，更新文件的总大小
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeTotalSize:(FileModel *)model;

/**
 *  这个剧是否在下载列表
 *
 *  @param uniquenName uniquenName
 *
 *  @return YES：存在 ； NO：不存在
 */
+(BOOL)isFileModelInDB:(NSString *)uniquenName;

/**
 *  读取那些剧被下载 -- 不包括详细信息（只取到那些剧集被下载即可）
 *
 *  @return 下载完毕的剧集Array
 */
+(NSArray *)getFileModelsHadDownLoad;
 
/**
 *  是否这部剧已经下载完毕
 *
 *  @param uniquenName 剧集Id
 *
 *  @return YES:下载完毕 ； NO：没有下载完毕
 */
+(BOOL)isThisHadLoaded:(NSString *)fileName;


/**
 *  根据uniquenName删除已经下载的剧
 *
 *  @param uniquenName  
 *
 *  @return YES:成功；NO：失败
 */
+(BOOL)delFileModelWithUniquenName:(NSString *)uniquenName;
 
 
/*******************************5 -- 新 - 下载2.0****************************************/

@end
















