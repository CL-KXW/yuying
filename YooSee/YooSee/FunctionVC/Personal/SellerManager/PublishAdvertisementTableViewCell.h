//
//  PublishAdvertisementTableViewCell.h
//  YooSee
//
//  Created by 周后云 on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishAdvertisementTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *contentLabel;

@property(nonatomic,weak)IBOutlet UIButton *coverButton;
@property(nonatomic,weak)IBOutlet UIButton *addPicture1;
@property(nonatomic,weak)IBOutlet UIButton *addPicture2;
@property(nonatomic,weak)IBOutlet UIButton *addPicture3;

@end
