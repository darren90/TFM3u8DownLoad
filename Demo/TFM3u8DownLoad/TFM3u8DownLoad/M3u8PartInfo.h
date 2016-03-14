//
//  M3u8PartInfo.h
//  MovieBinge
//
//  Created by Fengtf on 16/2/29.
//  Copyright © 2016年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>


//视频片段的模型
@interface M3u8PartInfo : NSObject

///片段时间
@property (nonatomic,assign) CGFloat duration;

//片段的地址
@property (nonatomic,copy) NSString *locationUrl;


@end
