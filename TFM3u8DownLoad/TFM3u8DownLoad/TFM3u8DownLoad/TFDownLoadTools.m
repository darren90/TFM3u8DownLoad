//
//  TFDownLoadTools.m
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import "TFDownLoadTools.h"
 
@implementation TFDownLoadTools

+(NSString *)getHttpDowningSize:(NSString *)fileName urlType:(int)urlType
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    if (urlType == 1) {//m3u8类型
        NSString *videoDir = [NSString stringWithFormat:@"%@/Video/%@", docPath,fileName];
        return videoDir;
    }else{
        
        NSString *videoDir = [NSString stringWithFormat:@"%@/Temp/%@.mp4", docPath,fileName];
        return videoDir;
    }
}

+(NSString *)getM3u8PlayUrl:(NSString *)uniquenName
{
    NSString *url = [NSString stringWithFormat:@"%@%@/Video/%@/movie.m3u8",KLocaPlaylUrl,kDownDomanPath,uniquenName];
    return url;
}


+(NSString *)dateToString:(NSDate*)date{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"MM-dd HH:mm:ss"];//[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *datestr = [df stringFromDate:date];
    return datestr;
}


+(float)getProgress:(float)totalSize currentSize:(float)currentSize
{
    return currentSize/totalSize;
}


+(NSString *)getFileSizeString:(NSString *)size
{
    long long floatSize = [size longLongValue];
    if(floatSize >= 1024*1024){//大于1M，则转化成M单位的字符串
        return [NSString stringWithFormat:@"%.1fM",floatSize/1024.0/1024];
    }
    else if(floatSize >= 1024 && floatSize < 1024*1024){ //不到1M,但是超过了1KB，则转化成KB单位
        return [NSString stringWithFormat:@"%lldK",floatSize/1024];
    }
    else{//剩下的都是小于1K的，则转化成B单位
        return [NSString stringWithFormat:@"%lldB",floatSize];
    }
}


//name：m3u8：是文件夹。mp4是文件名
+(NSString *)getCrTargetPath:(NSString *)name
{
    NSString *pathstr = [self getDownBasePath];
    pathstr =  [pathstr stringByAppendingPathComponent:kDownTargetPath];
    pathstr =  [pathstr stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:pathstr]) {
        [fileManager createDirectoryAtPath:pathstr withIntermediateDirectories:YES attributes:nil error:&error];
        if(!error)  {
            NSLog(@"%@",[error description]);
        }
    }
    return pathstr;
}

//name：m3u8：是文件夹。mp4是文件名
+(NSString *)getCrTempPath:(NSString *)name
{
    NSString *pathstr = [self getDownBasePath];
    pathstr =  [pathstr stringByAppendingPathComponent:kDownTempPath];
    pathstr =  [pathstr stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:pathstr]) {
        [fileManager createDirectoryAtPath:pathstr withIntermediateDirectories:YES attributes:nil error:&error];
        if(!error){
            NSLog(@"%@",[error description]);
        }
    }
    return pathstr;
}


//name：m3u8：是文件夹。mp4是文件名
+(NSString *)getTargetPath:(NSString *)name
{
    NSString *pathstr = [self getDownBasePath];
    pathstr =  [pathstr stringByAppendingPathComponent:kDownTargetPath];
    pathstr =  [pathstr stringByAppendingPathComponent:name];
    return pathstr;
}

//name：m3u8：是文件夹。mp4是文件名
+(NSString *)getTempPath:(NSString *)name
{
    NSString *pathstr = [self getDownBasePath];
    pathstr =  [pathstr stringByAppendingPathComponent:kDownTempPath];
    pathstr =  [pathstr stringByAppendingPathComponent:name];
    return pathstr;
}



+(NSString *)getDownBasePath{
    NSString *pathstr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    pathstr = [pathstr stringByAppendingPathComponent:kDownDomanPath];
    return pathstr;
}




@end
