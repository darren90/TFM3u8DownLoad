//
//  TFDownLoadTools.h
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDownDomanPath @""  //下载的地址 //  /Downloads
#define kDownTargetPath @"Video"//下载的所在的文件夹
#define kDownTempPath @"Temp"//下载的所在的文件夹

#define KLocaPlaylUrl @"http://127.0.0.1:12345"

@interface TFDownLoadTools : NSObject

+(NSString *)getHttpDowningSize:(NSString *)fileName urlType:(int)urlType;

+(NSString *)getM3u8PlayUrl:(NSString *)uniquenName;


+(NSString *)dateToString:(NSDate*)date;


+(float)getProgress:(float)totalSize currentSize:(float)currentSize;


+(NSString *)getFileSizeString:(NSString *)size;


/**
 *  取得下载的目标路径，不存在会创建
 *
 *  @param name 名字不要包含.
 *
 *  @return 全部路径
 */
+(NSString *)getCrTargetPath:(NSString *)name;

/**
 *  取得下载的临时路径，不存在会创建
 *
 *  @param name 名字不要包含.
 *
 *  @return 全部路径
 */
+(NSString *)getCrTempPath:(NSString *)name;



//单纯的取出下载文件的目标路径
+(NSString *)getTargetPath:(NSString *)name;
//单纯的取出下载文件的临时路径
+(NSString *)getTempPath:(NSString *)name;



@end
