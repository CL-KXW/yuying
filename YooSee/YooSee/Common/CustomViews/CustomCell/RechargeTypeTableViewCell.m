//
//  RechargeTypeTableViewCell.m
//  OspreyIAD
//
//  Created by youyoujushi on 15/7/1.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import "RechargeTypeTableViewCell.h"

@implementation RechargeTypeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    float height = self.frame.size.height-40;
    float width = height * 212 / 88 ;
    [self.imageView setFrame:CGRectMake(0, 20,width,height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.backgroundColor = [UIColor clearColor];
    /*CGRect rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame);
    self.textLabel.frame = rect;*/
    
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.textColor = [UIColor colorWithRed:155.f/255.f green:155.f/255.f blue:155.f/255.f alpha:1.f];
    
    if(self.imageView.image == nil)
    {
        CGRect rect = self.textLabel.frame;
        rect.origin.x = 0;
        rect.size.width = self.frame.size.width;
        self.textLabel.frame = rect;
        self.textLabel.textAlignment = UITextAlignmentCenter;
    }else
    {
        CGRect rect = self.textLabel.frame;
        rect.origin.x = CGRectGetMaxX(self.imageView.frame);
        rect.size.width = self.frame.size.width-rect.origin.x;
        self.textLabel.frame = rect;
        //self.textLabel.textAlignment = UITextAlignment;
    }
    //_isSelect = YES;
    
}

@end
