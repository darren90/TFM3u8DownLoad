//
//  NSString+TF.m
//  test
//
//  Created by Tengfei on 15/5/8.
//  Copyright (c) 2015年 tengfei. All rights reserved.
//

#import "NSString+TF.h"

@implementation NSString (TF)


+(NSString *)getHttpDowningSize:(NSString *)fileName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDir = [NSString stringWithFormat:@"%@/Downloads/Temp/%@", docPath,fileName];
    return videoDir;
}

/**
 *  获取下载速度
 *
 *  @return 速度值，大于M的话用KB，不大于用MB
 */
-(NSString *)getDownSpeed
{
    long long bytes = [self longLongValue] / 5;
    
    if(bytes < 1000)     // B
    {
        return [NSString stringWithFormat:@"%lldB/S", bytes];
    }
    else if(bytes >= 1000 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.0fK/S", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.1fM/S", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.1fG/S", (double)bytes / (1024 * 1024 * 1024)];
    }
} 
@end
