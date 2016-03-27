//
//  SellerCentreWriteDataBusinessLicenseTableViewCell.h
//  YooSee
//
//  Created by 周后云 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectPictureButton.h"
#import "PromptTextfield.h"

@interface SellerCentreWriteDataBusinessLicenseTableViewCell : UITableViewCell

@property(nonatomic,strong)SelectPictureButton *businessLicenseView;

@property(nonatomic,weak)IBOutlet UILabel *promptLabel;

@end
