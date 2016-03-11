//
//  NewTwoXXVCACell.m
//  OspreyIAD
//
//  Created by cong on 16/1/2.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "NewsListCell.h"

@implementation NewsListCell

- (void)awakeFromNib {
    // Initialization code
    [CommonTool clipView:self.ButtomView withCornerRadius:10.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
