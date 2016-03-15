//
//  NSString+TF.h
//  test
//
//  Created by Tengfei on 15/5/8.
//  Copyright (c) 2015年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TF)


/**
 *  获取下载速度
 *
 *  @return 速度值，大于M的话用KB，不大于用MB
 */
-(NSString *)getDownSpeed;
 
+(NSString *)getHttpDowningSize:(NSString *)fileName;

@end












