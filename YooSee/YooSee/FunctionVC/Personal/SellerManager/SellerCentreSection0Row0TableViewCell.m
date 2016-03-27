//
//  SellerCentreSection0Row0TableViewCell.m
//  YooSee
//
//  Created by 周后云 on 16/3/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreSection0Row0TableViewCell.h"

@implementation SellerCentreSection0Row0TableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SellerCentreSection0Row0TableViewCell class]) owner:self options:nil] firstObject];
    }
    
    self.sellerLogoImageView.layer.cornerRadius = 80/2;
    self.sellerLogoImageView.layer.masksToBounds = YES;
    
    return self;
}

@end
