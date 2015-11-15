//
//  DownloadedCell.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/14.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "DownloadedCell.h"
#import "ContentModel.h"

@interface DownloadedCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DownloadedCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setModel:(ContentModel *)model
{

    _model = model;
    self.imageView.image = [UIImage imageNamed:model.iconUrl];
    self.titleLabel.text = model.title;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
