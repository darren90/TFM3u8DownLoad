//
//  DowningCell.h
//  TFDownLoad
//
//  Created by Fengtf on 15/11/14.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileModel,ASIHTTPRequest;

@interface DowningCell : UITableViewCell

@property(nonatomic,strong)FileModel *fileInfo;
@property(nonatomic,assign)UIViewController *cDelegate;
@property(nonatomic,strong)ASIHTTPRequest *request;//该文件发起的请求

/**
 *  根据模型，每秒都进行界面的刷新
 *
 *  @param fileInfo 模型
 */
-(void)updateContentCPS:(FileModel *)fileInfo;


@end
