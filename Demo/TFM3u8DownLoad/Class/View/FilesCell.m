//
//  FilesCell.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/11.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "FilesCell.h"
#import "ContentModel.h"
#import "FilesDownManage.h"
#import "DatabaseTool.h"

@interface FilesCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *DownBtn;


@end
@implementation FilesCell

- (void)awakeFromNib {
    // Initialization code
}



-(void)setModel:(ContentModel *)model
{
    _model = model;
    
    self.iconView.image = [UIImage imageNamed:model.iconUrl];
    self.titleLabel.text = model.title;
}


/**
 *  下载按钮被点击
 *
 *  @param sender 按钮
 */
- (IBAction)DownBtnClick:(UIButton *)sender {
    BOOL resutl = [DatabaseTool isThisHadLoaded:self.model.uniquenName];
    
    if (resutl) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"本文件已经下载" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        
        return;
    }
    
    NSLog(@"---downUrl:%@",self.model.downUrl);
    self.DownBtn.hidden = YES;
    NSLog(@"-加入下载列表成功r-----");
     [[FilesDownManage sharedFilesDownManage]downFileUrl:self.model];
}



@end
