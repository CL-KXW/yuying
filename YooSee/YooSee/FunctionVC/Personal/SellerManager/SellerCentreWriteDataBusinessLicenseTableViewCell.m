//
//  SellerCentreWriteDataBusinessLicenseTableViewCell.m
//  YooSee
//
//  Created by 周后云 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreWriteDataBusinessLicenseTableViewCell.h"

@implementation SellerCentreWriteDataBusinessLicenseTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        self.businessLicenseView = Alloc(SelectPictureButton);
        [self.contentView addSubview:self.businessLicenseView];
        [self.businessLicenseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(0);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(0);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(0);
            make.bottom.equalTo(self.promptLabel.mas_top).with.offset(-10);
        }];
    }
    return self;
}

@end
